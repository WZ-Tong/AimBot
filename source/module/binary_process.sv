module binary_process #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,

    parameter  WIN_SIZE  = 5                                ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                          rstn    ,
    input      [    PACK_SIZE-1:0] i_pack  ,
    // Position
    output reg [$clog2(H_ACT)-1:0] start_x ,
    output reg [$clog2(V_ACT)-1:0] start_y ,
    output reg [$clog2(H_ACT)-1:0] end_x   ,
    output reg [$clog2(V_ACT)-1:0] end_y   ,
    output     [    PACK_SIZE-1:0] dbg_pack
);

    wire [ WIN_SIZE-1:0] window  ;
    wire [PACK_SIZE-1:0] buf_pack;
    bin_buffers #(
        .H_ACT(H_ACT   ),
        .V_ACT(V_ACT   ),
        .ROW  (WIN_SIZE)
    ) u_bin_buffers (
        .rstn  (rstn    ),
        .i_pack(i_pack  ),
        .o_pack(buf_pack),
        .window(window  )
    );

    compress_window u_compress_window (
        .rstn    (rstn    ),
        .i_pack  (buf_pack),
        .window  (window  ),
        .start_x (start_x ),
        .start_y (start_y ),
        .end_x   (end_x   ),
        .end_y   (end_y   ),
        .dbg_pack(dbg_pack)
    );

endmodule : binary_process
