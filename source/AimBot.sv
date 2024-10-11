`timescale 1ns / 1ps

module AimBot #(
    parameter BITS        = 8       ,

    parameter V_TOTAL     = 12'd750 ,
    parameter V_FP        = 12'd5   ,
    parameter V_BP        = 12'd20  ,
    parameter V_SYNC      = 12'd5   ,
    parameter V_ACT       = 12'd720 ,

    parameter H_TOTAL     = 12'd1650,
    parameter H_FP        = 12'd110 ,
    parameter H_BP        = 12'd220 ,
    parameter H_SYNC      = 12'd40  ,
    parameter H_ACT       = 12'd1280,

    parameter V_BOX_WIDTH = 1'b1    ,
    parameter H_BOX_WIDTH = 1'b1    ,

    parameter N_BOX       = 1'b1
) (
    input             clk        ,
    input             rstn       ,

    inout             cam_scl   ,
    inout             cam_sda   ,
    input             cam_vsync ,
    input             cam_href  ,
    input             cam_pclk  ,
    input  [BITS-1:0] cam_data  ,
    output            cam_reset ,
    output            cam_heart ,

    output            hdmi_hsync ,
    output            hdmi_vsync ,
    output            hdmi_de    ,
    output [BITS-1:0] hdmi_r     ,
    output [BITS-1:0] hdmi_g     ,
    output [BITS-1:0] hdmi_b     ,

    output            hdmi_rstn  ,
    output            hdmi_scl   ,
    inout             hdmi_sda
);

    // Pll clk generator
    wire clk10, clk10l;
    wire clk20, clk20l;
    wire clk25, clk25l;
    fake_pll #(.CLK(3)) pll (
        .i(clk                   ),
        .l({clk10l,clk20l,clk25l}),
        .o({clk10, clk20, clk25} )
    );

    // HDMI configure
    wire hdmi_inited;
    hdmi_ctrl hdmi_ctrl (
        .rstn        (rstn       ),
        .clk10       (clk10      ),
        .clk10_locked(clk10l     ),
        .inited      (hdmi_inited),
        .iic_rstn    (hdmi_rstn  ),
        .iic_i_scl   (/*unused*/ ),
        .iic_i_sda   (/*unused*/ ),
        .iic_o_scl   (hdmi_scl   ),
        .iic_o_sda   (hdmi_sda   )
    );

    // OV5640 configure & read
    wire cam_inited;

    wire        cam_vsync_565;
    wire        cam_href_565 ;
    wire        cam_pclk_565 ;
    wire [15:0] cam_data_565 ;
    ov5640_reader ov5640_reader (
        .clk25        (clk25        ),
        .rstn         (rstn         ),
        .cam_vsync    (cam_vsync    ),
        .cam_href     (cam_href     ),
        .cam_pclk     (cam_pclk     ),
        .cam_data     (cam_data     ),
        .cam_inited   (cam_inited   ),
        .cam_vsync_565(cam_vsync_565),
        .cam_href_565 (cam_href_565 ),
        .cam_pclk_565 (cam_pclk_565 ),
        .cam_data_565 (cam_data_565 ),
        .cam_scl      (cam_scl      ),
        .cam_sda      (cam_sda      ),
        .cam_rstn     (cam_rstn     )
    );

endmodule : AimBot
