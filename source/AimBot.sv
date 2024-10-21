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
    output       cam_inited
);

    wire clk10, clk25;
    clk_div #(.DIV(5)) u_clk10_gen (.i_clk(clk), .o_clk(clk10));
    clk_div #(.DIV(2)) u_clk25_gen (.i_clk(clk), .o_clk(clk25));

    // HDMI configure
    hdmi_ctrl u_hdmi_ctrl (
        .rstn        (rstn       ),
        .clk10       (clk10      ),
        .inited      (hdmi_inited),
        .iic_rstn    (hdmi_rstn  ),
        .iic_i_scl   (/*unused*/ ),
        .iic_i_sda   (/*unused*/ ),
        .iic_o_scl   (hdmi_scl   ),
        .iic_o_sda   (hdmi_sda   )
    );

    // OV5640 configure & read
    wire [15:0] cam1_data_565, cam2_data_565;

    wire cam1_inited, cam2_inited;
    wire cam1_pclk_565, cam2_pclk_565;
    wire cam1_href_565, cam2_href_565;
    assign cam_inited = cam1_inited && cam2_inited;

    ov5640_reader u_cam1_reader (
        .clk25       (clk25        ),
        .rstn        (rstn         ),
        .vsync       (cam1_vsync   ),
        .href        (cam1_href    ),
        .pclk        (cam1_pclk    ),
        .data        (cam1_data    ),
        .inited      (cam1_inited  ),
        .href_565    (cam1_href_565),
        .pclk_565    (cam1_pclk_565),
        .data_565    (cam1_data_565),
        .cfg_scl     (cam1_scl     ),
        .cfg_sda     (cam1_sda     ),
        .cfg_rstn    (cam1_rstn    )
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


    wire [10:0] x;
    wire [ 9:0] y;

    wire [15:0] cam_data;
    wire        cam_clk, cam_vsync;

    wire [15:0] disp_data ;
    wire        disp_vsync, disp_hsync, disp_de, disp_clk;
    if (CAM_DISPLAY==1) begin
        assign cam_vsync = cam1_vsync;
        assign cam_clk   = cam1_pclk_565;
        assign cam_data  = cam1_data_565;
    end else if (CAM_DISPLAY==2) begin
        assign cam_vsync = cam2_vsync;
        assign cam_clk   = cam2_pclk_565;
        assign cam_data  = cam2_data_565;
    end
    hdmi_display u_hdmi_display (
        .clk    (cam_clk   ),
        .rstn   (svg_rstn  ),
        .i_vsync(cam_vsync ),
        .i_data (cam_data  ),
        .o_hsync(disp_hsync),
        .o_vsync(disp_vsync),
        .o_de   (disp_de   ),
        .o_data (disp_data ),
        .o_x    (x         ),
        .o_y    (y         )
    );
    assign disp_clk = cam_clk;

    wire [7:0] disp_r, disp_g, disp_b;
    assign disp_r = {disp_data[15:11], 3'b0};
    assign disp_g = {disp_data[10:05], 2'b0};
    assign disp_b = {disp_data[04:00], 3'b0};

    wire [7:0] win_r, win_g, win_b;
    wire       win_vsync, win_hsync, win_de, win_clk;
    draw_window #(
        .V_BOX_WIDTH(40),
        .H_BOX_WIDTH(20),
        .N_BOX      (1 )
    ) u_draw_window (
        .clk     (disp_clk  ),
        .x       (x         ),
        .y       (y         ),
        .start_xs(11'd100   ),
        .start_ys(10'd200   ),
        .end_xs  (11'd200   ),
        .end_ys  (10'd400   ),
        .colors  (24'hFFFFFF),
        .i_hsync (disp_hsync),
        .i_vsync (disp_vsync),
        .i_r     (disp_r    ),
        .i_g     (disp_g    ),
        .i_b     (disp_b    ),
        .o_hsync (win_hsync ),
        .o_vsync (win_vsync ),
        .o_r     (win_r     ),
        .o_g     (win_g     ),
        .o_b     (win_b     )
    );
    assign win_clk = disp_clk;
    assign win_de  = disp_de;

    assign hdmi_r     = win_r    ;
    assign hdmi_g     = win_g    ;
    assign hdmi_b     = win_b    ;
    assign hdmi_de    = win_de   ;
    assign hdmi_vsync = win_vsync;
    assign hdmi_hsync = win_hsync;
    assign hdmi_clk   = win_clk  ;



endmodule : AimBot
