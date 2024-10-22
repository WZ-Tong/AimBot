`timescale 1ns / 1ps

module AimBot #(
    parameter V_BOX_WIDTH = 1'b1,
    parameter H_BOX_WIDTH = 1'b1,
    parameter N_BOX       = 1'b1,
    parameter CAM_DISPLAY = 1
) (
    input        clk          ,
    input        rstn         ,
    input        svg_rstn     ,

    inout        cam1_scl     ,
    inout        cam1_sda     ,
    input        cam1_vsync     /*synthesis PAP_MARK_DEBUG="true"*/,
    input        cam1_href      /*synthesis PAP_MARK_DEBUG="true"*/,
    input        cam1_pclk      /*synthesis PAP_MARK_DEBUG="true"*/,
    input  [7:0] cam1_data    ,
    output       cam1_rstn    ,

    inout        cam2_scl     ,
    inout        cam2_sda     ,
    input        cam2_vsync   ,
    input        cam2_href    ,
    input        cam2_pclk    ,
    input  [7:0] cam2_data    ,
    output       cam2_rstn    ,

    output       hdmi_clk     ,
    output       hdmi_hsync   ,
    output       hdmi_vsync   ,
    output       hdmi_de      ,
    output [7:0] hdmi_r       ,
    output [7:0] hdmi_g       ,
    output [7:0] hdmi_b       ,

    output       hdmi_rstn    ,
    output       hdmi_scl     ,
    inout        hdmi_sda     ,

    input        rgmii1_rxc   ,
    input        rgmii1_rx_ctl,
    input  [3:0] rgmii1_rxd   ,

    output       rgmii1_txc   ,
    output       rgmii1_tx_ctl,
    output [3:0] rgmii1_txd   ,

    input        rgmii2_rxc   ,
    input        rgmii2_rx_ctl,
    input  [3:0] rgmii2_rxd   ,

    output       rgmii2_txc   ,
    output       rgmii2_tx_ctl,
    output [3:0] rgmii2_txd   ,

    // Debug signals
    output       hdmi_inited  ,
    output       cam_inited   ,
    output       frame_tick
);

    wire clk10, clk25;
    clk_div #(.DIV(5)) u_clk10_gen (.i_clk(clk), .o_clk(clk10));
    clk_div #(.DIV(2)) u_clk25_gen (.i_clk(clk), .o_clk(clk25));

    // HDMI configure
    hdmi_ctrl u_hdmi_ctrl (
        .rstn     (rstn       ),
        .clk10    (clk10      ),
        .inited   (hdmi_inited),
        .iic_rstn (hdmi_rstn  ),
        .iic_i_scl(/*unused*/ ),
        .iic_i_sda(/*unused*/ ),
        .iic_o_scl(hdmi_scl   ),
        .iic_o_sda(hdmi_sda   )
    );

    // OV5640 configure & read
    wire [15:0] cam1_data_565, cam2_data_565;

    wire cam1_inited, cam2_inited;
    wire cam1_pclk_565, cam2_pclk_565;
    wire cam1_href_565, cam2_href_565;
    assign cam_inited = cam1_inited && cam2_inited;

    ov5640_reader u_cam1_reader (
        .clk25   (clk25        ),
        .rstn    (rstn         ),
        .vsync   (cam1_vsync   ),
        .href    (cam1_href    ),
        .pclk    (cam1_pclk    ),
        .data    (cam1_data    ),
        .inited  (cam1_inited  ),
        .href_565(cam1_href_565),
        .pclk_565(cam1_pclk_565),
        .data_565(cam1_data_565),
        .cfg_scl (cam1_scl     ),
        .cfg_sda (cam1_sda     ),
        .cfg_rstn(cam1_rstn    )
    );

    ov5640_reader u_cam2_reader (
        .clk25   (clk25        ),
        .rstn    (rstn         ),
        .vsync   (cam2_vsync   ),
        .href    (cam2_href    ),
        .pclk    (cam2_pclk    ),
        .data    (cam2_data    ),
        .inited  (cam2_inited  ),
        .href_565(cam2_href_565),
        .pclk_565(cam2_pclk_565),
        .data_565(cam2_data_565),
        .cfg_scl (cam2_scl     ),
        .cfg_sda (cam2_sda     ),
        .cfg_rstn(cam2_rstn    )
    );

    wire [15:0] cam_data;
    wire        cam_clk, cam_vsync, cam_href;

    if (CAM_DISPLAY==1) begin
        assign cam_vsync = cam1_vsync;
        assign cam_clk   = cam1_pclk_565;
        assign cam_data  = cam1_data_565;
        assign cam_href  = cam1_href_565;
    end else if (CAM_DISPLAY==2) begin
        assign cam_vsync = cam2_vsync;
        assign cam_clk   = cam2_pclk_565;
        assign cam_data  = cam2_data_565;
        assign cam_href  = cam2_href_565;
    end
    wire [49:0] disp_pack;
    hdmi_display u_hdmi_display (
        .clk    (cam_clk  ),
        .rstn   (svg_rstn ),
        .i_vsync(cam_vsync),
        .i_data (cam_data ),
        .i_href (cam_href ),
        .o_pack (disp_pack)
    );

    wire [49:0] wb_pack;
    white_balance #(
        .H_ACT(1280),
        .V_ACT(720 )
    ) u_white_balance (
        .i_pack(disp_pack),
        .o_pack(wb_pack  )
    );

    wire [49:0] win_pack;
    draw_window #(
        .V_BOX_WIDTH(40),
        .H_BOX_WIDTH(20),
        .N_BOX      (1 )
    ) u_draw_window (
        .i_pack  (wb_pack   ),
        .o_pack  (win_pack  ),
        .start_xs(11'd100   ),
        .start_ys(10'd200   ),
        .end_xs  (11'd200   ),
        .end_ys  (10'd400   ),
        .colors  (24'hFFFFFF)
    );

    hdmi_unpack u_hdmi_output (
        .pack (win_pack  ),
        .clk  (hdmi_clk  ),
        .hsync(hdmi_hsync),
        .vsync(hdmi_vsync),
        .de   (hdmi_de   ),
        .r    (hdmi_r    ),
        .g    (hdmi_g    ),
        .b    (hdmi_b    )
    );

    tick #(.TICK(30)) u_frame_tick (
        .clk (hdmi_clk  ),
        .rstn(rstn      ),
        .trig(hdmi_vsync),
        .tick(frame_tick)
    );

endmodule : AimBot
