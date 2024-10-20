`timescale 1ns / 1ps

module AimBot #(
    parameter V_BOX_WIDTH = 1'b1,
    parameter H_BOX_WIDTH = 1'b1,
    parameter N_BOX       = 1'b1,
    parameter CAM_DISPLAY = 1
) (
    input         clk        ,
    input         rstn       ,
    input         svg_rstn   ,

    inout         cam1_scl   ,
    inout         cam1_sda   ,
    input         cam1_vsync ,
    input         cam1_href  ,
    input         cam1_pclk  ,
    input  [ 7:0] cam1_data  ,
    output        cam1_rstn  ,

    inout         cam2_scl   ,
    inout         cam2_sda   ,
    input         cam2_vsync ,
    input         cam2_href  ,
    input         cam2_pclk  ,
    input  [ 7:0] cam2_data  ,
    output        cam2_rstn  ,

    output        hdmi_clk     /*synthesis PAP_MARK_DEBUG="true"*/,
    output        hdmi_hsync   /*synthesis PAP_MARK_DEBUG="true"*/,
    output        hdmi_vsync   /*synthesis PAP_MARK_DEBUG="true"*/,
    output        hdmi_de      /*synthesis PAP_MARK_DEBUG="true"*/,
    output [ 7:0] hdmi_r       /*synthesis PAP_MARK_DEBUG="true"*/,
    output [ 7:0] hdmi_g       /*synthesis PAP_MARK_DEBUG="true"*/,
    output [ 7:0] hdmi_b       /*synthesis PAP_MARK_DEBUG="true"*/,

    output        hdmi_rstn  ,
    output        hdmi_scl   ,
    inout         hdmi_sda   ,

    output        mem_rst_n  ,
    output        mem_ck     ,
    output        mem_ck_n   ,
    output        mem_cke    ,
    output        mem_cs_n   ,
    output        mem_ras_n  ,
    output        mem_cas_n  ,
    output        mem_we_n   ,
    output        mem_odt    ,
    output [14:0] mem_a      ,
    output [ 2:0] mem_ba     ,
    inout  [ 3:0] mem_dqs    ,
    inout  [ 3:0] mem_dqs_n  ,
    inout  [31:0] mem_dq     ,
    output [ 3:0] mem_dm     ,

    // Debug signals
    output        hdmi_inited,
    output        cam_inited ,
    output        buf_tick   ,
    output        comb_err
);

    wire clk10, clk25, clk36_946, clk150, clkl;
    pll u_pll (
        .pll_rst (~rstn    ),
        .clkin1  (clk      ),
        .pll_lock(clkl     ),
        .clkout0 (clk36_946),
        .clkout1 (clk25    ),
        .clkout2 (clk10    ),
        .clkout3 (clk150   )
    );
    assign hdmi_clk = clk36_946;

    wire debug_clk;
    assign debug_clk = clk150;

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
    wire [15:0] cam1_data_565, cam2_data_565;

    wire cam1_inited, cam2_inited;
    wire cam1_pclk_565, cam2_pclk_565;
    wire cam1_href_565, cam2_href_565;
    assign cam_inited = cam1_inited && cam2_inited;

    ov5640_reader u_cam1_reader (
        .clk25       (clk25        ),
        .clk25_locked(clkl         ),
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
        .clk25       (clk25        ),
        .clk25_locked(clkl         ),
        .rstn        (rstn         ),
        .vsync       (cam2_vsync   ),
        .href        (cam2_href    ),
        .pclk        (cam2_pclk    ),
        .data        (cam2_data    ),
        .inited      (cam2_inited  ),
        .href_565    (cam2_href_565),
        .pclk_565    (cam2_pclk_565),
        .data_565    (cam2_data_565),
        .cfg_scl     (cam2_scl     ),
        .cfg_sda     (cam2_sda     ),
        .cfg_rstn    (cam2_rstn    )
    );

    wire [7:0] cam_r, cam_g, cam_b;

    wire disp_clk ;
    wire disp_href;
    if (CAM_DISPLAY==1) begin
        assign disp_clk  = cam1_pclk_565;
        assign disp_href = cam1_href_565;
        assign cam_r     = {cam1_data_565[15:11], 3'b0};
        assign cam_g     = {cam1_data_565[10:05], 2'b0};
        assign cam_b     = {cam1_data_565[04:00], 3'b0};
    end else if (CAM_DISPLAY==2) begin
        assign disp_clk  = cam2_pclk_565;
        assign disp_href = cam2_href_565;
        assign cam_r     = {cam2_data_565[15:11], 3'b0};
        assign cam_g     = {cam2_data_565[10:05], 2'b0};
        assign cam_b     = {cam2_data_565[04:00], 3'b0};
    end
    assign hdmi_clk = disp_clk;
    assign hdmi_r   = cam_r;
    assign hdmi_g   = cam_g;
    assign hdmi_b   = cam_b;
    hdmi_display u_hdmi_display (
        .clk    (disp_clk  ),
        .rstn   (rstn      ),
        .href   (disp_href ),
        .hsync  (hdmi_hsync),
        .vsync  (hdmi_vsync),
        .data_en(hdmi_de   )
    );


endmodule : AimBot
