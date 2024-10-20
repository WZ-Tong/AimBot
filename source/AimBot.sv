`timescale 1ns / 1ps

module AimBot #(
    parameter V_BOX_WIDTH = 1'b1,
    parameter H_BOX_WIDTH = 1'b1,
    parameter N_BOX       = 1'b1
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

    wire clk10, clk25, clk37, clk150, clkl;
    pll u_pll (
        .pll_rst (~rstn ),
        .clkin1  (clk   ),
        .pll_lock(clkl  ),
        .clkout0 (clk37 ),
        .clkout1 (clk25 ),
        .clkout2 (clk10 ),
        .clkout3 (clk150)
    );
    assign hdmi_clk = clk37;

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
    wire cam1_inited, cam2_inited;

    wire cam1_pclk_565, cam2_pclk_565;
    wire        cam1_href_565, cam2_href_565 /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [15:0] cam1_data_565, cam2_data_565 /*synthesis PAP_MARK_DEBUG="true"*/;
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

    localparam V_FP   = 8     ;
    localparam THRESH = 1649*2;

    wire data_en;
    wire read_en /*synthesis PAP_MARK_DEBUG="true"*/;
    sync_gen #(
        .THRESH(THRESH          ),
        .DELAY (1649*V_FP-THRESH),
        .V_FP  (V_FP            ),
        .V_SYNC(2               ),
        .V_BP  (11             ),
        .H_FP  (182             ),
        .H_SYNC(5               ),
        .H_BP  (193             )
    ) u_sync_gen (
        .clk     (hdmi_clk     ),
        .rstn    (svg_rstn     ),
        .cam_href(cam1_href_565),
        .vsync   (hdmi_vsync   ),
        .hsync   (hdmi_hsync   ),
        .data_en (data_en      ),
        .read_en (read_en      )
    );
    assign hdmi_de = data_en;

    wire [15:0] comb_pix_1, comb_pix_2 /*synthesis PAP_MARK_DEBUG="true"*/;

    pixel_combine u_pixel_combine (
        .rclk    (hdmi_clk     ),
        .rstn    (rstn         ),
        .read_en (read_en      ),
        .pixel_1 (comb_pix_1   ),
        .pixel_2 (comb_pix_2   ),
        .error   (comb_err     ),
        // Cam 1
        .inited_1(cam1_inited  ),
        .pclk_1  (cam1_pclk_565),
        .href_1  (cam1_href    ),
        .data_1  (cam1_data_565),
        // Cam 2
        .inited_2(cam2_inited  ),
        .pclk_2  (cam2_pclk_565),
        .href_2  (cam2_href    ),
        .data_2  (cam2_data_565)
    );

    tick #(.TICK(((1280*720)/1280)*30), .DBG_CNT(10240)) u_buf_tick (
        .clk (hdmi_clk  ),
        .rstn(rstn      ),
        .trig(hdmi_vsync),
        .tick(buf_tick  )
    );

    assign hdmi_r = {comb_pix_1[15:11], 3'b0};
    assign hdmi_g = {comb_pix_1[10:05], 2'b0};
    assign hdmi_b = {comb_pix_1[04:00], 3'b0};

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
