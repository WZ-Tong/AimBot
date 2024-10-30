`timescale 1ns / 1ps

module AimBot #(
    parameter  N_BOX          = 1                                                        ,

    parameter  LOCAL_MAC      = 48'h01_02_03_04_05_06                                    ,
    parameter  LOCAL_IP       = 32'hC0_A8_02_65                                          ,
    parameter  LOCAL_PORT     = 16'h1F90                                                 ,
    parameter  DEST_IP        = 32'hC0_A8_02_64                                          ,
    parameter  DEST_PORT      = 16'h1F90                                                 ,

    localparam H_ACT          = 1280                                                     ,
    localparam V_ACT          = 720                                                      ,
    localparam WB_INIT_HOLD   = 500_000_000                                              ,
    localparam KEY_HOLD       = 50_000_000                                               ,

    localparam DDR_DATA_WIDTH = 16                                                       ,
    localparam DDR_DM_WIDTH   = DDR_DATA_WIDTH==16 ? 2 : (DDR_DATA_WIDTH==32 ? 4 : 0)    ,
    localparam DDR_DQ_WIDTH   = DDR_DATA_WIDTH==16 ? 2 : (DDR_DATA_WIDTH==32 ? 4 : 0)    ,
    localparam DDR_DATA_LEN   = DDR_DATA_WIDTH==16 ? 128 : (DDR_DATA_WIDTH==32 ? 256 : 0)
) (
    input                       clk          ,
    input                       rstn         ,
    input                       cam_key      ,
    input                       wb_key       ,
    input                       dw_key       ,
    input                       send_switch  ,
    input                       wb_rstn      ,

    inout                       cam1_scl     ,
    inout                       cam1_sda     ,
    input                       cam1_vsync   ,
    input                       cam1_href    ,
    input                       cam1_pclk    ,
    input  [               7:0] cam1_data    ,
    output                      cam1_rstn    ,

    inout                       cam2_scl     ,
    inout                       cam2_sda     ,
    input                       cam2_vsync   ,
    input                       cam2_href    ,
    input                       cam2_pclk    ,
    input  [               7:0] cam2_data    ,
    output                      cam2_rstn    ,

    output                      hdmi_clk     ,
    output                      hdmi_hsync   ,
    output                      hdmi_vsync   ,
    output                      hdmi_de      ,
    output [               7:0] hdmi_r       ,
    output [               7:0] hdmi_g       ,
    output [               7:0] hdmi_b       ,

    output                      hdmi_rstn    ,
    output                      hdmi_scl     ,
    inout                       hdmi_sda     ,

    input                       rgmii1_rxc   ,
    input                       rgmii1_rx_ctl,
    input  [               3:0] rgmii1_rxd   ,

    output                      rgmii1_txc   ,
    output                      rgmii1_tx_ctl,
    output [               3:0] rgmii1_txd   ,

    // DDR
    output                      mem_rst_n    ,
    output                      mem_ck       ,
    output                      mem_ck_n     ,
    output                      mem_cke      ,
    output                      mem_cs_n     ,
    output                      mem_ras_n    ,
    output                      mem_cas_n    ,
    output                      mem_we_n     ,
    output                      mem_odt      ,
    output [              14:0] mem_a        ,
    output [               2:0] mem_ba       ,
    inout  [  DDR_DQ_WIDTH-1:0] mem_dqs      ,
    inout  [  DDR_DQ_WIDTH-1:0] mem_dqs_n    ,
    inout  [DDR_DATA_WIDTH-1:0] mem_dq       ,
    output [  DDR_DM_WIDTH-1:0] mem_dm       ,

    // Debug signals
    output                      io_init      ,
    output                      net_conn     ,
    output                      cam_tick     ,
    output                      line_err     ,
    output                      udp_fill
);

    aim_bot_pl #(
        .N_BOX         (N_BOX         ),
        .LOCAL_MAC     (LOCAL_MAC     ),
        .LOCAL_IP      (LOCAL_IP      ),
        .LOCAL_PORT    (LOCAL_PORT    ),
        .DEST_IP       (DEST_IP       ),
        .DEST_PORT     (DEST_PORT     ),
        .H_ACT         (H_ACT         ),
        .V_ACT         (V_ACT         ),
        .WB_INIT_HOLD  (WB_INIT_HOLD  ),
        .KEY_HOLD      (KEY_HOLD      ),
        .DDR_DATA_WIDTH(DDR_DATA_WIDTH),
        .DDR_DM_WIDTH  (DDR_DM_WIDTH  ),
        .DDR_DQ_WIDTH  (DDR_DQ_WIDTH  ),
        .DDR_DATA_LEN  (DDR_DATA_LEN  )
    ) u_pl (
        .clk          (clk          ),
        .rstn         (rstn         ),
        .cam_key      (cam_key      ),
        .wb_key       (wb_key       ),
        .dw_key       (dw_key       ),
        .send_switch  (send_switch  ),
        .wb_rstn      (wb_rstn      ),
        .cam1_scl     (cam1_scl     ),
        .cam1_sda     (cam1_sda     ),
        .cam1_vsync   (cam1_vsync   ),
        .cam1_href    (cam1_href    ),
        .cam1_pclk    (cam1_pclk    ),
        .cam1_data    (cam1_data    ),
        .cam1_rstn    (cam1_rstn    ),
        .cam2_scl     (cam2_scl     ),
        .cam2_sda     (cam2_sda     ),
        .cam2_vsync   (cam2_vsync   ),
        .cam2_href    (cam2_href    ),
        .cam2_pclk    (cam2_pclk    ),
        .cam2_data    (cam2_data    ),
        .cam2_rstn    (cam2_rstn    ),
        .hdmi_clk     (hdmi_clk     ),
        .hdmi_hsync   (hdmi_hsync   ),
        .hdmi_vsync   (hdmi_vsync   ),
        .hdmi_de      (hdmi_de      ),
        .hdmi_r       (hdmi_r       ),
        .hdmi_g       (hdmi_g       ),
        .hdmi_b       (hdmi_b       ),
        .hdmi_rstn    (hdmi_rstn    ),
        .hdmi_scl     (hdmi_scl     ),
        .hdmi_sda     (hdmi_sda     ),
        .rgmii1_rxc   (rgmii1_rxc   ),
        .rgmii1_rx_ctl(rgmii1_rx_ctl),
        .rgmii1_rxd   (rgmii1_rxd   ),
        .rgmii1_txc   (rgmii1_txc   ),
        .rgmii1_tx_ctl(rgmii1_tx_ctl),
        .rgmii1_txd   (rgmii1_txd   ),
        .mem_rst_n    (mem_rst_n    ),
        .mem_ck       (mem_ck       ),
        .mem_ck_n     (mem_ck_n     ),
        .mem_cke      (mem_cke      ),
        .mem_cs_n     (mem_cs_n     ),
        .mem_ras_n    (mem_ras_n    ),
        .mem_cas_n    (mem_cas_n    ),
        .mem_we_n     (mem_we_n     ),
        .mem_odt      (mem_odt      ),
        .mem_a        (mem_a        ),
        .mem_ba       (mem_ba       ),
        .mem_dqs      (mem_dqs      ),
        .mem_dqs_n    (mem_dqs_n    ),
        .mem_dq       (mem_dq       ),
        .mem_dm       (mem_dm       ),
        .line_err     (line_err     ),
        .udp_fill     (udp_fill     ),
        .net_conn     (net_conn     ),
        .cam_tick     (cam_tick     )
    );

    ddr3 #(.DATA_WIDTH(DDR_DATA_WIDTH)) u_ddr3 (
        .clk            (         ),
        .inited         (         ),
        .phy_clk        (         ),
        .phy_clkl       (         ),
        .axi_awaddr     (         ),
        .axi_awlen      (         ),
        .axi_awready    (         ),
        .axi_awvalid    (         ),
        .axi_wdata      (         ),
        .axi_wstrb      (         ),
        .axi_wready     (         ),
        .axi_wusero_last(         ),
        .axi_araddr     (         ),
        .axi_arlen      (         ),
        .axi_arready    (         ),
        .axi_arvalid    (         ),
        .axi_rdata      (         ),
        .axi_rid        (         ),
        .axi_rlast      (         ),
        .axi_rvalid     (         ),
        .mem_rst_n      (mem_rst_n),
        .mem_ck         (mem_ck   ),
        .mem_ck_n       (mem_ck_n ),
        .mem_cke        (mem_cke  ),
        .mem_cs_n       (mem_cs_n ),
        .mem_ras_n      (mem_ras_n),
        .mem_cas_n      (mem_cas_n),
        .mem_we_n       (mem_we_n ),
        .mem_odt        (mem_odt  ),
        .mem_a          (mem_a    ),
        .mem_ba         (mem_ba   ),
        .mem_dqs        (mem_dqs  ),
        .mem_dqs_n      (mem_dqs_n),
        .mem_dq         (mem_dq   ),
        .mem_dm         (mem_dm   )
    );

endmodule : AimBot
