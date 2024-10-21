module ddr3_32 (
    input          clk            ,
    input          rstn           ,
    output         inited         ,
    output         phy_clk        ,
    output         phy_clkl       ,

    input  [ 27:0] axi_awaddr     ,
    input  [  3:0] axi_awlen      ,
    output         axi_awready    ,
    input          axi_awvalid    ,

    input  [255:0] axi_wdata      ,
    input  [ 31:0] axi_wstrb      ,
    output         axi_wready     ,
    output         axi_wusero_last,

    input  [ 27:0] axi_araddr     ,
    input  [  3:0] axi_arlen      ,
    output         axi_arready    ,
    input          axi_arvalid    ,

    output [255:0] axi_rdata      ,
    output [  3:0] axi_rid        ,
    output         axi_rlast      ,
    output         axi_rvalid     ,

    output         mem_rst_n      ,
    output         mem_ck         ,
    output         mem_ck_n       ,
    output         mem_cke        ,
    output         mem_cs_n       ,
    output         mem_ras_n      ,
    output         mem_cas_n      ,
    output         mem_we_n       ,
    output         mem_odt        ,

    output [ 14:0] mem_a          ,
    output [  2:0] mem_ba         ,
    inout  [  3:0] mem_dqs        ,
    inout  [  3:0] mem_dqs_n      ,
    inout  [ 31:0] mem_dq         ,
    output [  3:0] mem_dm
);

    localparam DDR3_RSTN_HOLD_CNT = 50000;

    wire ddr3_rstn;
    rstn_gen #(.TICK(DDR3_RSTN_HOLD_CNT)) u_ddr3_rstn_gen (
        .clk   (clk      ),
        .i_rstn(rstn     ),
        .o_rstn(ddr3_rstn)
    );

    DDR3_50H u_ddr3_intrinsic (
        .ref_clk                (clk            ),
        .resetn                 (ddr3_rstn      ),
        .ddr_init_done          (inited         ),
        .ddrphy_clkin           (phy_clk        ),
        .pll_lock               (phy_clkl       ),
        // AXI
        .axi_awaddr             (axi_awaddr     ),
        .axi_awuser_ap          (1'b0           ),
        .axi_awuser_id          (4'b0000        ),
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
        .axi_aruser_id          (4'b0000        ),
        .axi_arlen              (axi_arlen      ),
        .axi_arready            (axi_arready    ),
        .axi_arvalid            (axi_arvalid    ),
        .axi_rdata              (axi_rdata      ),
        .axi_rid                (axi_rid        ),
        .axi_rlast              (axi_rlast      ),
        .axi_rvalid             (axi_rvalid     ),
        // MEM
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
        // APB
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

endmodule : ddr3_32
