module  DDR3_50H_32 #(

   parameter DFI_CLK_PERIOD       = 10000         ,

   parameter MEM_ROW_WIDTH   = 15         ,

   parameter MEM_COLUMN_WIDTH   = 10         ,

   parameter MEM_BANK_WIDTH      = 3          ,

  parameter MEM_DQ_WIDTH         =  32         ,

  parameter MEM_DM_WIDTH         =  4         ,

  parameter MEM_DQS_WIDTH        =  4         ,

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

endmodule

