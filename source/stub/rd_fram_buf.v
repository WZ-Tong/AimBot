module rd_fram_buf
    (
    wr_data        , //input write data
    wr_addr        , //input write address
    wr_en          , //input write enable
    wr_clk         , //input write clock
    
    wr_rst         , //input write reset
    
    rd_data        , //output read data
    rd_addr        , //input read address
    rd_clk         , //input read clock
    
    rd_rst           //input read reset
    );


localparam WR_ADDR_WIDTH = 9 ; // @IPC int 9,20

localparam WR_DATA_WIDTH = 256 ; // @IPC int 1,1152

localparam RD_ADDR_WIDTH = 12 ; // @IPC int 9,20

localparam RD_DATA_WIDTH = 32 ; // @IPC int 1,1152

localparam OUTPUT_REG = 0 ; // @IPC bool

localparam RD_OCE_EN = 0 ; // @IPC bool

localparam RD_CLK_OR_POL_INV = 0 ; // @IPC bool

localparam RESET_TYPE = "ASYNC" ; // @IPC enum Sync_Internally,SYNC,ASYNC

localparam POWER_OPT = 0 ; // @IPC bool

localparam INIT_FILE = "NONE" ; // @IPC string

localparam INIT_FORMAT = "BIN" ; // @IPC enum BIN,HEX

localparam WR_BYTE_EN = 0 ; // @IPC bool

localparam BE_WIDTH = 1 ; // @IPC int 2,128

localparam RD_BE_WIDTH = 1 ; // @IPC int 2,128

localparam BYTE_SIZE = 8 ; // @IPC enum 8,9

localparam INIT_EN = 0 ; // @IPC bool

localparam SAMEWIDTH_EN = 0 ; // @IPC bool

localparam WR_CLK_EN = 0 ; // @IPC bool

localparam RD_CLK_EN = 0 ; // @IPC bool

localparam WR_ADDR_STROBE_EN = 0 ; // @IPC bool

localparam RD_ADDR_STROBE_EN = 0 ; // @IPC bool

localparam  RESET_TYPE_CTRL    = (RESET_TYPE == "ASYNC") ? "ASYNC_RESET" :
                                 (RESET_TYPE == "SYNC")  ? "SYNC_RESET"  : "ASYNC_RESET_SYNC_RELEASE";
localparam  DEVICE_NAME        = "PGL50H";

localparam  WR_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (WR_DATA_WIDTH <= 9)) ? 10 : WR_DATA_WIDTH;
localparam  RD_DATA_WIDTH_WRAP = ((DEVICE_NAME == "PGT30G") && (RD_DATA_WIDTH <= 9)) ? 10 : RD_DATA_WIDTH;
localparam  SIM_DEVICE         = ((DEVICE_NAME == "PGL22G") || (DEVICE_NAME == "PGL22GS")) ? "PGL22G" : "LOGOS";


input  [WR_DATA_WIDTH-1:0]    wr_data        ; //input write data    [WR_DATA_WIDTH-1:0]
input  [WR_ADDR_WIDTH-1:0]    wr_addr        ; //input write address [WR_ADDR_WIDTH-1:0]
input                         wr_en          ; //input write enable
input                         wr_clk         ; //input write clock

input                         wr_rst         ; //input write reset

output [RD_DATA_WIDTH-1:0]    rd_data        ; //output read data    [C_RD_DATA_WIDTH-1:0]
input  [RD_ADDR_WIDTH-1:0]    rd_addr        ; //input read address [RD_ADDR_WIDTH-1:0]
input                         rd_clk         ; //input read clock 

input                         rd_rst         ; //input read reset


endmodule
