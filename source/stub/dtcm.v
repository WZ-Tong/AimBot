
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
// Filename:dtcm.v
//////////////////////////////////////////////////////////////////////////////

module dtcm
    (
    addr        ,
    wr_data     ,
    rd_data     ,
    wr_en       ,
    clk         ,
    
    wr_byte_en  ,

    rst
    );


localparam ADDR_WIDTH = 13 ; // @IPC int 9,20

localparam DATA_WIDTH = 32 ; // @IPC int 1,1152

localparam WRITE_MODE = "NORMAL_WRITE"; // @IPC enum NORMAL_WRITE,TRANSPARENT_WRITE,READ_BEFORE_WRITE

localparam OUTPUT_REG = 0 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam INIT_FILE = "NONE" ; // @IPC string

localparam INIT_FORMAT = "BIN" ; // @IPC enum BIN,HEX

localparam WR_BYTE_EN = 1 ; // @IPC bool

localparam BE_WIDTH = 4 ; // @IPC int 2,128

localparam BYTE_SIZE = 8 ; // @IPC enum 8,9

localparam INIT_EN = 0 ; // @IPC bool

localparam CLK_EN  = 0 ; // @IPC bool

localparam ADDR_STROBE_EN  = 0 ; // @IPC bool

localparam  RESET_TYPE_SEL  = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                              (RESET_TYPE == "SYNC")  ? "SYNC_RESET"  : "ASYNC_RESET_SYNC_RELEASE";
localparam  DEVICE_NAME     = "PGL50H";

localparam  DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? 10 : DATA_WIDTH;
localparam  SIM_DEVICE      = ((DEVICE_NAME == "PGL22G") || (DEVICE_NAME == "PGL22GS")) ? "PGL22G" : "LOGOS";


input  [ADDR_WIDTH-1 : 0]   addr        ;
input  [DATA_WIDTH-1 : 0]   wr_data     ;
output [DATA_WIDTH-1 : 0]   rd_data     ;
input                       wr_en       ;
input                       clk         ;

input  [BE_WIDTH-1 : 0]     wr_byte_en  ;

input                       rst         ;

wire [ADDR_WIDTH-1 : 0]     addr        ;
wire [DATA_WIDTH-1 : 0]     wr_data     ;
wire [DATA_WIDTH-1 : 0]     rd_data     ;
wire                        wr_en       ;
wire                        clk         ;
wire                        clk_en      ;
wire                        addr_strobe ;
wire                        rst         ;
wire [BE_WIDTH-1 : 0]       wr_byte_en  ;
wire                        rd_oce      ;

wire [BE_WIDTH-1 : 0]       wr_byte_en_mux  ;
wire                        rd_oce_mux      ;
wire                        clk_en_mux      ;
wire                        addr_strobe_mux ;

wire [DATA_WIDTH_WRAP-1 : 0] wr_data_wrap;
wire [DATA_WIDTH_WRAP-1 : 0] rd_data_wrap;

assign wr_byte_en_mux   = (WR_BYTE_EN     == 1) ? wr_byte_en  : -1  ;
assign rd_oce_mux       = (RD_OCE_EN      == 1) ? rd_oce      :
                          (OUTPUT_REG     == 1) ? 1'b1 : 1'B0 ;
assign clk_en_mux       = (CLK_EN         == 1) ? clk_en      : 1'b1 ;
assign addr_strobe_mux  = (ADDR_STROBE_EN == 1) ? addr_strobe : 1'b0 ;


assign wr_data_wrap    = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? {{(DATA_WIDTH_WRAP - DATA_WIDTH){1'b0}},wr_data} : wr_data;
assign rd_data         = ((DEVICE_NAME == "PGT30G") && (DATA_WIDTH <= 9)) ? rd_data_wrap[DATA_WIDTH-1 : 0] : rd_data_wrap;

endmodule
