

//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2019 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
//               
// Library:
// Filename:pll.v                 
//////////////////////////////////////////////////////////////////////////////

module pll (
    clkin1,
    clkout0,
    
    pll_lock
    );

    localparam real CLKIN_FREQ          = 50.0;
    localparam integer STATIC_RATIOI    = 2;
    localparam integer STATIC_RATIO0    = 25;
    localparam integer STATIC_RATIO1    = 16;
    localparam integer STATIC_RATIO2    = 16;
    localparam integer STATIC_RATIO3    = 16;
    localparam integer STATIC_RATIO4    = 16;
    localparam integer STATIC_RATIOF    = 42;
    localparam integer STATIC_DUTY0     = 25;
    localparam integer STATIC_DUTY1     = 16;
    localparam integer STATIC_DUTY2     = 16;
    localparam integer STATIC_DUTY3     = 16;
    localparam integer STATIC_DUTY4     = 16;
    localparam integer STATIC_DUTYF     = 42;
    localparam integer STATIC_PHASE0    = 16;
    localparam integer STATIC_PHASE1    = 16;
    localparam integer STATIC_PHASE2    = 16;
    localparam integer STATIC_PHASE3    = 16;
    localparam integer STATIC_PHASE4    = 16;
    localparam CLK_CAS1_EN              = "FALSE";
    localparam CLK_CAS2_EN              = "FALSE";
    localparam CLK_CAS3_EN              = "FALSE";
    localparam CLK_CAS4_EN              = "FALSE";
    localparam CLKIN_BYPASS_EN          = "FALSE";
    localparam CLKOUT0_GATE_EN          = "FALSE";
    localparam CLKOUT0_EXT_GATE_EN      = "FALSE";
    localparam CLKOUT1_GATE_EN          = "FALSE";
    localparam CLKOUT2_GATE_EN          = "FALSE";
    localparam CLKOUT3_GATE_EN          = "FALSE";
    localparam CLKOUT4_GATE_EN          = "FALSE";
    localparam FBMODE                   = "FALSE";
    localparam integer FBDIV_SEL        = 0;
    localparam BANDWIDTH                = "OPTIMIZED";
    localparam PFDEN_EN                 = "FALSE";
    localparam VCOCLK_DIV2              = 1'b0;
    localparam DYNAMIC_RATIOI_EN        = "FALSE";
    localparam DYNAMIC_RATIO0_EN        = "FALSE";
    localparam DYNAMIC_RATIO1_EN        = "FALSE";
    localparam DYNAMIC_RATIO2_EN        = "FALSE";
    localparam DYNAMIC_RATIO3_EN        = "FALSE";
    localparam DYNAMIC_RATIO4_EN        = "FALSE";
    localparam DYNAMIC_RATIOF_EN        = "FALSE";
    localparam DYNAMIC_DUTY0_EN         = "FALSE";
    localparam DYNAMIC_DUTY1_EN         = "FALSE";
    localparam DYNAMIC_DUTY2_EN         = "FALSE";
    localparam DYNAMIC_DUTY3_EN         = "FALSE";
    localparam DYNAMIC_DUTY4_EN         = "FALSE";
    localparam DYNAMIC_DUTYF_EN         = "FALSE";
    localparam PHASE_ADJUST0_EN         = "TRUE";
    localparam PHASE_ADJUST1_EN         = (CLK_CAS1_EN == "TRUE") ? "FALSE" : "TRUE";
    localparam PHASE_ADJUST2_EN         = (CLK_CAS2_EN == "TRUE") ? "FALSE" : "TRUE";
    localparam PHASE_ADJUST3_EN         = (CLK_CAS3_EN == "TRUE") ? "FALSE" : "TRUE";
    localparam PHASE_ADJUST4_EN         = (CLK_CAS4_EN == "TRUE") ? "FALSE" : "TRUE";
    localparam DYNAMIC_PHASE0_EN        = "FALSE";
    localparam DYNAMIC_PHASE1_EN        = "FALSE";
    localparam DYNAMIC_PHASE2_EN        = "FALSE";
    localparam DYNAMIC_PHASE3_EN        = "FALSE";
    localparam DYNAMIC_PHASE4_EN        = "FALSE";
    localparam DYNAMIC_PHASEF_EN        = "FALSE";
    localparam integer STATIC_PHASEF    = 16;
    localparam CLK_CAS0_EN              = "FALSE";
    localparam integer CLKOUT5_SEL      = 0;
    localparam CLKOUT5_GATE_EN          = "FALSE";
    localparam INTERNAL_FB              = (FBMODE == "FALSE") ? "ENABLE":"DISABLE";
    localparam EXTERNAL_FB              = (FBMODE == "FALSE") ? "DISABLE":
                                          (FBDIV_SEL == 0)  ? "CLKOUT0":
                                          (FBDIV_SEL == 1)  ? "CLKOUT1":
                                          (FBDIV_SEL == 2)  ? "CLKOUT2":
                                          (FBDIV_SEL == 3)  ? "CLKOUT3":
                                          (FBDIV_SEL == 4)  ? "CLKOUT4":"DISABLE";
    localparam RSTODIV_ENABLE           = "FALSE";
    localparam integer STATIC_RATIOM    = 1;
    

    input clkin1;
    output clkout0;
    
    output pll_lock;

endmodule
