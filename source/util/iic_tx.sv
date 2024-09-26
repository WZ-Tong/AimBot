module iic_tx #(
    parameter SCL_CLK_DIV     = 64, // IIC总线时钟分频系数
    parameter DEVICE_ADDR_LEN = 7 , // 设备地址宽度
    parameter REG_ADDR_LEN    = 8 , // 寄存器地址宽度
    parameter DATA_LEN        = 8 , // 数据长度
    parameter DEBUG           = 0   // 0:ACK失败返回IDLE, 1:ACK失败继续流程
) (
    input                            clk        ,
    input                            rstn       ,
    input      [DEVICE_ADDR_LEN-1:0] device_addr, // 从机地址
    input      [   REG_ADDR_LEN-1:0] reg_addr   , // 从机寄存器地址
    input      [       DATA_LEN-1:0] data       , // IIC写入数据
    input                            start      , // 用于启动IIC传输
    output                           busy       , // IIC总线正忙

    inout                            sda        , // IIC数据
    output reg                       scl          // IIC时钟
);

    localparam READ  = 1'b1;
    localparam WRITE = 1'b0;

    localparam ACK  = 1'b0;
    localparam NACK = ~ACK;

    localparam IDLE              = 4'b0000;
    localparam START             = 4'b0001;
    localparam DEVICE_ADDR       = 4'b0010;
    localparam RW                = 4'b0011;
    localparam DEVICE_ADDR_ACK   = 4'b0100;
    localparam REGISTER_ADDR     = 4'b0101;
    localparam REGISTER_ADDR_ACK = 4'b0110;
    localparam WRITE_DATA        = 4'b0111;
    localparam WRITE_DATA_ACK    = 4'b1000;
    localparam STOP              = 4'b1001;

    localparam MAX_LEN = DEVICE_ADDR_LEN > REG_ADDR_LEN ? (DEVICE_ADDR_LEN > DATA_LEN ? DEVICE_ADDR_LEN : DATA_LEN) : (REG_ADDR_LEN > DATA_LEN ? REG_ADDR_LEN : DATA_LEN);

    reg [3:0] state;
    assign busy = state != IDLE;

    reg sda_en, sda_data;
    assign sda = sda_en ? sda_data : 1'bz;

    reg [$clog2(MAX_LEN)-1:0] data_count;

    localparam CLK_START  = 0                  ;
    localparam CLK_HALF   = SCL_CLK_DIV / 2    ;
    localparam CLK_BEGIN  = SCL_CLK_DIV / 4    ;
    localparam CLK_END    = SCL_CLK_DIV * 3 / 4;
    localparam CLK_FINISH = SCL_CLK_DIV - 1    ;

    reg [$clog2(SCL_CLK_DIV)-1:0] clk_count;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            state      <= #1 IDLE;
            scl        <= #1 1'b1;
            sda_en     <= #1 1'b1;
            sda_data   <= #1 1'b1;
            data_count <= #1 'b0;
            clk_count  <= #1 'b0;
        end else begin
            case (state)
                IDLE : begin
                    scl        <= #1 1'b1;
                    sda_en     <= #1 1'b1;
                    sda_data   <= #1 1'b1;
                    clk_count  <= #1 'b0;
                    data_count <= #1 'b0;
                    if (start) begin
                        state <= #1 START;
                    end
                end
                START : begin // scl = 1, data_count = 0, sda_en = 1
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_HALF) begin
                        sda_en   <= #1 'b1;
                        sda_data <= #1 'b0;
                    end else if (clk_count == CLK_FINISH) begin
                        state      <= #1 DEVICE_ADDR;
                        scl        <= #1 'b0;
                        data_count <= #1 DEVICE_ADDR_LEN - 1;
                        clk_count  <= #1 'b0;
                    end else begin
                    end
                end
                DEVICE_ADDR : begin // scl = 0, data_count = DEVICE_ADDR_LEN - 1, sda_en = 1
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_START) begin
                        sda_data <= #1 device_addr[data_count];
                    end else if (clk_count == CLK_BEGIN) begin
                        scl <= #1 'b1;
                    end else if (clk_count == CLK_END) begin
                        scl <= #1 'b0;
                    end else if (clk_count == CLK_FINISH) begin
                        if (data_count != 'b0) begin
                            data_count <= #1 data_count - 1'b1;
                        end else begin
                            state <= #1 RW;
                        end
                        clk_count <= #1 'b0;
                    end
                end
                RW : begin // scl = 0, data_count = 0, sda_en = 1
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_START) begin
                        sda_data <= #1 WRITE;
                    end else if (clk_count == CLK_BEGIN) begin
                        scl <= #1 'b1;
                    end else if (clk_count == CLK_END) begin
                        scl <= #1 'b0;
                    end else if (clk_count == CLK_FINISH) begin
                        clk_count  <= #1 'b0;
                        sda_en     <= #1 'b0;
                        data_count <= #1 NACK;
                        state      <= #1 DEVICE_ADDR_ACK;
                    end
                end
                DEVICE_ADDR_ACK : begin // scl = 0, data_count = NACK, sda_en = 0
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_BEGIN) begin
                        scl <= #1 'b1;
                    end else if (clk_count == CLK_HALF) begin
                        data_count <= #1 sda;
                    end else if (clk_count == CLK_END) begin
                        scl <= #1 'b0;
                    end else if (clk_count == CLK_FINISH) begin
                        if (data_count == ACK || DEBUG) begin
                            data_count <= #1 REG_ADDR_LEN - 1;
                            sda_en     <= #1 'b1;
                            state      <= #1 REGISTER_ADDR;
                        end else begin
                            state <= #1 IDLE; // Slave DEVICE_ADDR_ACK failed
                        end
                        clk_count <= #1 'b0;
                    end
                end
                REGISTER_ADDR : begin // scl = 0, data_count = REG_ADDR_LEN - 1, sda_en = 1
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_START) begin
                        sda_data <= #1 reg_addr[data_count];
                    end else if (clk_count == CLK_BEGIN) begin
                        scl <= #1 'b1;
                    end else if (clk_count == CLK_END) begin
                        scl <= #1 'b0;
                    end else if (clk_count == CLK_FINISH) begin
                        if (data_count != 'b0) begin
                            data_count <= #1 data_count - 1'b1;
                        end else begin
                            sda_en     <= #1 'b0;
                            data_count <= #1 NACK;
                            state      <= #1 REGISTER_ADDR_ACK;
                        end
                        clk_count <= #1 'b0;
                    end
                end
                REGISTER_ADDR_ACK : begin // scl = 0, data_count = NACK, sda_en = 0
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_BEGIN) begin
                        scl <= #1 'b1;
                    end else if (clk_count == CLK_HALF) begin
                        data_count <= #1 sda;
                    end else if (clk_count == CLK_END) begin
                        scl <= #1 'b0;
                    end else if (clk_count == CLK_FINISH) begin
                        if (data_count == ACK || DEBUG) begin
                            data_count <= #1 DATA_LEN - 1;
                            sda_en     <= #1 'b1;
                            state      <= #1 WRITE_DATA;
                        end else begin
                            state <= #1 IDLE; // Slave REGISTER_ADDR_ACK failed
                        end
                        clk_count <= #1 'b0;
                    end
                end
                WRITE_DATA : begin // scl = 0, data_count = DATA_LEN - 1, sda_en = 1
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_START) begin
                        sda_data <= #1 data[data_count];
                    end else if (clk_count == CLK_BEGIN) begin
                        scl <= #1 'b1;
                    end else if (clk_count == CLK_END) begin
                        scl <= #1 'b0;
                    end else if (clk_count == CLK_FINISH) begin
                        if (data_count != 'b0) begin
                            data_count <= #1 data_count - 1'b1;
                        end else begin
                            sda_en     <= #1 'b0;
                            data_count <= #1 NACK;
                            state      <= #1 WRITE_DATA_ACK;
                        end
                        clk_count <= #1 'b0;
                    end
                end
                WRITE_DATA_ACK : begin // scl = 0, data_count = NACK, sda_en = 0
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_BEGIN) begin
                        scl <= #1 'b1;
                    end else if (clk_count == CLK_HALF) begin
                        data_count <= #1 sda;
                    end else if (clk_count == CLK_END) begin
                        scl <= #1 'b0;
                    end else if (clk_count == CLK_FINISH) begin
                        if (data_count == ACK || DEBUG) begin
                            data_count <= #1 'b0;
                            sda_en     <= #1 'b1;
                            state      <= #1 WRITE_DATA;
                        end else begin
                            state <= #1 IDLE; // Slave REGISTER_ADDR_ACK failed
                        end
                        clk_count <= #1 'b0;
                    end
                end
                STOP : begin // scl = 0, data_count = 0, sda_en = 1
                    clk_count <= #1 clk_count + 1'b1;
                    if (clk_count == CLK_BEGIN) begin
                        scl <= #1 'b1;
                    end else if (clk_count == CLK_HALF) begin
                        sda_data <= #1 'b1;
                    end else if (clk_count == CLK_FINISH) begin
                        state <= #1 IDLE;
                    end
                end
                default : begin
                    state      <= #1 IDLE;
                    scl        <= #1 1'b1;
                    sda_en     <= #1 1'b1;
                    sda_data   <= #1 1'b1;
                    data_count <= #1 'b0;
                    clk_count  <= #1 'b0;
                end
            endcase
        end
    end

endmodule : iic_tx
