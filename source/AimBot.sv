`timescale 1ns / 1ps

module AimBot #(
    parameter V_TOTAL            = 12'd750                                          ,
    parameter V_FP               = 12'd5                                            ,
    parameter V_BP               = 12'd20                                           ,
    parameter V_SYNC             = 12'd5                                            ,
    parameter V_ACT              = 12'd720                                          ,

    parameter H_TOTAL            = 12'd1650                                         ,
    parameter H_FP               = 12'd110                                          ,
    parameter H_BP               = 12'd220                                          ,
    parameter H_SYNC             = 12'd40                                           ,
    parameter H_ACT              = 12'd1280                                         ,

    parameter V_BOX_WIDTH        = 1'b1                                             ,
    parameter H_BOX_WIDTH        = 1'b1                                             ,

    parameter N_BOX              = 1'b1                                             ,

    parameter MEM_ROW_WIDTH      = 15                                               ,
    parameter MEM_COLUMN_WIDTH   = 10                                               ,
    parameter MEM_BANK_WIDTH     = 3                                                ,
    parameter MEM_DQ_WIDTH       = 32                                               ,
    parameter MEM_ROW_ADDR_WIDTH = 15                                               ,
    parameter MEM_COL_ADDR_WIDTH = 10                                               ,
    parameter MEM_BADDR_WIDTH    = 3                                                ,
    parameter MEM_DQS_WIDTH      = 32/8                                             ,
    parameter CTRL_ADDR_WIDTH    = MEM_ROW_WIDTH + MEM_BANK_WIDTH + MEM_COLUMN_WIDTH
) (
    input                           clk         ,
    input                           rstn        ,

    inout                           cam1_scl    ,
    inout                           cam1_sda    ,
    input                           cam1_vsync  ,
    input                           cam1_href   ,
    input                           cam1_pclk   ,
    input  [                   7:0] cam1_data   ,
    output                          cam1_rstn   ,

    inout                           cam2_scl    ,
    inout                           cam2_sda    ,
    input                           cam2_vsync  ,
    input                           cam2_href   ,
    input                           cam2_pclk   ,
    input  [                   7:0] cam2_data   ,
    output                          cam2_rstn   ,

    output                          hdmi_hsync  ,
    output                          hdmi_vsync  ,
    output                          hdmi_de     ,
    output [                   7:0] hdmi_r      ,
    output [                   7:0] hdmi_g      ,
    output [                   7:0] hdmi_b      ,

    // Ctrl signals
    output                          hdmi_rstn   ,
    output                          hdmi_scl    ,
    inout                           hdmi_sda    ,

    output                          mem_rst_n   ,
    output                          mem_ck      ,
    output                          mem_ck_n    ,
    output                          mem_cke     ,
    output                          mem_cs_n    ,
    output                          mem_ras_n   ,
    output                          mem_cas_n   ,
    output                          mem_we_n    ,
    output                          mem_odt     ,
    output [MEM_ROW_ADDR_WIDTH-1:0] mem_a       ,
    output [   MEM_BADDR_WIDTH-1:0] mem_ba      ,
    inout  [    MEM_DQ_WIDTH/8-1:0] mem_dqs     ,
    inout  [    MEM_DQ_WIDTH/8-1:0] mem_dqs_n   ,
    inout  [      MEM_DQ_WIDTH-1:0] mem_dq      ,
    output [    MEM_DQ_WIDTH/8-1:0] mem_dm      ,

    // Debug signals
    output                          hdmi_inited ,
    output                          cam1_inited ,
    output                          cam2_inited ,
    output                          cam1_tick   ,
    output                          cam2_tick   ,
    output                          ddr_inited  ,
    output                          fram_inited
);

    wire clk10, clk25, clkl;
    pll u_pll (
        .pll_rst (~rstn),
        .clkin1  (clk  ),
        .pll_lock(clkl ),
        .clkout0 (clk25),
        .clkout1 (clk10)
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


    localparam FRAME_BUF_H_NUM = 12'd1280;
    localparam FRAME_BUF_V_NUM = 12'd720 ;

    wire [ CTRL_ADDR_WIDTH-1:0] axi_awaddr     ;
    wire                        axi_awuser_ap  ;
    wire [                 3:0] axi_awuser_id  ;
    wire [                 3:0] axi_awlen      ;
    wire                        axi_awready    ;
    wire                        axi_awvalid    ;
    wire [  MEM_DQ_WIDTH*8-1:0] axi_wdata      ;
    wire [MEM_DQ_WIDTH*8/8-1:0] axi_wstrb      ;
    wire                        axi_wready     ;
    wire [                 3:0] axi_wusero_id  ;
    wire                        axi_wusero_last;
    wire [ CTRL_ADDR_WIDTH-1:0] axi_araddr     ;
    wire                        axi_aruser_ap  ;
    wire [                 3:0] axi_aruser_id  ;
    wire [                 3:0] axi_arlen      ;
    wire                        axi_arready    ;
    wire                        axi_arvalid    ;
    wire [  MEM_DQ_WIDTH*8-1:0] axi_rdata      ;
    wire                        axi_rvalid     ;
    wire [                 3:0] axi_rid        ;
    wire                        axi_rlast      ;

    localparam DDR3_RSTN_HOLD_CNT = 50000;

    wire ddr3_rstn;
    rstn_async_hold #(.TICK(DDR3_RSTN_HOLD_CNT)) u_ddr3_rstn (
        .clk   (clk      ),
        .i_rstn(rstn     ),
        .o_rstn(ddr3_rstn)
    );

    wire ddr_clk, ddr_clkl;
    DDR3_50H u_ddr3 (
        .ref_clk                (clk            ),
        .resetn                 (ddr3_rstn      ),
        .ddr_init_done          (ddr_inited     ),
        .ddrphy_clkin           (ddr_clk        ),
        .pll_lock               (/*unused*/     ),
        .axi_awaddr             (axi_awaddr     ),
        .axi_awuser_ap          (1'b0           ),
        .axi_awuser_id          (axi_awuser_id  ),
        .axi_awlen              (axi_awlen      ),
        .axi_awready            (axi_awready    ),
        .axi_awvalid            (axi_awvalid    ),
        .axi_wdata              (axi_wdata      ),
        .axi_wstrb              (axi_wstrb      ),
        .axi_wready             (axi_wready     ),
        .axi_wusero_id          (/*unused*/     ),
        .axi_wusero_last        (axi_wusero_last),
        .axi_araddr             (axi_araddr     ),
        .axi_aruser_ap          (1'b0           ),
        .axi_aruser_id          (axi_aruser_id  ),
        .axi_arlen              (axi_arlen      ),
        .axi_arready            (axi_arready    ),
        .axi_arvalid            (axi_arvalid    ),
        .axi_rdata              (axi_rdata      ),
        .axi_rid                (axi_rid        ),
        .axi_rlast              (axi_rlast      ),
        .axi_rvalid             (axi_rvalid     ),
        .apb_clk                (1'b0           ),
        .apb_rst_n              (1'b1           ),
        .apb_sel                (1'b0           ),
        .apb_enable             (1'b0           ),
        .apb_addr               (8'b0           ),
        .apb_write              (1'b0           ),
        .apb_ready              (/*unused*/     ),
        .apb_wdata              (16'b0          ),
        .apb_rdata              (/*unused*/     ),
        .apb_int                (/*unused*/     ),
        .mem_rst_n              (mem_rst_n      ),
        .mem_ck                 (mem_ck         ),
        .mem_ck_n               (mem_ck_n       ),
        .mem_cke                (mem_cke        ),
        .mem_cs_n               (mem_cs_n       ),
        .mem_ras_n              (mem_ras_n      ),
        .mem_cas_n              (mem_cas_n      ),
        .mem_we_n               (mem_we_n       ),
        .mem_odt                (mem_odt        ),
        .mem_a                  (mem_a          ),
        .mem_ba                 (mem_ba         ),
        .mem_dqs                (mem_dqs        ),
        .mem_dqs_n              (mem_dqs_n      ),
        .mem_dq                 (mem_dq         ),
        .mem_dm                 (mem_dm         ),
        //debug
        .debug_data             (/*unused*/     ),
        .debug_slice_state      (/*unused*/     ),
        .debug_calib_ctrl       (/*unused*/     ),
        .ck_dly_set_bin         (/*unused*/     ),
        .force_ck_dly_en        (1'b0           ),
        .force_ck_dly_set_bin   (8'h05          ),
        .dll_step               (/*unused*/     ),
        .dll_lock               (/*unused*/     ),
        .init_read_clk_ctrl     (2'b0           ),
        .init_slip_step         (4'b0           ),
        .force_read_clk_ctrl    (1'b0           ),
        .ddrphy_gate_update_en  (1'b0           ),
        .update_com_val_err_flag(/*unused*/     ),
        .rd_fake_stop           (1'b0           )
    );

    fram_buf #(.PIX_WIDTH(32)) u_fram_buf (
        .ddr_clk    (ddr_clk        ),
        .ddr_rstn   (ddr_inited     ),
        .vin_clk    (               ),   // TODO: OV5640
        .wr_fsync   (               ),   // TODO
        .wr_en      (               ),   // TODO
        .wr_data    (               ),   // TODO
        .vout_clk   (               ),   // TODO: HDMI
        .rd_fsync   (               ),   // TODO
        .rd_en      (               ),   // TODO
        .vout_de    (               ),   // TODO
        .vout_data  (               ),   // TODO
        .init_done  (fram_inited    ),
        .axi_awaddr (axi_awaddr     ),
        .axi_awid   (axi_awuser_id  ),
        .axi_awlen  (axi_awlen      ),
        .axi_awsize (/*unused*/     ),
        .axi_awburst(/*unused*/     ),
        .axi_awready(axi_awready    ),
        .axi_awvalid(axi_awvalid    ),
        .axi_wdata  (axi_wdata      ),
        .axi_wstrb  (axi_wstrb      ),
        .axi_wlast  (axi_wusero_last),
        .axi_wvalid (/*unused*/     ),
        .axi_wready (axi_wready     ),
        .axi_bid    (4'd0           ),
        .axi_araddr (axi_araddr     ),
        .axi_arid   (axi_aruser_id  ),
        .axi_arlen  (axi_arlen      ),
        .axi_arsize (/*unused*/     ),
        .axi_arburst(/*unused*/     ),
        .axi_arvalid(axi_arvalid    ),
        .axi_arready(axi_arready    ),
        .axi_rready (/*unused*/     ),
        .axi_rdata  (axi_rdata      ),
        .axi_rvalid (axi_rvalid     ),
        .axi_rlast  (axi_rlast      ),
        .axi_rid    (axi_rid        )
    );

    localparam DBG_CNT = 102400;

    logic [$clog2(DBG_CNT)-1:0] dbg1, dbg2;
    tick #(.TICK(1), .DBG_CNT(DBG_CNT)) u_cam1_cnt (
        .clk    (ddr_clk       ),
        .rstn   (rstn      ),
        .trig   (cam1_vsync),
        .tick   ( ),
        .dbg_cnt(dbg1      )
    );
    tick #(.TICK(1), .DBG_CNT(DBG_CNT)) u_cam2_cnt (
        .clk    (ddr_clk   ),
        .rstn   (rstn      ),
        .trig   (cam2_vsync),
        .tick   (          ),
        .dbg_cnt(dbg2      )
    );

endmodule : AimBot
