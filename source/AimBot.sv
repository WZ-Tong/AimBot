`timescale 1ns / 1ps

module AimBot #(
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
    input        clk        ,
    input        rstn       ,

    inout        cam1_scl   ,
    inout        cam1_sda   ,
    input        cam1_vsync ,
    input        cam1_href  ,
    input        cam1_pclk  ,
    input  [7:0] cam1_data  ,
    output       cam1_rstn  ,

    inout        cam2_scl   ,
    inout        cam2_sda   ,
    input        cam2_vsync ,
    input        cam2_href  ,
    input        cam2_pclk  ,
    input  [7:0] cam2_data  ,
    output       cam2_rstn  ,

    output       hdmi_hsync ,
    output       hdmi_vsync ,
    output       hdmi_de    ,
    output [7:0] hdmi_r     ,
    output [7:0] hdmi_g     ,
    output [7:0] hdmi_b     ,

    output       hdmi_rstn  ,
    output       hdmi_scl   ,
    inout        hdmi_sda   ,

    output       hdmi_inited,
    output       cam1_inited,
    output       cam2_inited,
    output       cam1_tick  ,
    output       cam2_tick
);

    wire clk10, clk25, clk400, clkl;
    pll u_pll (
        .pll_rst (~rstn ),
        .clkin1  (clk   ),
        .pll_lock(clkl  ),
        .clkout0 (clk25 ),
        .clkout1 (clk10 ),
        .clkout2 (clk400)
    );

    // HDMI configure
    hdmi_ctrl u_hdmi_ctrl (
        .rstn        (rstn       ),
        .clk10       (clk10      ),
        .clk10_locked(clkl       ),
        .inited      (hdmi_inited),
        .iic_rstn    (hdmi_rstn  ),
        .iic_i_scl   (/*unused*/ ),
        .iic_i_sda   (/*unused*/ ),
        .iic_o_scl   (hdmi_scl   ),
        .iic_o_sda   (hdmi_sda   )
    );

    // OV5640 configure & read
    wire        cam1_href_565,  cam2_href_565;
    wire        cam1_pclk_565,  cam2_pclk_565;
    wire [15:0] cam1_data_565,  cam2_data_565;

    ov5640_reader u_cam1_reader (
        .clk25       (clk25        ),
        .clk25_locked(clkl         ),
        .rstn        (rstn         ),
        .cam_vsync   (cam1_vsync   ),
        .cam_href    (cam1_href    ),
        .cam_pclk    (cam1_pclk    ),
        .cam_data    (cam1_data    ),
        .cam_inited  (cam1_inited  ),
        .cam_href_565(cam1_href_565),
        .cam_pclk_565(cam1_pclk_565),
        .cam_data_565(cam1_data_565),
        .cam_scl     (cam1_scl     ),
        .cam_sda     (cam1_sda     ),
        .cam_rstn    (cam1_rstn    )
    );

    ov5640_reader u_cam2_reader (
        .clk25       (clk25        ),
        .clk25_locked(clkl         ),
        .rstn        (rstn         ),
        .cam_vsync   (cam2_vsync   ),
        .cam_href    (cam2_href    ),
        .cam_pclk    (cam2_pclk    ),
        .cam_data    (cam2_data    ),
        .cam_inited  (cam2_inited  ),
        .cam_href_565(cam2_href_565),
        .cam_pclk_565(cam2_pclk_565),
        .cam_data_565(cam2_data_565),
        .cam_scl     (cam2_scl     ),
        .cam_sda     (cam2_sda     ),
        .cam_rstn    (cam2_rstn    )
    );

    localparam CAM_TICK            = 30  ;
    localparam CAM_FRAME_DBG_CNT   = 1024;
    localparam CAM_PIX_CLK_DBG_CNT = 102400;

    reg [$clog2(CAM_FRAME_DBG_CNT)-1:0] cam1_frame_dbg_cnt /*synthesis PAP_MARK_DEBUG="true"*/;
    reg [$clog2(CAM_FRAME_DBG_CNT)-1:0] cam2_frame_dbg_cnt /*synthesis PAP_MARK_DEBUG="true"*/;

    tick #(.TICK(CAM_TICK), .DBG_CNT(CAM_FRAME_DBG_CNT)) u_cam1_frame_tick (
        .clk    (clk               ),
        .rstn   (rstn              ),
        .trig   (cam1_vsync        ),
        // .tick   (cam1_tick         ),
        .dbg_cnt(cam1_frame_dbg_cnt)
    );

    tick #(.TICK(CAM_TICK), .DBG_CNT(CAM_FRAME_DBG_CNT)) u_cam2_frame_tick (
        .clk    (clk         ),
        .rstn   (rstn        ),
        .trig   (cam2_vsync  ),
        // .tick   (cam2_tick   ),
        .dbg_cnt(cam2_frame_dbg_cnt)
    );

    reg [$clog2(CAM_PIX_CLK_DBG_CNT)-1:0] cam1_pix_clk_dbg_cnt /*synthesis PAP_MARK_DEBUG="true"*/;
    reg [$clog2(CAM_PIX_CLK_DBG_CNT)-1:0] cam2_pix_clk_dbg_cnt /*synthesis PAP_MARK_DEBUG="true"*/;

    tick #(.TICK(1), .DBG_CNT(CAM_PIX_CLK_DBG_CNT)) u_cam1_pix_tick (
        .clk    (clk400              ),
        .rstn   (rstn&clkl           ),
        .trig   (cam1_pclk           ),
        .tick   (cam1_tick           ),
        .dbg_cnt(cam1_pix_clk_dbg_cnt)
    );

    tick #(.TICK(1), .DBG_CNT(CAM_PIX_CLK_DBG_CNT)) u_cam2_pix_tick (
        .clk    (clk400              ),
        .rstn   (rstn&clkl           ),
        .trig   (cam2_pclk           ),
        .tick   (cam2_tick           ),
        .dbg_cnt(cam2_pix_clk_dbg_cnt)
    );

endmodule : AimBot
