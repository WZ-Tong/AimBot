`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/08 09:51:43
// Design Name: 
// Module Name: rgb2gray
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//=======================================================
//============== rgb转灰度--三级流水线 ===================
//=======================================================


module rgb2gray(
input               clk         ,
input               rst_n       ,
input   [23:0]      din         ,
input               de_in     ,
input               vs_in     ,
input               hs_in     ,

output  [23:0]      ycrcb     ,
output reg          de_out    ,
output reg          vs_out    ,
output reg          hs_out    //都照着de一样做相同的打拍操作即可
    );

 reg [7:0]    dout1  ;
assign ycrcb={dout1,14'b0};//只要灰度，cr，cb都为0

reg [7:0]   data_r;
reg [7:0]   data_g;
reg [7:0]   data_b;

reg [17:0]  temp_r;
reg [17:0]  temp_g;
reg [17:0]  temp_b;

reg [1:0]   de_vld;
reg [1:0]   vs_vld;
reg [1:0]   hs_vld;



//rgb分量寄存 
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        data_r <= 8'b0;
        data_b <= 8'b0;
        data_g <= 8'b0;
    end
    else if(de_in)
        begin
            data_r <= din[23:16];
            data_g <= din[15:8];
            data_b <= din[7:0];
        end
end

//vld寄存   delay 2clk
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        de_vld <= 2'b0;
        hs_vld <= 2'b0;
        vs_vld <= 2'b0;
    end
    else begin//移位打拍，这种写法确实也可以
        de_vld <= {de_vld[0],de_in}; 
        hs_vld <= {hs_vld[0],hs_in}; 
        vs_vld <= {vs_vld[0],vs_in}; 
    end
end


//=================================================================
//                rgb2YCrCb算法主体部分
//=================================================================

//rgb_temp分量计算 ==pipe_line1
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        temp_r <= 17'd0;
        temp_g <= 17'd0;
        temp_b <= 17'd0;
    end
    else if(de_vld[0] == 1'b1) begin   //din_vld有效
        temp_r <= data_r*77;
        temp_g <= data_g*150;
        temp_b <= data_b*29;
    end
end


//dout计算 ==pipe_line2
reg [18:0]  dout_temp;
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        dout_temp <= 19'd0;
    else if(de_vld[1] == 1'b1)     //din_vld延时 时钟后
        dout_temp <= (temp_r + temp_g + temp_b)>>8;
end



//de_out 此处会延时一个时钟  组合逻辑改为时序逻辑
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)begin
        de_out <= 1'b0;
        hs_out <= 1'b0;
        vs_out <= 1'b0;
    end
    else begin
        dout1 <= dout_temp[7:0];
        de_out <= de_vld[1];
        hs_out <= hs_vld[1];
        vs_out <= vs_vld[1];
    end       
end
endmodule
