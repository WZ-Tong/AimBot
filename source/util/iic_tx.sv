module iic_tx #(
	parameter SCL_DIV         = 64, // IIC总线时钟分频系数
	parameter DEVICE_ADDR_LEN = 7 , // 设备地址宽度
	parameter REG_ADDR_LEN    = 8 , // 寄存器地址宽度
	parameter DATA_LEN        = 8   // 数据长度
) (
	input                            clk        ,
	input                            rstn       ,
	input                            rw         , // 控制读写
	input      [DEVICE_ADDR_LEN-1:0] device_addr, // 从机地址
	input      [   REG_ADDR_LEN-1:0] reg_addr   , // 从机寄存器地址
	input      [       DATA_LEN-1:0] w_data     , // IIC写入数据
	output reg [       DATA_LEN-1:0] r_data     , // IIC读取数据
	input                            start      , // 用于启动IIC传输
	output reg                       busy       , // IIC总线正忙

	inout                            sda        , // IIC数据
	output reg                       scl          // IIC时钟
);

localparam READ  = 1'b1;
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

	// Write
	WRITE_DATA,
	WRITE_DATA_ACK,
	// Read
	READ_START,
	READ_DEVICE_ADDR,

	STOP
} state_t;
state_t state;

reg sda_en, sda_data;
assign sda = sda_en ? sda_data : 1'bz;

localparam MAX_LEN = DEVICE_ADDR_LEN > REG_ADDR_LEN ? (DEVICE_ADDR_LEN > DATA_LEN ? DEVICE_ADDR_LEN : DATA_LEN) : (REG_ADDR_LEN > DATA_LEN ? REG_ADDR_LEN : DATA_LEN);
reg [$clog2(MAX_LEN)-1:0] data_count;

localparam CLK_HALF = SCL_DIV / 2;
reg [$clog2(SCL_DIV)-1:0] clk_count;

always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		state      <= #1 IDLE;
		data_count <= #1 'b0;
		clk_count  <= #1 'b0;
	end else begin

	end
end

endmodule : iic_tx
