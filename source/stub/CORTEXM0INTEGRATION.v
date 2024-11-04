module CORTEXM0INTEGRATION (
     input  wire        FCLK,
     input  wire        SCLK,
     input  wire        HCLK,
     input  wire        DCLK,
     input  wire        PORESETn,
     input  wire        DBGRESETn,
     input  wire        HRESETn,
     input  wire        SWCLKTCK,
     input  wire        nTRST,

     // AHB-LITE MASTER PORT
     output wire [31:0] HADDR,
     output wire [ 2:0] HBURST,
     output wire        HMASTLOCK,
     output wire [ 3:0] HPROT,
     output wire [ 2:0] HSIZE,
     output wire [ 1:0] HTRANS,
     output wire [31:0] HWDATA,
     output wire        HWRITE,
     input  wire [31:0] HRDATA,
     input  wire        HREADY,
     input  wire        HRESP,
     output wire        HMASTER,

     // CODE SEQUENTIALITY AND SPECULATION
     output wire        CODENSEQ,
     output wire [ 2:0] CODEHINTDE,
     output wire        SPECHTRANS,

     // DEBUG
     input  wire        SWDITMS,
     input  wire        TDI,
     output wire        SWDO,
     output wire        SWDOEN,
     output wire        TDO,
     output wire        nTDOEN,
     input  wire        DBGRESTART,
     output wire        DBGRESTARTED,
     input  wire        EDBGRQ,
     output wire        HALTED,

     // MISC
     input  wire        NMI,
     input  wire [31:0] IRQ,
     output wire        TXEV,
     input  wire        RXEV,
     output wire        LOCKUP,
     output wire        SYSRESETREQ,
     input  wire [25:0] STCALIB,
     input  wire        STCLKEN,
     input  wire [ 7:0] IRQLATENCY,
     input  wire [27:0] ECOREVNUM,    // [27:20] to DAP, [19:0] to core

     // POWER MANAGEMENT
     output wire        GATEHCLK,
     output wire        SLEEPING,
     output wire        SLEEPDEEP,
     output wire        WAKEUP,
     output wire [33:0] WICSENSE,
     input  wire        SLEEPHOLDREQn,
     output wire        SLEEPHOLDACKn,
     input  wire        WICENREQ,
     output wire        WICENACK,
     output wire        CDBGPWRUPREQ,
     input  wire        CDBGPWRUPACK,

     // SCAN IO
     input  wire        SE,
     input  wire        RSTBYPASS
);

endmodule
