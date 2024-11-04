module soc (
    input clk  ,
    input rstn ,
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

    wire       hselm0  ;
    wire       hreadym0;
    wire [1:0] htransm0;
    wire [2:0] hsizem0 ;
    wire       hwritem0;
    // wire [31:0] haddrm0    ;
    wire [31:0] hwdatam0   ;
    wire        hreadyoutm0;
    wire        hrespm0    ;
    wire [31:0] hrdatam0   ;

    wire [31:0] itcm_rdata;
    wire [31:0] itcm_wdata;
    wire [13:0] itcm_addr ;
    wire [03:0] itcm_write;
    wire        itcm_cs   ;

    ahb_to_sram #(.AW(16)) u_ahb_itcm (
        .HCLK     (soc_clk    ),
        .HRESETn  (hrstn      ),
        // AHB
        .HSEL     (hselm0     ),
        .HREADY   (hreadym0   ),
        .HTRANS   (htransm0   ),
        .HSIZE    (hsizem0    ),
        .HWRITE   (hwritem0   ),
        .HADDR    (/*haddrm0*/),
        .HWDATA   (hwdatam0   ),
        .HREADYOUT(hreadyoutm0),
        .HRESP    (hrespm0    ),
        .HRDATA   (hrdatam0   ),
        // SRAM
        .SRAMRDATA(itcm_rdata ),
        .SRAMADDR (itcm_addr  ),
        .SRAMWEN  (itcm_write ),
        .SRAMWDATA(itcm_wdata ),
        .SRAMCS   (itcm_cs    )
    );

    itcm u_itcm (
        .clk       (clk                    ),
        .rst       (1'b0                   ),
        .addr      (itcm_addr              ),
        .wr_data   (itcm_wdata             ),
        .rd_data   (itcm_rdata             ),
        .wr_en     (|itcm_write            ),
        .wr_byte_en(itcm_write&{4{itcm_cs}})
    );


endmodule : soc
