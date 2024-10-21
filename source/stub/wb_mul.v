

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
// Filename:wb_mul.v                 
//////////////////////////////////////////////////////////////////////////////
module wb_mul
( 
     ce         ,
     rst        ,
     clk        ,
     a          ,
     b          ,

     reload     ,
     p
);



localparam ASIZE = 32 ; //@IPC int 2,36

localparam BSIZE = 16 ; //@IPC int 2,36

localparam PSIZE = 66 ; //@IPC enum 24,48,96,66,84

localparam A_SIGNED = 0 ; //@IPC enum 0,1

localparam B_SIGNED = 0 ; //@IPC enum 0,1

localparam ASYNC_RST = 1 ; //@IPC enum 0,1

localparam INREG_EN = 1 ; //@IPC enum 0,1

localparam PIPEREG_EN = 1 ; //@IPC enum 0,1

localparam ACC_ADDSUB_OP = 0 ; //@IPC bool

localparam DYN_ACC_ADDSUB_OP = 0 ; //@IPC bool

localparam DYN_ACC_INIT = 0 ; //@IPC bool

localparam [PSIZE-1:0] ACC_INIT_VALUE = 66'h0 ; //@IPC string

//tmp variable for ipc purpose

localparam PIPE_STATUS = 2 ; //@IPC enum 0,1,2

localparam ASYNC_RST_BOOL = 1 ; //@IPC bool

//end of tmp variable
 
 localparam  GRS_EN       = "FALSE"        ;


 input                ce                   ;
 input                rst                  ;
 input                clk                  ;
 input  [ASIZE-1:0]   a                    ;
 input  [BSIZE-1:0]   b                    ;

 input                reload               ;
 output [PSIZE-1:0]   p                    ;


endmodule

