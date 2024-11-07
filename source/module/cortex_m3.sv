module cortex_m3 (
    input         clk         ,
    input         rstn        ,
    output        cpu_rstn    ,
    output        cpu_clk     ,
    input         swclk       ,
    inout         swdio       ,
    // CPU I-Code
    input         hreadyi     ,
    input  [31:0] hrdatai     ,
    input  [ 1:0] hrespi      ,
    output [31:0] haddri      ,
    output [ 1:0] htransi     ,
    output [ 2:0] hsizei      ,
    output [ 2:0] hbursti     ,
    output [ 3:0] hproti      ,
    // CPU D-Code
    input         hreadyd     ,
    input  [31:0] hrdatad     ,
    input  [ 1:0] hrespd      ,
    output [31:0] haddrd      ,
    output [ 1:0] htransd     ,
    output [ 2:0] hsized      ,
    output [ 2:0] hburstd     ,
    output [ 3:0] hprotd      ,
    output [31:0] hwdatad     ,
    output        hwrited     ,
    output [ 1:0] hmasterd    ,
    // CPU System bus
    input         hreadys     ,
    input  [31:0] hrdatas     ,
    input  [ 1:0] hresps      ,
    output [31:0] haddrs      ,
    output [ 1:0] htranss     ,
    output        hwrites     ,
    output [ 2:0] hsizes      ,
    output [31:0] hwdatas     ,
    output [ 2:0] hbursts     ,
    output [ 3:0] hprots      ,
    output [ 1:0] hmasters    ,
    output        hmasterlocks
);

    wire hclk, fclk;
    assign cpu_clk = clk;
    assign hclk    = cpu_clk;
    assign fclk    = cpu_clk;


    wire swdi, swdo_en, swdo;
    assign swdi  = swdio;
    assign swdio = swdo_en ? swdo : 1'bz;

    wire [239:0] irq;
    assign irq = 240'b0;

    wire cdbg_pwr_up_req;
    reg  cdbg_pwr_up_ack;
    always @(posedge cpu_clk or negedge rstn)begin
        if (~rstn) begin
            cdbg_pwr_up_ack <= 1'b0;
        end else begin
            cdbg_pwr_up_ack <= cdbg_pwr_up_req;
        end
    end

    wire cpu_rstn_req;
    reg cpu_rstn;
    always_ff @(posedge cpu_clk or negedge rstn) begin
        if(~rstn) begin
            cpu_rstn <= #1 'b0;
        end else if (cpu_rstn_req) begin
            cpu_rstn <= #1 'b0;
        end else begin
            cpu_rstn <= #1 'b1;
        end
    end

    CORTEXM3INTEGRATIONDS u_CORTEXM3INTEGRATIONDS (
        .ISOLATEn     (1'b1           ),
        .RETAINn      (1'b1           ),
        // Resets
        .PORESETn     (rstn           ),
        .SYSRESETn    (cpu_rstn       ),
        .SYSRESETREQ  (cpu_rstn_req   ),
        .RSTBYPASS    (1'b0           ),
        .CGBYPASS     (1'b0           ),
        .SE           (1'b0           ),
        // Clocks
        .FCLK         (fclk           ),
        .HCLK         (hclk           ),
        .TRACECLKIN   (1'b0           ),
        // SYSTICK
        .STCLK        (1'b0           ),
        .STCALIB      (26'b0          ),
        .AUXFAULT     (32'b0          ),
        // CONFIG - SYSTEM
        .BIGEND       (1'b0           ),
        .DNOTITRANS   (1'b1           ),
        // CONFIG - DEBUG
        .DBGEN        (1'b1           ),
        .NIDEN        (1'b1           ),
        .MPUDISABLE   (1'b0           ),
        // EXTERNAL DEBUG REQUEST
        .EDBGRQ       (1'b0           ),
        .DBGRESTART   (1'b0           ),
        // DAP HMASTER OVERRIDE
        .FIXMASTERTYPE(1'b0           ),
        // WIC
        .WICENREQ     (1'b0           ),
        // TIMESTAMP INTERFACE
        .TSVALUEB     (48'b0          ),
        .RXEV         (1'b0           ),
        .SLEEPHOLDREQn(1'b1           ),
        .SLEEPING     (/*unused*/     ),
        // I-CODE BUS
        .HREADYI      (hreadyi        ),
        .HRDATAI      (hrdatai        ),
        .HRESPI       (hrespi         ),
        .IFLUSH       (1'b0           ),
        .HADDRI       (haddri         ),
        .HTRANSI      (htransi        ),
        .HSIZEI       (hsizei         ),
        .HBURSTI      (hbursti        ),
        .HPROTI       (hproti         ),
        // D-CODE BUS
        .HREADYD      (hreadyd        ),
        .HRDATAD      (hrdatad        ),
        .HRESPD       (hrespd         ),
        .EXRESPD      (1'b0           ),
        .HADDRD       (haddrd         ),
        .HTRANSD      (htransd        ),
        .HSIZED       (hsized         ),
        .HBURSTD      (hburstd        ),
        .HPROTD       (hprotd         ),
        .HWDATAD      (hwdatad        ),
        .HWRITED      (hwrited        ),
        .HMASTERD     (hmasterd       ),
        // SYSTEM BUS
        .HREADYS      (hreadys        ),
        .HRDATAS      (hrdatas        ),
        .HRESPS       (hresps         ),
        .EXRESPS      (1'b0           ),
        .HADDRS       (haddrs         ),
        .HTRANSS      (htranss        ),
        .HSIZES       (hsizes         ),
        .HBURSTS      (hbursts        ),
        .HPROTS       (hprots         ),
        .HWDATAS      (hwdatas        ),
        .HWRITES      (hwrites        ),
        .HMASTERS     (hmasters       ),
        .HMASTLOCKS   (hmasterlocks   ),
        // SWJDAP
        .nTRST        (1'b1           ),
        .SWDITMS      (swdi           ),
        .SWCLKTCK     (swck           ),
        .TDI          (1'b0           ),
        .CDBGPWRUPACK (cdbg_pwr_up_ack),
        .CDBGPWRUPREQ (cdbg_pwr_up_req),
        .SWDO         (swdo           ),
        .SWDOEN       (swdo_en        ),
        // IRQS
        .INTISR       (irq            ),
        .INTNMI       (1'b0           ),
        // Unused
        .TDO          (/*unused*/     ),
        .nTDOEN       (/*unused*/     ),
        .JTAGNSW      (/*unused*/     ),
        .SWV          (/*unused*/     ),
        .TRACECLK     (/*unused*/     ),
        .TRACEDATA    (/*unused*/     ),
        .HTMDHADDR    (/*unused*/     ),
        .HTMDHTRANS   (/*unused*/     ),
        .HTMDHSIZE    (/*unused*/     ),
        .HTMDHBURST   (/*unused*/     ),
        .HTMDHPROT    (/*unused*/     ),
        .HTMDHWDATA   (/*unused*/     ),
        .HTMDHWRITE   (/*unused*/     ),
        .HTMDHRDATA   (/*unused*/     ),
        .HTMDHREADY   (/*unused*/     ),
        .HTMDHRESP    (/*unused*/     ),
        .MEMATTRI     (/*unused*/     ),
        .MEMATTRD     (/*unused*/     ),
        .EXREQD       (/*unused*/     ),
        .MEMATTRS     (/*unused*/     ),
        .EXREQS       (/*unused*/     ),
        .BRCHSTAT     (/*unused*/     ),
        .HALTED       (/*unused*/     ),
        .DBGRESTARTED (/*unused*/     ),
        .LOCKUP       (/*unused*/     ),
        .SLEEPDEEP    (/*unused*/     ),
        .SLEEPHOLDACKn(/*unused*/     ),
        .ETMINTNUM    (/*unused*/     ),
        .ETMINTSTAT   (/*unused*/     ),
        .TRCENA       (/*unused*/     ),
        .CURRPRI      (/*unused*/     ),
        .TXEV         (/*unused*/     ),
        .GATEHCLK     (/*unused*/     ),
        .WICENACK     (/*unused*/     ),
        .WAKEUP       (/*unused*/     )
    );

endmodule : cortex_m3
