//------------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2004-2017 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//  Revision            : $Revision: 365823 $
//  Release information : CM3DesignStart-r0p0-02rel0
//
//------------------------------------------------------------------------------
// Purpose: CORTEX-M3 DesignStart Integration Level
//------------------------------------------------------------------------------

// This wrapper instantiates the obfuscated code of the CortexM3.
// Therefore there cannot be any parameter inputs as the design instantiated is static

module CORTEXM3INTEGRATIONDS
  (
   // Inputs
   ISOLATEn, RETAINn, nTRST, SWCLKTCK, SWDITMS, TDI, PORESETn, SYSRESETn,
   RSTBYPASS, CGBYPASS, FCLK, HCLK, TRACECLKIN, STCLK, STCALIB, AUXFAULT, BIGEND,
   INTISR, INTNMI, HREADYI, HRDATAI, HRESPI, IFLUSH, HREADYD, HRDATAD, HRESPD,
   EXRESPD, SE, HREADYS, HRDATAS, HRESPS, EXRESPS, EDBGRQ, DBGRESTART, RXEV,
   SLEEPHOLDREQn, WICENREQ, FIXMASTERTYPE, TSVALUEB, MPUDISABLE,
   DBGEN, NIDEN, CDBGPWRUPACK, DNOTITRANS,
   // Outputs
   TDO, nTDOEN, SWDOEN, SWDO, SWV, JTAGNSW, TRACECLK, TRACEDATA, HTRANSI,
   HSIZEI, HADDRI, HBURSTI, HPROTI, MEMATTRI, HTRANSD, HSIZED, HADDRD, HBURSTD,
   HPROTD, MEMATTRD, HMASTERD, EXREQD, HWRITED, HWDATAD, HTRANSS, HSIZES,
   HADDRS, HBURSTS, HPROTS, MEMATTRS, HMASTERS, EXREQS, HWRITES, HWDATAS,
   HMASTLOCKS, BRCHSTAT, HALTED, LOCKUP, SLEEPING, SLEEPDEEP, ETMINTNUM,
   ETMINTSTAT, SYSRESETREQ, TXEV, TRCENA, CURRPRI, DBGRESTARTED, SLEEPHOLDACKn,
   GATEHCLK, HTMDHADDR, HTMDHTRANS, HTMDHSIZE, HTMDHBURST,
   HTMDHPROT, HTMDHWDATA, HTMDHWRITE, HTMDHRDATA, HTMDHREADY, HTMDHRESP,
   WICENACK, WAKEUP, CDBGPWRUPREQ
  );



  //----------------------------------------------------------------------------
  // Port declarations
  //----------------------------------------------------------------------------

  // PMU
  input          ISOLATEn;           // Isolate core power domain
  input          RETAINn;            // Retain core state during power-down

  // Debug
  input          nTRST;              // Test reset
  input          SWDITMS;            // Test Mode Select/SWDIN
  input          SWCLKTCK;           // Test clock / SWCLK
  input          TDI;                // Test Data In
  input          CDBGPWRUPACK;       // Debug power up acknowledge

  // Miscellaneous
  input          PORESETn;           // PowerOn reset
  input          SYSRESETn;          // System reset
  input          RSTBYPASS;          // Reset Bypass
  input          CGBYPASS;           // Architectural clock gate bypass
  input          FCLK;               // Free running clock
  input          HCLK;               // System clock
  input          TRACECLKIN;         // TPIU trace port clock
  input          STCLK;              // System Tick clock
  input   [25:0] STCALIB;            // System Tick calibration
  input   [31:0] AUXFAULT;           // Auxillary FSR pulse inputs
  input          BIGEND;             // Static endianess select

  // Interrupt
  input  [239:0] INTISR;             // Interrupts
  input          INTNMI;             // Non-maskable Interrupt

  // Code (instruction & literal) bus
  input          HREADYI;            // ICode-bus ready
  input   [31:0] HRDATAI;            // ICode-bus read data
  input    [1:0] HRESPI;             // ICode-bus transfer response
  input          IFLUSH;             // ICode-bus buffer flush
  input          HREADYD;            // DCode-bus ready
  input   [31:0] HRDATAD;            // DCode-bus read data
  input    [1:0] HRESPD;             // DCode-bus transfer response
  input          EXRESPD;            // DCode-bus exclusive response

  // System Bus
  input          HREADYS;            // System-bus ready
  input   [31:0] HRDATAS;            // System-bus read data
  input    [1:0] HRESPS;             // System-bus transfer response
  input          EXRESPS;            // System-bus exclusive response

  // Sleep
  input          RXEV;               // Wait for exception input
  input          SLEEPHOLDREQn;      // Hold core in sleep mode

  // External Debug Request
  input          EDBGRQ;             // Debug Request
  input          DBGRESTART;         // External Debug Restart request

  // DAP HMASTER override
  input          FIXMASTERTYPE;      // Override HMASTER for AHB-AP accesses

  // WIC
  input          WICENREQ;           // WIC mode Request from PMU

  // Timestamp intereace
  input [47:0]   TSVALUEB;           // Binary coded timestamp value

  // Scan
  input          SE;                 // Scan Enable

  // Logic disable
  input          MPUDISABLE;         // Disable the MPU (act as default)
  input          DBGEN;              // Enable debug
  input          NIDEN;              // Enable non-invasive debug

  // Added for DesignStart
  // Tie-High if code mux is used
  input          DNOTITRANS;         // I/DCode arbitration control

  // Debug
  output         TDO;                // Test Data Out
  output         nTDOEN;             // Test Data Out Enable
  output         CDBGPWRUPREQ;       // Debug power up request

  // Single Wire
  output         SWDO;               // SingleWire data out
  output         SWDOEN;             // SingleWire output enable
  output         JTAGNSW;            // JTAG mode(1) or SW mode(0)

  // Single Wire Viewer
  output         SWV;                // SingleWire Viewer Data

  // TracePort Output
  output         TRACECLK;           // TracePort clock reference
  output   [3:0] TRACEDATA;          // TracePort Data

  // HTM data
  output  [31:0] HTMDHADDR;          // HTM data HADDR
  output   [1:0] HTMDHTRANS;         // HTM data HTRANS
  output   [2:0] HTMDHSIZE;          // HTM data HSIZE
  output   [2:0] HTMDHBURST;         // HTM data HBURST
  output   [3:0] HTMDHPROT;          // HTM data HPROT
  output  [31:0] HTMDHWDATA;         // HTM data HWDATA
  output         HTMDHWRITE;         // HTM data HWRITE
  output  [31:0] HTMDHRDATA;         // HTM data HRDATA
  output         HTMDHREADY;         // HTM data HREADY
  output   [1:0] HTMDHRESP;          // HTM data HRESP

  // Code (instruction & literal) bus
  output   [1:0] HTRANSI;            // ICode-bus transfer type
  output   [2:0] HSIZEI;             // ICode-bus transfer size
  output  [31:0] HADDRI;             // ICode-bus address
  output   [2:0] HBURSTI;            // ICode-bus burst length
  output   [3:0] HPROTI;             // ICode-bus protection
  output   [1:0] MEMATTRI;           // ICode-bus memory attributes
  output   [1:0] HMASTERD;           // DCode-bus master
  output   [1:0] HTRANSD;            // DCode-bus transfer type
  output   [2:0] HSIZED;             // DCode-bus transfer size
  output  [31:0] HADDRD;             // DCode-bus address
  output   [2:0] HBURSTD;            // DCode-bus burst length
  output   [3:0] HPROTD;             // DCode-bus protection
  output   [1:0] MEMATTRD;           // ICode-bus memory attributes
  output         EXREQD;             // ICode-bus exclusive request
  output         HWRITED;            // DCode-bus write not read
  output  [31:0] HWDATAD;            // DCode-bus write data

  // System Bus
  output   [1:0] HMASTERS;           // System-bus master
  output   [1:0] HTRANSS;            // System-bus transfer type
  output         HWRITES;            // System-bus write not read
  output   [2:0] HSIZES;             // System-bus transfer size
  output         HMASTLOCKS;         // System-bus lock
  output  [31:0] HADDRS;             // System-bus address
  output  [31:0] HWDATAS;            // System-bus write data
  output   [2:0] HBURSTS;            // System-bus burst length
  output   [3:0] HPROTS;             // System-bus protection
  output   [1:0] MEMATTRS;           // System-bus memory attributes
  output         EXREQS;             // System-bus exclusive request

  // Core Status
  output   [3:0] BRCHSTAT;           // Branch status
  output         HALTED;             // Core is halted via debug
  output         DBGRESTARTED;       // External Debug Restart Ready
  output         LOCKUP;             // Lockup indication
  output         SLEEPING;           // Core is sleeping
  output         SLEEPDEEP;          // System can enter deep sleep
  output         SLEEPHOLDACKn;      // Indicate core is force in sleep mode
  output   [8:0] ETMINTNUM;          // Interrupt that is currently active
  output   [2:0] ETMINTSTAT;         // Interrupt activation status
  output         TRCENA;             // Trace Enable
  output   [7:0] CURRPRI;            // Current Int Priority

  // Reset request
  output         SYSRESETREQ;        // System reset request

  // Events
  output         TXEV;               // Event output

  // Clock gating control
  output         GATEHCLK;           // when high, HCLK can be turned off

  // WIC
  output         WICENACK;           // WIC mode acknowledge from WIC
  output         WAKEUP;             // Wake-up request from WIC


endmodule
