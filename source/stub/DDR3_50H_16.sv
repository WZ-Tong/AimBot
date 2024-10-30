module  DDR3_50H_16 #(

   parameter DFI_CLK_PERIOD       = 10000         ,

   parameter MEM_ROW_WIDTH   = 15         ,

   parameter MEM_COLUMN_WIDTH   = 10         ,

   parameter MEM_BANK_WIDTH      = 3          ,

  parameter MEM_DQ_WIDTH         =  16         ,

  parameter MEM_DM_WIDTH         =  2         ,

  parameter MEM_DQS_WIDTH        =  2         ,

  parameter REGION_NUM           =  3         ,

  parameter CTRL_ADDR_WIDTH      = MEM_ROW_WIDTH + MEM_COLUMN_WIDTH + MEM_BANK_WIDTH         
  )(
   input                              ref_clk        ,
   input                              resetn         ,
   output                             ddr_init_done  ,
   output                             ddrphy_clkin   ,
   output                             pll_lock       , 
 
   input [CTRL_ADDR_WIDTH-1:0]        axi_awaddr     ,
   input                              axi_awuser_ap  ,
   input [3:0]                        axi_awuser_id  ,
   input [3:0]                        axi_awlen      ,
   output                             axi_awready    ,
   input                              axi_awvalid    ,

   input [MEM_DQ_WIDTH*8-1:0]         axi_wdata      ,
   input [MEM_DQ_WIDTH-1:0]           axi_wstrb      ,
   output                             axi_wready     ,
   output [3:0]                       axi_wusero_id  ,
   output                             axi_wusero_last,

   input [CTRL_ADDR_WIDTH-1:0]        axi_araddr     ,
   input                              axi_aruser_ap  ,
   input [3:0]                        axi_aruser_id  ,
   input [3:0]                        axi_arlen      ,
   output                             axi_arready    ,
   input                              axi_arvalid    ,

   output[8*MEM_DQ_WIDTH-1:0]         axi_rdata      ,
   output[3:0]                        axi_rid        ,
   output                             axi_rlast      ,
   output                             axi_rvalid     ,

   input                              apb_clk        ,
   input                              apb_rst_n      ,
   input                              apb_sel        ,
   input                              apb_enable     ,
   input [7:0]                        apb_addr       ,
   input                              apb_write      ,
   output                             apb_ready      ,
   input [15:0]                       apb_wdata      ,
   output[15:0]                       apb_rdata      ,
   output                             apb_int        ,
   output [34*MEM_DQS_WIDTH -1:0]     debug_data           ,
   output [13*MEM_DQS_WIDTH -1:0]     debug_slice_state    ,
   output [21:0]                      debug_calib_ctrl     ,
   output [7:0]                       ck_dly_set_bin       ,
   input                              force_ck_dly_en      ,
   input [7:0]                        force_ck_dly_set_bin ,
   output [7:0]                       dll_step             ,    
   output                             dll_lock             ,
   input [1:0]                        init_read_clk_ctrl   ,                                                       
   input [3:0]                        init_slip_step       ,                                                
   input                              force_read_clk_ctrl  , 

   input                              ddrphy_gate_update_en,
   output [MEM_DQS_WIDTH-1:0]         update_com_val_err_flag,
   input                              rd_fake_stop         ,
   
   output                             mem_rst_n            ,                       
   output                             mem_ck               ,
   output                             mem_ck_n             ,
   output                             mem_cke              ,

   output                             mem_cs_n             ,

   output                             mem_ras_n            ,
   output                             mem_cas_n            ,
   output                             mem_we_n             , 
   output                             mem_odt              ,
   output [MEM_ROW_WIDTH-1:0]         mem_a                ,   
   output [MEM_BANK_WIDTH-1:0]        mem_ba               ,   
   inout [MEM_DQS_WIDTH-1:0]          mem_dqs              ,
   inout [MEM_DQS_WIDTH-1:0]          mem_dqs_n            ,
   inout [MEM_DQ_WIDTH-1:0]           mem_dq               ,
   output [MEM_DM_WIDTH-1:0]          mem_dm               
);

`ifdef SIMULATION                                                  
localparam T200US         = (200*1000*1000 / DFI_CLK_PERIOD) / 100;
`else                                                              
localparam T200US         = (200*1000*1000 / DFI_CLK_PERIOD);      
`endif

`ifdef SIMULATION                                                  
localparam T500US         = (500*1000*1000 / DFI_CLK_PERIOD) / 100;
`else                                                              
localparam T500US         = (500*1000*1000 / DFI_CLK_PERIOD);      
`endif

