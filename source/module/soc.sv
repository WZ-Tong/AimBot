module soc (
    input clk  ,
    input rstn /*synthesis PAP_MARK_DEBUG="true"*/,
    input swclk,
    inout swdio
);

    // TODO: Replace with pll
    assign soc_clk = clk;

    wire        hrstn    ;
    wire [31:0] haddr    ;
    wire [ 2:0] hburst   ;
    wire        hmastlock;
    wire [ 3:0] hprot    ;
    wire [ 2:0] hsize    ;
    wire [ 1:0] htrans   ;
    wire [31:0] hwdata   ;
    wire        hwrite   ;
    wire [31:0] hrdata   ;
    wire        hready   ;
    wire        hresp    ;
    wire        hmaster  ;

    cortex_m0 u_cortex_m0 (
        .clk      (soc_clk  ),
        .rstn     (rstn     ),
        .hrstn    (hrstn    ),
        .swclk    (swclk    ),
        .swdio    (swdio    ),
        .haddr    (haddr    ),
        .hburst   (hburst   ),
        .hmastlock(hmastlock),
        .hprot    (hprot    ),
        .hsize    (hsize    ),
        .htrans   (htrans   ),
        .hwdata   (hwdata   ),
        .hwrite   (hwrite   ),
        .hrdata   (hrdata   ),
        .hready   (hready   ),
        .hresp    (hresp    ),
        .hmaster  (hmaster  )
    );

    // Input from ITCM
    wire  [31:0] hrdatam0   ;
    wire         hreadyoutm0;
    wire         hrespm0    ;
    wire  [31:0] hruserm0   ;
    // Output to ITCM
    wire         hselm0     ;
    wire  [31:0] haddrm0    ;
    wire  [ 1:0] htransm0   ;
    wire         hwritem0   ;
    wire  [ 2:0] hsizem0    ;
    wire  [ 2:0] hburstm0   ;
    wire  [ 3:0] hprotm0    ;
    wire  [31:0] hwdatam0   ;
    wire         hmastlockm0;
    wire         hreadymuxm0;

    // Input from DTCM
    wire  [31:0] hrdatam1   ;
    wire         hreadyoutm1;
    wire         hrespm1    ;
    wire  [31:0] hruserm1   ;
    // Output to DTCM
    wire         hselm1     ;
    wire  [31:0] haddrm1    ;
    wire  [ 1:0] htransm1   ;
    wire         hwritem1   ;
    wire  [ 2:0] hsizem1    ;
    wire  [ 2:0] hburstm1   ;
    wire  [ 3:0] hprotm1    ;
    wire  [31:0] hwdatam1   ;
    wire         hmastlockm1;
    wire         hreadymuxm1;


    wire  [31:0] HRDATAM2   ;
    wire         HREADYOUTM2;
    wire         HRESPM2    ;
    wire  [31:0] HRUSERM2   ;
    wire  [31:0] HRDATAM3   ;
    wire         HREADYOUTM3;
    wire         HRESPM3    ;
    wire  [31:0] HRUSERM3   ;
    wire  [31:0] HRDATAM4   ;
    wire         HREADYOUTM4;
    wire         HRESPM4    ;
    wire  [31:0] HRUSERM4   ;
    wire         HSELM2     ;
    wire  [31:0] HADDRM2    ;
    wire  [ 1:0] HTRANSM2   ;
    wire         HWRITEM2   ;
    wire  [ 2:0] HSIZEM2    ;
    wire  [ 2:0] HBURSTM2   ;
    wire  [ 3:0] HPROTM2    ;
    wire  [31:0] HWDATAM2   ;
    wire         HMASTLOCKM2;
    wire         HREADYMUXM2;

    wire         HSELM3     ;
    wire  [31:0] HADDRM3    ;
    wire  [ 1:0] HTRANSM3   ;
    wire         HWRITEM3   ;
    wire  [ 2:0] HSIZEM3    ;
    wire  [ 2:0] HBURSTM3   ;
    wire  [ 3:0] HPROTM3    ;
    wire  [31:0] HWDATAM3   ;
    wire         HMASTLOCKM3;
    wire         HREADYMUXM3;

    wire         HSELM4     ;
    wire  [31:0] HADDRM4    ;
    wire  [ 1:0] HTRANSM4   ;
    wire         HWRITEM4   ;
    wire  [ 2:0] HSIZEM4    ;
    wire  [ 2:0] HBURSTM4   ;
    wire  [ 3:0] HPROTM4    ;
    wire  [31:0] HWDATAM4   ;
    wire         HMASTLOCKM4;
    wire         HREADYMUXM4;

    ahb_bus_matrix_lite u_ahb_bus_matrix_lite (
        .HCLK       (soc_clk    ),
        .HRESETn    (hrstn      ),
        .REMAP      (4'b0       ),
        .HADDRS0    (haddr      ),
        .HTRANSS0   (htrans     ),
        .HWRITES0   (hwrite     ),
        .HSIZES0    (hsize      ),
        .HBURSTS0   (hburst     ),
        .HPROTS0    (hprot      ),
        .HWDATAS0   (hwdata     ),
        .HMASTLOCKS0(hmastlock  ),
        .HAUSERS0   (32'b0      ),
        .HWUSERS0   (32'b0      ),
        // Input from slave 0
        .HRDATAM0   (hrdatam0   ),
        .HREADYOUTM0(hreadyoutm0),
        .HRESPM0    (hrespm0    ),
        .HRUSERM0   (hruserm0   ),
        // Input from slave 1
        .HRDATAM1   (hrdatam1   ),
        .HREADYOUTM1(hreadyoutm1),
        .HRESPM1    (hrespm1    ),
        .HRUSERM1   (hruserm1   ),
        // Input from slave 2
        .HRDATAM2   (HRDATAM2   ),
        .HREADYOUTM2(HREADYOUTM2),
        .HRESPM2    (HRESPM2    ),
        .HRUSERM2   (HRUSERM2   ),
        // Input from slave 3
        .HRDATAM3   (HRDATAM3   ),
        .HREADYOUTM3(HREADYOUTM3),
        .HRESPM3    (HRESPM3    ),
        .HRUSERM3   (HRUSERM3   ),
        // Input from slave 4
        .HRDATAM4   (HRDATAM4   ),
        .HREADYOUTM4(HREADYOUTM4),
        .HRESPM4    (HRESPM4    ),
        .HRUSERM4   (HRUSERM4   ),
        // Output to slave 0
        .HSELM0     (hselm0     ),
        .HADDRM0    (haddrm0    ),
        .HTRANSM0   (htransm0   ),
        .HWRITEM0   (hwritem0   ),
        .HSIZEM0    (hsizem0    ),
        .HBURSTM0   (hburstm0   ),
        .HPROTM0    (hprotm0    ),
        .HWDATAM0   (hwdatam0   ),
        .HMASTLOCKM0(hmastlockm0),
        .HREADYMUXM0(hreadymuxm0),
        .HAUSERM0   (/*unused*/ ),
        .HWUSERM0   (/*unused*/ ),
        // Output to slave 1
        .HSELM1     (hselm1     ),
        .HADDRM1    (haddrm1    ),
        .HTRANSM1   (htransm1   ),
        .HWRITEM1   (hwritem1   ),
        .HSIZEM1    (hsizem1    ),
        .HBURSTM1   (hburstm1   ),
        .HPROTM1    (hprotm1    ),
        .HWDATAM1   (hwdatam1   ),
        .HMASTLOCKM1(hmastlockm1),
        .HREADYMUXM1(hreadymuxm1),
        .HAUSERM1   (/*unused*/ ),
        .HWUSERM1   (/*unused*/ ),
        // Output to slave 2
        .HSELM2     (HSELM2     ),
        .HADDRM2    (HADDRM2    ),
        .HTRANSM2   (HTRANSM2   ),
        .HWRITEM2   (HWRITEM2   ),
        .HSIZEM2    (HSIZEM2    ),
        .HBURSTM2   (HBURSTM2   ),
        .HPROTM2    (HPROTM2    ),
        .HWDATAM2   (HWDATAM2   ),
        .HMASTLOCKM2(HMASTLOCKM2),
        .HREADYMUXM2(HREADYMUXM2),
        .HAUSERM2   (/*unused*/ ),
        .HWUSERM2   (/*unused*/ ),
        // Output to slave 3
        .HSELM3     (HSELM3     ),
        .HADDRM3    (HADDRM3    ),
        .HTRANSM3   (HTRANSM3   ),
        .HWRITEM3   (HWRITEM3   ),
        .HSIZEM3    (HSIZEM3    ),
        .HBURSTM3   (HBURSTM3   ),
        .HPROTM3    (HPROTM3    ),
        .HWDATAM3   (HWDATAM3   ),
        .HMASTLOCKM3(HMASTLOCKM3),
        .HREADYMUXM3(HREADYMUXM3),
        .HAUSERM3   (/*unused*/ ),
        .HWUSERM3   (/*unused*/ ),
        // Output to slave 4
        .HSELM4     (HSELM4     ),
        .HADDRM4    (HADDRM4    ),
        .HTRANSM4   (HTRANSM4   ),
        .HWRITEM4   (HWRITEM4   ),
        .HSIZEM4    (HSIZEM4    ),
        .HBURSTM4   (HBURSTM4   ),
        .HPROTM4    (HPROTM4    ),
        .HWDATAM4   (HWDATAM4   ),
        .HMASTLOCKM4(HMASTLOCKM4),
        .HREADYMUXM4(HREADYMUXM4),
        .HAUSERM4   (/*unused*/ ),
        .HWUSERM4   (/*unused*/ ),
        // Output to master 0
        .HRDATAS0   (hrdata     ),
        .HREADYS0   (hready     ),
        .HRESPS0    (hresp      ),
        .HRUSERS0   (/*unused*/ ),
        // SCAN
        .SCANENABLE (1'b0       ),
        .SCANINHCLK (1'b0       ),
        .SCANOUTHCLK(/*unused*/ )
    );

    wire [31:0] itcm_rdata    /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [31:0] itcm_wdata    /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [03:0] itcm_write    /*synthesis PAP_MARK_DEBUG="true"*/;
    wire itcm_cs;
    wire [29:0] itcm_addr_full /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [13:0] itcm_addr;
    assign itcm_addr = itcm_addr_full[13:0];

    ahb_to_sram #(.AW(32)) u_ahb_itcm (
        .HCLK     (soc_clk       ),
        .HRESETn  (hrstn         ),
        // AHB
        .HSEL     (hselm0        ),
        .HREADY   (hreadym0      ),
        .HTRANS   (htransm0      ),
        .HSIZE    (hsizem0       ),
        .HWRITE   (hwritem0      ),
        .HADDR    (haddrm0       ),
        .HWDATA   (hwdatam0      ),
        .HREADYOUT(hreadyoutm0   ),
        .HRESP    (hrespm0       ),
        .HRDATA   (hrdatam0      ),
        // SRAM
        .SRAMRDATA(itcm_rdata    ),
        .SRAMADDR (itcm_addr_full),
        .SRAMWEN  (itcm_write    ),
        .SRAMWDATA(itcm_wdata    ),
        .SRAMCS   (itcm_cs       )
    );

    // AW:9, Addr: 512, 2KB
    itcm u_itcm (
        .clk       (clk                    ),
        .rst       (1'b0                   ),
        .addr      (itcm_addr              ),
        .wr_data   (itcm_wdata             ),
        .rd_data   (itcm_rdata             ),
        .wr_en     (1'b0                   ),
        .wr_byte_en(itcm_write&{4{itcm_cs}})
    );

    wire [31:0] dtcm_rdata    ;
    wire [31:0] dtcm_wdata    ;
    wire [03:0] dtcm_write    ;
    wire        dtcm_cs       ;
    wire [29:0] dtcm_addr_full;
    wire [12:0] dtcm_addr     ;
    assign dtcm_addr = dtcm_addr_full[12:0];

    ahb_to_sram #(.AW(32)) u_ahb_dtcm (
        .HCLK     (soc_clk       ),
        .HRESETn  (hrstn         ),
        // AHB
        .HSEL     (hselm1        ),
        .HREADY   (hreadym1      ),
        .HTRANS   (htransm1      ),
        .HSIZE    (hsizem1       ),
        .HWRITE   (hwritem1      ),
        .HADDR    (haddrm1       ),
        .HWDATA   (hwdatam1      ),
        .HREADYOUT(hreadyoutm1   ),
        .HRESP    (hrespm1       ),
        .HRDATA   (hrdatam1      ),
        // SRAM
        .SRAMRDATA(dtcm_rdata    ),
        .SRAMADDR (dtcm_addr_full),
        .SRAMWEN  (dtcm_write    ),
        .SRAMWDATA(dtcm_wdata    ),
        .SRAMCS   (dtcm_cs       )
    );

    dtcm u_dtcm (
        .clk       (clk                    ),
        .rst       (1'b0                   ),
        .addr      (dtcm_addr              ),
        .wr_data   (dtcm_wdata             ),
        .rd_data   (dtcm_rdata             ),
        .wr_en     (1'b0                   ),
        .wr_byte_en(dtcm_write&{4{itcm_cs}})
    );

endmodule : soc
