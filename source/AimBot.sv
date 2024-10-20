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
    input         cam1_vsync   /*synthesis PAP_MARK_DEBUG="true"*/,
    input         cam1_href    /*synthesis PAP_MARK_DEBUG="true"*/,
    input         cam1_pclk    /*synthesis PAP_MARK_DEBUG="true"*/,
    input  [ 7:0] cam1_data  ,
    output        cam1_rstn  ,

    inout         cam2_scl   ,
    inout         cam2_sda   ,
    input         cam2_vsync ,
    input         cam2_href  ,
    input         cam2_pclk  ,
    input  [ 7:0] cam2_data  ,
    output        cam2_rstn  ,

    output        hdmi_clk   ,
    output        hdmi_hsync ,
    output        hdmi_vsync ,
    output        hdmi_de    ,
    output [ 7:0] hdmi_r     ,
    output [ 7:0] hdmi_g     ,
    output [ 7:0] hdmi_b     ,

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
    output        cam_inited 
);

    wire clk10, clk25, clk150, clkl;
    pll u_pll (
        .pll_rst (~rstn     ),
        .clkin1  (clk       ),
        .pll_lock(clkl      ),
        .clkout0 (/*unused*/),
        .clkout1 (clk25     ),
        .clkout2 (clk10     ),
        .clkout3 (clk150    )
    );

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


    wire [10:0] x;
    wire [ 9:0] y;

    wire [15:0] cam_data;
    wire        cam_clk, cam_vsync;

    wire [15:0] disp_data ;
    wire        disp_vsync, disp_hsync, disp_de;
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

    wire [7:0] disp_r, disp_g, disp_b;
    assign disp_r = {disp_data[15:11], 3'b0};
    assign disp_g = {disp_data[10:05], 2'b0};
    assign disp_b = {disp_data[04:00], 3'b0};

    wire [7:0] win_r, win_g, win_b;
    draw_window #(
        .V_BOX_WIDTH(40),
        .H_BOX_WIDTH(20),
        .N_BOX      (1 )
    ) u_draw_window (
        .clk     (cam_clk   ),
        .hsync   (hdmi_hsync),
        .vsync   (hdmi_vsync),
        .x       (x         ),
        .y       (y         ),
        .start_xs(11'd100   ),
        .start_ys(10'd200   ),
        .end_xs  (11'd200   ),
        .end_ys  (10'd400   ),
        .colors  (24'hFFFFFF),
        .i_r     (disp_r    ),
        .i_g     (disp_g    ),
        .i_b     (disp_b    ),
        .o_r     (win_r     ),
        .o_g     (win_g     ),
        .o_b     (win_b     )
    );

    assign hdmi_r   = win_r;
    assign hdmi_g   = win_g;
    assign hdmi_b   = win_b;
    assign hdmi_clk = cam_clk;

    wire         ddr_clk, ddr_clkl;
    wire [ 27:0] axi_awaddr     ;
    wire         axi_awuser_ap  ;
    wire [  3:0] axi_awuser_id  ;
    wire [  3:0] axi_awlen      ;
    wire         axi_awready    ;
    wire         axi_awvalid    ;
    wire [255:0] axi_wdata      ;
    wire [ 31:0] axi_wstrb      ;
    wire         axi_wready     ;
    wire [  3:0] axi_wusero_id  ;
    wire         axi_wusero_last;
    wire [ 27:0] axi_araddr     ;
    wire         axi_aruser_ap  ;
    wire [  3:0] axi_aruser_id  ;
    wire [  3:0] axi_arlen      ;
    wire         axi_arready    ;
    wire         axi_arvalid    ;
    wire [255:0] axi_rdata      ;
    wire [  3:0] axi_rid        ;
    wire         axi_rlast      ;
    wire         axi_rvalid     ;

    ddr3_32 u_ddr3_32 (
        .clk            (clk            ),
        .rstn           (rstn           ),
        .inited         (ddr_inited     ),
        .phy_clk        (ddr_clk        ),
        .phy_clkl       (ddr_clkl       ),
        // AXI
        .axi_awaddr     (axi_awaddr     ),
        .axi_awuser_ap  (axi_awuser_ap  ),
        .axi_awuser_id  (axi_awuser_id  ),
        .axi_awlen      (axi_awlen      ),
        .axi_awready    (axi_awready    ),
        .axi_awvalid    (axi_awvalid    ),
        .axi_wdata      (axi_wdata      ),
        .axi_wstrb      (axi_wstrb      ),
        .axi_wready     (axi_wready     ),
        .axi_wusero_id  (axi_wusero_id  ),
        .axi_wusero_last(axi_wusero_last),
        .axi_araddr     (axi_araddr     ),
        .axi_aruser_ap  (axi_aruser_ap  ),
        .axi_aruser_id  (axi_aruser_id  ),
        .axi_arlen      (axi_arlen      ),
        .axi_arready    (axi_arready    ),
        .axi_arvalid    (axi_arvalid    ),
        .axi_rdata      (axi_rdata      ),
        .axi_rid        (axi_rid        ),
        .axi_rlast      (axi_rlast      ),
        .axi_rvalid     (axi_rvalid     ),
        // MEM
        .mem_rst_n      (mem_rst_n      ),
        .mem_ck         (mem_ck         ),
        .mem_ck_n       (mem_ck_n       ),
        .mem_cke        (mem_cke        ),
        .mem_cs_n       (mem_cs_n       ),
        .mem_ras_n      (mem_ras_n      ),
        .mem_cas_n      (mem_cas_n      ),
        .mem_we_n       (mem_we_n       ),
        .mem_odt        (mem_odt        ),
        .mem_a          (mem_a          ),
        .mem_ba         (mem_ba         ),
        .mem_dqs        (mem_dqs        ),
        .mem_dqs_n      (mem_dqs_n      ),
        .mem_dq         (mem_dq         ),
        .mem_dm         (mem_dm         )
    );

endmodule : AimBot
