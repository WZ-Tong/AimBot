module iic_tx #(
	parameter DEVICE_ADDR_LEN = 7, // 设备地址宽度
	parameter REG_ADDR_LEN    = 8, // 寄存器地址宽度
	parameter DATA_LEN        = 8  // 数据长度
) (
	input                            clk        ,
	input                            rstn       ,
	input      [DEVICE_ADDR_LEN-1:0] device_addr, // 从机地址
	input      [   REG_ADDR_LEN-1:0] reg_addr   , // 从机寄存器地址
	input      [       DATA_LEN-1:0] data       , // IIC传输数据
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
	DATA,
	DATA_ACK,
	STOP
} state_t;
state_t state, next_state;

reg sda_en, sda_data;
assign sda = sda_en ? sda_data : 1'bz;
parameter MAX_LEN = DEVICE_ADDR_LEN > REG_ADDR_LEN ? (DEVICE_ADDR_LEN > DATA_LEN ?DEVICE_ADDR_LEN:DATA_LEN) : (REG_ADDR_LEN > DATA_LEN ? REG_ADDR_LEN : DATA_LEN);
reg [$clog2(MAX_LEN)-1:0] count;

always_ff @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		state <= #1 IDLE;
	end else begin
		state <= #1 next_state;
	end
end

always_comb begin
	case (state)
		IDLE            : if (start) next_state = START;
		START           : next_state = DEVICE_ADDR;
		DEVICE_ADDR     : if (count == 0) next_state = RW;
		RW              : if (scl) next_state = DEVICE_ADDR_ACK;
		DEVICE_ADDR_ACK :
			if (scl) begin
				if (sda == ACK) begin
					next_state = REGISTER_ADDR;
				end else begin
					next_state = IDLE;
				end
			end
		REGISTER_ADDR     : if (count == 0) next_state = REGISTER_ADDR_ACK;
		REGISTER_ADDR_ACK : next_state = DATA;
		DATA              : next_state = DATA_ACK;
		DATA_ACK          : next_state = STOP;
		STOP              : next_state = IDLE;
	endcase
end

always_ff @(posedge clk or negedge rstn) begin
	if (!rstn) begin
		scl      <= #1 1'b1;
		sda_en   <= #1 1'b1;
		sda_data <= #1 1'b1;
		count    <= #1 DEVICE_ADDR_LEN - 1'b1;
	end else begin
		case (state)
			START : begin
				// 时钟信号 scl 保持为1, 数据信号拉低, 传输开始
				scl      <= #1 1'b1;
				sda_en   <= #1 1'b1;
				sda_data <= #1 1'b0;
				count    <= #1 DEVICE_ADDR_LEN - 1'b1;
			end
			DEVICE_ADDR : begin
				// 退出此状态时 scl 为低电平
				if (scl) begin
					// 拉低时钟, 并准备下一个数据
					scl      <= #1 1'b0;
					sda_en   <= #1 1'b1;
					sda_data <= #1 device_addr[count];
					count    <= #1 count - 1'b1;
				end else begin
					// 拉高时钟, 并保持数据不变
					scl      <= #1 1'b1;
					sda_en   <= #1 1'b1;
					sda_data <= #1 sda_data;
					count    <= #1 count;
				end
			end
			RW : begin
				// 退出此状态时 scl 为低电平
				if (scl) begin
					// 拉低时钟, 将模式设置为 WRITE
					scl      <= #1 1'b0;
					sda_en   <= #1 1'b1;
					sda_data <= #1 WRITE;
					count    <= #1 count;
				end else begin
					// 拉高时钟, 并保持数据不变, 并等待接收从机应答信号
					scl      <= #1 1'b1;
					sda_en   <= #1 1'b0; // 将 sda 转换为输入模式
					sda_data <= #1 sda_data;
					count    <= #1 count;
				end
			end
			DEVICE_ADDR_ACK : begin
				if (scl) begin
					// 拉低时钟, 由状态决定是否下一步
					scl      <= #1 1'b0;
					sda_en   <= #1 1'b0;
					sda_data <= #1 sda_data;
					count    <= #1 count;
				end else begin
					// 拉高时钟, 让数据保持稳定
					scl      <= #1 1'b1;
					sda_en   <= #1 1'b0;
					sda_data <= #1 sda_data;
					count    <= #1 count;
				end
			end
			// TODO
			default : begin
				scl      <= 1'b1;
				sda_data <= 1'b1;
			end
		endcase
	end
end


endmodule : iic_tx