//MR0_DDR3
localparam [0:0] DDR3_PPD      = 1'b1;

localparam [2:0] DDR3_WR       =  3'd2;

localparam [0:0] DDR3_DLL      = 1'b1;
localparam [0:0] DDR3_TM       = 1'b0;
localparam [0:0] DDR3_RBT      = 1'b0;


localparam [3:0] DDR3_CL       = 4'd4;

    
localparam [1:0] DDR3_BL       = 2'b00;
localparam [15:0] MR0_DDR3     = {3'b000, DDR3_PPD, DDR3_WR, DDR3_DLL, DDR3_TM, DDR3_CL[3:1], DDR3_RBT, DDR3_CL[0], DDR3_BL};
//MR1_DDR3
localparam [0:0] DDR3_QOFF     = 1'b0;
localparam [0:0] DDR3_TDQS     = 1'b0;


localparam [2:0] DDR3_RTT_NOM  = 3'b001;
      

localparam [0:0] DDR3_LEVEL    = 1'b0;

localparam [1:0] DDR3_DIC      = 2'b00;

localparam [1:0] DDR3_AL       = 2'd2;
    
localparam [0:0] DDR3_DLL_EN   = 1'b0;
localparam [15:0] MR1_DDR3 = {1'b0, DDR3_QOFF, DDR3_TDQS, 1'b0, DDR3_RTT_NOM[2], 1'b0, DDR3_LEVEL, DDR3_RTT_NOM[1], DDR3_DIC[1], DDR3_AL, DDR3_RTT_NOM[0], DDR3_DIC[0], DDR3_DLL_EN};
//MR2_DDR3
localparam [1:0] DDR3_RTT_WR   = 2'b00;
localparam [0:0] DDR3_SRT      = 1'b0;
localparam [0:0] DDR3_ASR      = 1'b0;


localparam [2:0] DDR3_CWL      = 5 - 5;


localparam [2:0] DDR3_PASR     = 3'b000;
localparam [15:0] MR2_DDR3     = {5'b00000, DDR3_RTT_WR, 1'b0, DDR3_SRT, DDR3_ASR, DDR3_CWL, DDR3_PASR};
//MR3_DDR3
localparam [0:0] DDR3_MPR      = 1'b0;
localparam [1:0] DDR3_MPR_LOC  = 2'b00;
localparam [15:0] MR3_DDR3     = {13'b0, DDR3_MPR, DDR3_MPR_LOC};



//****************************************************************************     
//The following parameters are mode register settings                              
//*****************************************************************************       
localparam INIT_MC_AL           = 2'b10       ;
localparam INIT_MC_CL           = 6           ;
localparam INIT_MC_CWL          = 5           ;
localparam INIT_MC_WR           = 6           ;       

//******************************************************************************
//The following parameters are Memory Timing
//******************************************************************************    

  localparam         MEM_TYPE          =  "DDR3"    ;

  localparam [7:0]   PHY_TMRD          =  4/4    ;

  localparam [7:0]   PHY_TRP           =  2      ;

  localparam [7:0]   PHY_TRCD          =  2      ;

  localparam         DDRC_TXSDLL       = 512      ;

  localparam         DDRC_TXP          = 3       ;

  localparam         DDRC_TFAW         = 18       ;

  localparam         DDRC_TRAS         = 15       ;

  localparam         DDRC_TRCD         = 6       ;

  localparam         DDRC_TRFC         = 120       ;

  localparam         DDRC_TREFI        = 3120       ;

  localparam         DDRC_TRC          = 20       ;

  localparam         DDRC_TRP          = 6       ;

  localparam         DDRC_TRRD         = 4       ;

  localparam         DDRC_TRTP         = 4       ;

  localparam         DDRC_TWR          = 6       ;

  localparam         DDRC_TWTR         = 4       ;

  localparam [7:0]   PHY_TMOD          =  12/4    ;

  localparam [9:0]   PHY_TZQINIT       =  10'd128 ;

  localparam [7:0]   PHY_TRFC          =  30      ;

  localparam [7:0]   PHY_TXPR          =  31      ;

  localparam real    CLKIN_FREQ        =  50.0   ;

  localparam         PLL_IDIV          =  1      ;

  localparam         PLL_FDIV          =  16     ;

  localparam         PLL_ODIV0         =  2      ;

  localparam         PLL_ODIV1         =  2*4    ;

  localparam         PLL_DUTY0         =  2      ;

  localparam         PLL_DUTY1         =  2*4    ;

endmodule

