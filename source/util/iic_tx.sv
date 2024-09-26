module iic_tx #(
	parameter SCL_CLK_DIV     = 64, // IIC总线时钟分频系数
	parameter DEVICE_ADDR_LEN = 7 , // 设备地址宽度
	parameter REG_ADDR_LEN    = 8 , // 寄存器地址宽度
	parameter DATA_LEN        = 8   // 数据长度
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

// localparam READ  = 1'b1;
localparam WRITE = 1'b0;
localparam ACK   = 1'b1;

typedef enum logic [3:0] {
	IDLE,
	START,

	DEVICE_ADDR,
	RW,
	DEVICE_ADDR_ACK,

	REGISTER_ADDR,
	REGISTER_ADDR_ACK,

	WRITE_DATA,
	WRITE_DATA_ACK,

	STOP
} state_t;
state_t state;
assign busy = state != IDLE;

reg sda_en, sda_data;
assign sda = sda_en ? sda_data : 1'bz;

localparam MAX_LEN = DEVICE_ADDR_LEN > REG_ADDR_LEN ? (DEVICE_ADDR_LEN > DATA_LEN ? DEVICE_ADDR_LEN : DATA_LEN) : (REG_ADDR_LEN > DATA_LEN ? REG_ADDR_LEN : DATA_LEN);
reg [$clog2(MAX_LEN)-1:0] data_count;

localparam CLK_HALF = SCL_CLK_DIV / 2;
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
				if (start) begin
					state     <= #1 START;
					clk_count <= #1 'b0;
				end
			end
			START : begin
				if (clk_count == CLK_HALF) begin
					sda_en    <= #1 'b1;
					sda_data  <= #1 'b0;
					clk_count <= #1 clk_count + 1'b1;
				end else if (clk_count == SCL_CLK_DIV - 1) begin
					state     <= #1 DEVICE_ADDR;
					clk_count <= #1 'b0;
				end else begin
					clk_count <= #1 clk_count + 1'b1;
				end
			end
			DEVICE_ADDR : begin

			end
			RW : begin

			end
			DEVICE_ADDR_ACK : begin

			end
			REGISTER_ADDR : begin

			end
			REGISTER_ADDR_ACK : begin

			end
			WRITE_DATA : begin

			end
			WRITE_DATA_ACK : begin

			end
			STOP : begin

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
