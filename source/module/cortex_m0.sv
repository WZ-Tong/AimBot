module cortex_m0 (
    input             clk      ,
    input             rstn     ,
    output reg        hrstn    ,
    input             swclk    ,
    inout             swdio    ,

    // AHB
    output     [31:0] haddr    ,
    output     [ 2:0] hburst   ,
    output            hmastlock,
    output     [ 3:0] hprot    ,
    output     [ 2:0] hsize    ,
    output     [ 1:0] htrans   ,
    output     [31:0] hwdata   ,
    output            hwrite   ,
    input      [31:0] hrdata   ,
    input             hready   ,
    input             hresp    ,
    output            hmaster
);

    wire sys_rst_req;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            hrstn <= #1 'b0;
        end else if (sys_rst_req) begin
            hrstn <= #1 'b0;
        end begin
            hrstn <= #1 'b1;
        end
    end

    wire c_dbg_pwr_up_req;
    reg  c_dbg_pwr_up_ack;
    always @(posedge clk or negedge rstn)begin
        if (~rstn) begin
            c_dbg_pwr_up_ack <= 1'b0;
        end else begin
            c_dbg_pwr_up_ack <= c_dbg_pwr_up_req;
        end
    end


    wire swdi   ;
    wire swdo   ;
    wire swdo_en;
    assign swdio = swdo_en ? swdo : 1'bz;
    assign swdi  = swdio;

    wire lockup/*synthesis PAP_MARK_DEBUG="true"*/;

    CORTEXM0INTEGRATION u_CORTEXM0INTEGRATION (
        .FCLK         (clk             ),
        .SCLK         (clk             ),
        .HCLK         (clk             ),
        .DCLK         (clk             ),
        .PORESETn     (rstn            ),
        .DBGRESETn    (rstn            ),
        .HRESETn      (hrstn           ),
        .SYSRESETREQ  (sys_rst_req     ),
        .nTRST        (1'b1            ),
        .RSTBYPASS    (1'b0            ),
        .SE           (1'b0            ),
        .SLEEPHOLDREQn(1'b1            ),
        .WICENREQ     (1'b0            ),
        // Interrupt
        .IRQ          (32'b0           ),
        .NMI          (1'b0            ),
        .IRQLATENCY   (8'h0            ),
        .ECOREVNUM    (28'h0           ),
        // AHB Bus
        .HADDR        (haddr           ),
        .HBURST       (hburst          ),
        .HMASTLOCK    (hmastlock       ),
        .HPROT        (hprot           ),
        .HSIZE        (hsize           ),
        .HTRANS       (htrans          ),
        .HWDATA       (hwdata          ),
        .HWRITE       (hwrite          ),
        .HRDATA       (hrdata          ),
        .HREADY       (hready          ),
        .HRESP        (hresp           ),
        .HMASTER      (hmaster         ),
        .CODENSEQ     (/*unused*/      ),
        .CODEHINTDE   (/*unused*/      ),
        .SPECHTRANS   (/*unused*/      ),
        .GATEHCLK     (/*unused*/      ),
        .SLEEPING     (/*unused*/      ),
        .SLEEPDEEP    (/*unused*/      ),
        .WAKEUP       (/*unused*/      ),
        .WICSENSE     (/*unused*/      ),
        .WICENACK     (/*unused*/      ),
        .SLEEPHOLDACKn(/*unused*/      ),
        .CDBGPWRUPREQ (c_dbg_pwr_up_req),
        .CDBGPWRUPACK (c_dbg_pwr_up_ack),
        .SWCLKTCK     (swclk           ),
        .SWDITMS      (swdi            ),
        .SWDO         (swdo            ),
        .SWDOEN       (swdo_en         ),
        .DBGRESTART   (1'b0            ),
        .DBGRESTARTED (/*unused*/      ),
        .EDBGRQ       (1'b0            ),
        .TDO          (/*unused*/      ),
        .nTDOEN       (/*unused*/      ),
        .TDI          (1'b0            ),
        .HALTED       (/*unused*/      ),
        .TXEV         (/*unused*/      ),
        .RXEV         (/*unused*/      ),
        .LOCKUP       (lockup          ),
        .STCLKEN      (1'b1            ),
        .STCALIB      (26'h0           )
    );

endmodule : cortex_m0
