
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
//
// Library:
// Filename: multiplier_8_8.v
//////////////////////////////////////////////////////////////////////////////
module multiplier_8_8
(
     ce  ,
     rst ,
     clk ,
     a   ,
     b   ,
     p
);



localparam ASIZE = 8 ; //@IPC int 2,72

localparam BSIZE = 8 ; //@IPC int 2,72

localparam A_SIGNED = 0 ; //@IPC enum 0,1

localparam B_SIGNED = 0 ; //@IPC enum 0,1

localparam ASYNC_RST = 1 ; //@IPC enum 0,1

localparam OPTIMAL_TIMING = 0 ; //@IPC enum 0,1

localparam INREG_EN = 0 ; //@IPC enum 0,1

localparam PIPEREG_EN_1 = 1 ; //@IPC enum 0,1

localparam PIPEREG_EN_2 = 1 ; //@IPC enum 0,1

localparam PIPEREG_EN_3 = 1 ; //@IPC enum 0,1

localparam OUTREG_EN = 0 ; //@IPC enum 0,1

//tmp variable for ipc purpose

localparam PIPE_STATUS = 3 ; //@IPC enum 0,1,2,3,4,5

localparam ASYNC_RST_BOOL = 1 ; //@IPC bool

localparam OPTIMAL_TIMING_BOOL = 0 ; //@IPC bool

//end of tmp variable
localparam  GRS_EN       = "FALSE"         ;

localparam  PSIZE = ASIZE + BSIZE          ;

input                 ce  ;
input                 rst ;
input                 clk ;
input  [ASIZE-1:0]    a   ;
input  [BSIZE-1:0]    b   ;
output [PSIZE-1:0]    p   ;


endmodule

