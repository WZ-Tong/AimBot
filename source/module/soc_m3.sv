module soc_m3 (
    input clk  ,
    input rstn   /*synthesis PAP_MARK_DEBUG="true"*/,
    input swclk,
    inout swdio
);

    wire cpu_rstn, cpu_clk;

    wire        hreadyi     ;
    wire [31:0] hrdatai     ;
    wire [ 1:0] hrespi      ;
    wire [31:0] haddri      ;
    wire [ 1:0] htransi     ;
    wire [ 2:0] hsizei      ;
    wire [ 2:0] hbursti     ;
    wire [ 3:0] hproti      ;
    wire        hreadyd     ;
    wire [31:0] hrdatad     ;
    wire [ 1:0] hrespd      ;
    wire [31:0] haddrd      ;
    wire [ 1:0] htransd     ;
    wire [ 2:0] hsized      ;
    wire [ 2:0] hburstd     ;
    wire [ 3:0] hprotd      ;
    wire [31:0] hwdatad     ;
    wire        hwrited     ;
    wire [ 1:0] hmasterd    ;
    wire        hreadys     ;
    wire [31:0] hrdatas     ;
    wire [ 1:0] hresps      ;
    wire [31:0] haddrs      ;
    wire [ 1:0] htranss     ;
    wire        hwrites     ;
    wire [ 2:0] hsizes      ;
    wire [31:0] hwdatas     ;
    wire [ 2:0] hbursts     ;
    wire [ 3:0] hprots      ;
    wire [ 1:0] hmasters    ;
    wire        hmasterlocks;

    cortex_m3 u_cortex_m3 (
        .clk         (clk         ),
        .rstn        (rstn        ),
        .cpu_rstn    (cpu_rstn    ),
        .cpu_clk     (cpu_clk     ),
        .swclk       (swclk       ),
        .swdio       (swdio       ),
        // ITCM
        .hreadyi     (hreadyi     ),
        .hrdatai     (hrdatai     ),
        .hrespi      (hrespi      ),
        .haddri      (haddri      ),
        .htransi     (htransi     ),
        .hsizei      (hsizei      ),
        .hbursti     (hbursti     ),
        .hproti      (hproti      ),
        // DTCM
        .hreadyd     (hreadyd     ),
        .hrdatad     (hrdatad     ),
        .hrespd      (hrespd      ),
        .haddrd      (haddrd      ),
        .htransd     (htransd     ),
        .hsized      (hsized      ),
        .hburstd     (hburstd     ),
        .hprotd      (hprotd      ),
        .hwdatad     (hwdatad     ),
        .hwrited     (hwrited     ),
        .hmasterd    (hmasterd    ),
        // System
        .hreadys     (hreadys     ),
        .hrdatas     (hrdatas     ),
        .hresps      (hresps      ),
        .haddrs      (haddrs      ),
        .htranss     (htranss     ),
        .hwrites     (hwrites     ),
        .hsizes      (hsizes      ),
        .hwdatas     (hwdatas     ),
        .hbursts     (hbursts     ),
        .hprots      (hprots      ),
        .hmasters    (hmasters    ),
        .hmasterlocks(hmasterlocks)
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

    // Stub
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


    wire [31:0] HADDRS0;
    wire [1:0] HTRANSS0;
    wire HWRITES0;
    wire [2:0] HSIZES0;
    wire [2:0] HBURSTS0;
    wire [3:0] HPROTS0;
    wire [31:0] HWDATAS0;
    wire HMASTLOCKS0;
    wire [31:0] HAUSERS0;
    wire [31:0] HWUSERS0;
    wire [31:0] HADDRS1;
    wire [1:0] HTRANSS1;
    wire HWRITES1;
    wire [2:0] HSIZES1;
    wire [2:0] HBURSTS1;
    wire [3:0] HPROTS1;
    wire [31:0] HWDATAS1;
    wire HMASTLOCKS1;
    wire [31:0] HAUSERS1;
    wire [31:0] HWUSERS1;
    wire [31:0] HADDRS2;
    wire [1:0] HTRANSS2;
    wire HWRITES2;
    wire [2:0] HSIZES2;
    wire [2:0] HBURSTS2;
    wire [3:0] HPROTS2;
    wire [31:0] HWDATAS2;
    wire HMASTLOCKS2;
    wire [31:0] HAUSERS2;
    wire [31:0] HWUSERS2;
    wire [31:0] HRDATAM0;
    wire HREADYOUTM0;
    wire HRESPM0;
    wire [31:0] HRUSERM0;
    wire [31:0] HRDATAM1;
    wire HREADYOUTM1;
    wire HRESPM1;
    wire [31:0] HRUSERM1;
    wire HSELM0;
    wire [31:0] HADDRM0;
    wire [1:0] HTRANSM0;
    wire HWRITEM0;
    wire [2:0] HSIZEM0;
    wire [2:0] HBURSTM0;
    wire [3:0] HPROTM0;
    wire [31:0] HWDATAM0;
    wire HMASTLOCKM0;
    wire HREADYMUXM0;
    wire [31:0] HAUSERM0;
    wire [31:0] HWUSERM0;
    wire HSELM1;
    wire [31:0] HADDRM1;
    wire [1:0] HTRANSM1;
    wire HWRITEM1;
    wire [2:0] HSIZEM1;
    wire [2:0] HBURSTM1;
    wire [3:0] HPROTM1;
    wire [31:0] HWDATAM1;
    wire HMASTLOCKM1;
    wire HREADYMUXM1;
    wire [31:0] HAUSERM1;
    wire [31:0] HWUSERM1;
    wire [31:0] HAUSERM2;
    wire [31:0] HWUSERM2;
    wire [31:0] HRDATAS0;
    wire HREADYS0;
    wire HRESPS0;
    wire [31:0] HRUSERS0;
    wire [31:0] HRDATAS1;
    wire HREADYS1;
    wire HRESPS1;
    wire [31:0] HRUSERS1;
    wire [31:0] HRDATAS2;
    wire HREADYS2;
    wire HRESPS2;
    wire [31:0] HRUSERS2;
    ahb_bus_matrix_lite u_ahb_bus_matrix_lite (
        .HCLK       (cpu_clk    ),
        .HRESETn    (cpu_rstn   ),
        .REMAP      (4'b0000    ),
        // Scan
        .SCANENABLE (1'b0       ),
        .SCANINHCLK (1'b0       ),
        .SCANOUTHCLK(/*unused*/ ),
        // S0: DTCM
        .HADDRS0    (HADDRS0    ),
        .HTRANSS0   (HTRANSS0   ),
        .HWRITES0   (HWRITES0   ),
        .HSIZES0    (HSIZES0    ),
        .HBURSTS0   (HBURSTS0   ),
        .HPROTS0    (HPROTS0    ),
        .HWDATAS0   (HWDATAS0   ),
        .HMASTLOCKS0(HMASTLOCKS0),
        .HAUSERS0   (HAUSERS0   ),
        .HWUSERS0   (HWUSERS0   ),
        .HRDATAS0   (HRDATAS0   ),
        .HREADYS0   (HREADYS0   ),
        .HRESPS0    (HRESPS0    ),
        .HRUSERS0   (HRUSERS0   ),
        // S1: ITCM
        .HADDRS1    (HADDRS1    ),
        .HTRANSS1   (HTRANSS1   ),
        .HWRITES1   (HWRITES1   ),
        .HSIZES1    (HSIZES1    ),
        .HBURSTS1   (HBURSTS1   ),
        .HPROTS1    (HPROTS1    ),
        .HWDATAS1   (HWDATAS1   ),
        .HMASTLOCKS1(HMASTLOCKS1),
        .HAUSERS1   (HAUSERS1   ),
        .HWUSERS1   (HWUSERS1   ),
        .HRDATAS1   (HRDATAS1   ),
        .HREADYS1   (HREADYS1   ),
        .HRESPS1    (HRESPS1    ),
        .HRUSERS1   (HRUSERS1   ),
        // S2: System Bus
        .HADDRS2    (HADDRS2    ),
        .HTRANSS2   (HTRANSS2   ),
        .HWRITES2   (HWRITES2   ),
        .HSIZES2    (HSIZES2    ),
        .HBURSTS2   (HBURSTS2   ),
        .HPROTS2    (HPROTS2    ),
        .HWDATAS2   (HWDATAS2   ),
        .HMASTLOCKS2(HMASTLOCKS2),
        .HAUSERS2   (HAUSERS2   ),
        .HWUSERS2   (HWUSERS2   ),
        .HRDATAM0   (HRDATAM0   ),
        .HREADYOUTM0(HREADYOUTM0),
        .HRESPM0    (HRESPM0    ),
        .HRUSERM0   (HRUSERM0   ),
        .HRDATAM1   (HRDATAM1   ),
        .HREADYOUTM1(HREADYOUTM1),
        .HRESPM1    (HRESPM1    ),
        .HRUSERM1   (HRUSERM1   ),
        .HRDATAM2   (HRDATAM2   ),
        .HREADYOUTM2(HREADYOUTM2),
        .HRESPM2    (HRESPM2    ),
        .HRUSERM2   (HRUSERM2   ),
        .HSELM0     (HSELM0     ),
        .HADDRM0    (HADDRM0    ),
        .HTRANSM0   (HTRANSM0   ),
        .HWRITEM0   (HWRITEM0   ),
        .HSIZEM0    (HSIZEM0    ),
        .HBURSTM0   (HBURSTM0   ),
        .HPROTM0    (HPROTM0    ),
        .HWDATAM0   (HWDATAM0   ),
        .HMASTLOCKM0(HMASTLOCKM0),
        .HREADYMUXM0(HREADYMUXM0),
        .HAUSERM0   (HAUSERM0   ),
        .HWUSERM0   (HWUSERM0   ),
        .HSELM1     (HSELM1     ),
        .HADDRM1    (HADDRM1    ),
        .HTRANSM1   (HTRANSM1   ),
        .HWRITEM1   (HWRITEM1   ),
        .HSIZEM1    (HSIZEM1    ),
        .HBURSTM1   (HBURSTM1   ),
        .HPROTM1    (HPROTM1    ),
        .HWDATAM1   (HWDATAM1   ),
        .HMASTLOCKM1(HMASTLOCKM1),
        .HREADYMUXM1(HREADYMUXM1),
        .HAUSERM1   (HAUSERM1   ),
        .HWUSERM1   (HWUSERM1   ),
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
        .HAUSERM2   (HAUSERM2   ),
        .HWUSERM2   (HWUSERM2   ),
        .HRDATAS2   (HRDATAS2   ),
        .HREADYS2   (HREADYS2   ),
        .HRESPS2    (HRESPS2    ),
        .HRUSERS2   (HRUSERS2   )
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


endmodule : soc_m3
