`timescale 1ns / 1ps

module pixel_process (
    input        clk      ,
    input        inited   , // HDMI输入输出是否已经初始化完成

    // MS7200 (HDMI Input)
    input        i_pix_clk, // 像素时钟
    input        i_hsync  , // 行同步信号
    input        i_vsync  , // 帧同步信号
    input        i_de     , // 有效像素点使能信号
    input  [7:0] i_r      , // 像素点位(R)
    input  [7:0] i_g      , // 像素点位(G)
    input  [7:0] i_b      , // 像素点位(B)

    // MS7210 (HDMI Output)
    output       o_pix_clk, // 像素时钟
    output       o_hsync  , // 行同步信号
    output       o_vsync  , // 帧同步信号
    output       o_de     , // 有效像素点使能信号
    output [7:0] o_r      , // 像素点位(R)
    output [7:0] o_g      , // 像素点位(G)
    output [7:0] o_b        // 像素点位(B)
);

endmodule : pixel_process
