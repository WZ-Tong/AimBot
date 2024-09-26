module iic_tx_tb ();

    localparam SCL_CLK_DIV     = 64; // IIC总线时钟分频系数
    localparam DEVICE_ADDR_LEN = 7 ; // 设备地址宽度
    localparam REG_ADDR_LEN    = 8 ; // 寄存器地址宽度
    localparam DATA_LEN        = 8 ; // 数据长度
    localparam DEBUG           = 1 ; // 0:ACK失败返回IDLE, 1:ACK失败继续流程

    logic clk ;
    logic rstn;

    logic [DEVICE_ADDR_LEN-1:0] device_addr;
    logic [   REG_ADDR_LEN-1:0] reg_addr   ;
    logic [       DATA_LEN-1:0] data       ;

    logic start;
    logic busy ;
    logic sda  ;
    logic scl  ;

    iic_tx #(
        .SCL_CLK_DIV    (SCL_CLK_DIV    ),
        .DEVICE_ADDR_LEN(DEVICE_ADDR_LEN),
        .REG_ADDR_LEN   (REG_ADDR_LEN   ),
        .DATA_LEN       (DATA_LEN       ),
        .DEBUG          (DEBUG          )
    ) inst_iic_tx (
        .clk        (clk        ),
        .rstn       (rstn       ),
        .device_addr(device_addr),
        .reg_addr   (reg_addr   ),
        .data       (data       ),
        .start      (start      ),
        .busy       (busy       ),
        .sda        (sda        ),
        .scl        (scl        )
    );

    `ifdef __ICARUS__
        initial begin
            $dumpfile("iic_tx_tb.vcd");
            $dumpvars(0, iic_tx_tb);
        end
    `endif
    always @(*) begin
        clk <= #10 ~clk;
    end
    initial begin
        clk = 0;
        rstn = 0;
        #13;
        rstn = 1;
        #1000;
        $finish;
    end

endmodule : iic_tx_tb
