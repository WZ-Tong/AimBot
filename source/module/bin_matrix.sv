module bin_matrix #(
    parameter  H_ACT       = 1280                                                          ,
    parameter  V_ACT       = 720                                                           ,

    parameter  WIN_WIDTH   = 8                                                             ,
    parameter  WIN_HEIGHT  = 4                                                             ,

    localparam I_PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)                             ,
    localparam O_PACK_SIZE = 3*8+4+$clog2(H_ACT-(WIN_WIDTH-1))+$clog2(V_ACT-(WIN_HEIGHT-1))
) (
    input  [I_PACK_SIZE-1:0] i_pack_3          ,
    input  [ WIN_HEIGHT-1:0] column            ,
    output [ WIN_HEIGHT-1:0] window [WIN_WIDTH],
    output [O_PACK_SIZE-1:0] o_pack_m
);

endmodule : bin_matrix
