
//////////////////////////////////////////////////////////////////////////////
//
// Copyright (c) 2014 PANGO MICROSYSTEMS, INC
// ALL RIGHTS REVERVED.
//
// THE SOURCE CODE CONTAINED HEREIN IS PROPRIETARY TO PANGO MICROSYSTEMS, INC.
// IT SHALL NOT BE REPRODUCED OR DISCLOSED IN WHOLE OR IN PART OR USED BY
// PARTIES WITHOUT WRITTEN AUTHORIZATION FROM THE OWNER.
//
//////////////////////////////////////////////////////////////////////////////
// Library:
// Filename:async_fifo_16_8_1280.v
//////////////////////////////////////////////////////////////////////////////

module async_fifo_16_8_1280
   (
    
    wr_clk          ,  // input write clock
    wr_rst          ,  // input write reset
    
    wr_en           ,  // input write enable 1 active
    wr_data         ,  // input write data
    wr_full         ,  // output write full  flag 1 active
    
    wr_water_level  ,  // output write water level
    
    rd_clk          ,  // input read clock
    rd_rst          ,  // input read reset
    
    rd_en           ,  // input read enable
    rd_data         ,  // output read data
    
    almost_full     ,  // output write almost full
    rd_empty        ,  // output read empty
    
    almost_empty       // output write almost empty 
   );


localparam WR_DEPTH_WIDTH = 10 ; // @IPC int 9,20

localparam WR_DATA_WIDTH = 16 ; // @IPC int 1,1152

localparam RD_DEPTH_WIDTH = 11 ; // @IPC int 9,20

localparam RD_DATA_WIDTH = 8 ; // @IPC int 1,1152

localparam OUTPUT_REG = 0 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam RD_CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam WR_BYTE_EN = 0 ; // @IPC bool

localparam BE_WIDTH = 1 ; // @IPC int 2,128

localparam FIFO_TYPE = "ASYN_FIFO" ; // @IPC enum SYN_FIFO,ASYN_FIFO

localparam ASYN_FIFO_EN = "1" ; // @IPC bool

localparam ALMOST_FULL_NUM = 1020 ; // @IPC int

localparam ALMOST_EMPTY_NUM = 4 ; // @IPC int

localparam FULL_WL_EN = 1 ; // @IPC bool

localparam EMPTY_WL_EN = 0 ; // @IPC bool

localparam BYTE_SIZE = 8 ; // @IPC enum 8,9

localparam  RESET_TYPE_SEL     = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                                 (RESET_TYPE == "SYNC") ? "SYNC_RESET": "ASYNC_RESET_SYNC_RELEASE";
localparam  FIFO_TYPE_SEL      = (FIFO_TYPE=="SYN_FIFO") ? "SYN" : "ASYN" ; // @IPC enum SYN,ASYN
localparam  DEVICE_NAME        = "PGL50H";

localparam  WR_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? 10 : WR_DATA_WIDTH;
localparam  RD_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? 10 : RD_DATA_WIDTH;
localparam  SIM_DEVICE         = ((DEVICE_NAME == "PGL22G") || (DEVICE_NAME == "PGL22GS")) ? "PGL22G" : "LOGOS";

input [WR_DATA_WIDTH-1 : 0]    wr_data         ;    // input write data
input                          wr_en           ;    // input write enable 1 active

input                          wr_clk          ;    // input write clock
input                          wr_rst          ;    // input write reset

output                         wr_full         ;    // output write full  flag 1 active

output                         almost_full     ;    // output write almost full

output [WR_DEPTH_WIDTH : 0]    wr_water_level  ;    // output write water level

output [RD_DATA_WIDTH-1 : 0]   rd_data         ;    // output read data
input                          rd_en           ;    // input  read enable

input                          rd_clk          ;    // input  read clock
input                          rd_rst          ;    // input read reset

output                         rd_empty        ;    // output read empty

output                         almost_empty    ;    // output read water level


wire  [WR_DATA_WIDTH-1 : 0]                   wr_data         ;    // input write data
wire                                          wr_en           ;    // input write enable 1 active
wire                                          wr_clk          ;    // input write clock
wire                                          wr_full         ;    // input write full  flag 1 active
wire                                          wr_rst          ;    // input write reset
wire  [BE_WIDTH-1 : 0]                        wr_byte_en      ;    // input write byte enable
wire                                          almost_full     ;    // output write almost full
wire  [WR_DEPTH_WIDTH : 0]                    wr_water_level  ;    // output write water level
wire  [RD_DATA_WIDTH-1 : 0]                   rd_data         ;    // output read data
wire                                          rd_en           ;    // input  read enable
wire                                          rd_clk          ;    // input  read clock
wire                                          rd_empty        ;    // output read empty
wire                                          rd_rst          ;    // input read reset
wire                                          rd_oce          ;    // output read output register enable
wire                                          almost_empty    ;    // output read water level
wire  [RD_DEPTH_WIDTH : 0]                    rd_water_level  ;

wire  [BE_WIDTH-1:0]                          wr_byte_en_mux  ;
wire                                          rd_oce_mux      ;

wire [WR_DATA_WIDTH_WRAP-1 : 0]               wr_data_wrap;
wire [RD_DATA_WIDTH_WRAP-1 : 0]               rd_data_wrap;


endmodule