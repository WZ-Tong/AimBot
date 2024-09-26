// MS7210模块的初始化与数据传输

`timescale 1ns / 1ps

module hdmi_ctrl (
    // 原始数据输入输出
    input        clk50    ,
    input        rstn     ,
    output       inited   ,

    // MS7200 (HDMI Input)
    output       i_pix_clk, // HDMI传入图像: 像素时钟
    output       i_hsync  , // HDMI传入图像: 行同步信号
    output       i_vsync  , // HDMI传入图像: 帧同步信号
    output       i_de     , // HDMI传入图像: 有效像素点使能信号
    output [7:0] i_r      , // HDMI传入图像: 像素点位(R)
    output [7:0] i_g      , // HDMI传入图像: 像素点位(G)
    output [7:0] i_b      , // HDMI传入图像: 像素点位(B)

    // MS7210 (HDMI Output)
    output       o_pix_clk, // HDMI显示图像: 像素时钟
    output       o_hsync  , // HDMI显示图像: 行同步信号
    output       o_vsync  , // HDMI显示图像: 帧同步信号
    output       o_de     , // HDMI显示图像: 有效像素点使能信号
    output [7:0] o_r      , // HDMI显示图像: 像素点位(R)
    output [7:0] o_g      , // HDMI显示图像: 像素点位(G)
    output [7:0] o_b      , // HDMI显示图像: 像素点位(B)
    output       o_int    , // MS7210: 输出中断

    // IIC Ctrl
    output       iic_rstn ,
    output       iic_i_scl,
    inout        iic_i_sda,
    output       iic_o_scl,
    inout        iic_o_sda
);

wire locked;
wire clk10 ;

`ifdef PLL_50M_10M
    PLL inst_pll (
        .clkin1  (clk50 ),
        .pll_lock(locked),
        .clkout0 (clk10 )
    );
`else
    reg       _clk_div_10 ;
    reg [2:0] _clk_div_cnt;
    always @(posedge clk50 or negedge rstn) begin
        if (~rstn) begin
            _clk_div_10  <= #1 'b0;
            _clk_div_cnt <= #1 'b0;
        end
        else begin
            if (_clk_div_cnt == 4) begin
                _clk_div_10  <= #1 ~_clk_div_10;
                _clk_div_cnt <= #1 'b0;
            end else begin
                _clk_div_cnt <= #1 _clk_div_cnt + 1'b1;
            end
        end
    end
`endif

ms72xx_ctl inst_ms72xx_ctl (
    .clk       (clk10    ),
    .rst_n     (iic_rstn ),
    .init_over (inited   ),
    .iic_tx_scl(iic_o_scl),
    .iic_tx_sda(iic_o_sda),
    .iic_scl   (iic_i_scl),
    .iic_sda   (iic_i_sda)
);

endmodule : hdmi_ctrl
