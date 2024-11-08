module binary_process #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,

    parameter  WIN_SIZE  = 5                                ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  rstn  ,
    input                  trig  ,
    input  [PACK_SIZE-1:0] i_pack,
    output [PACK_SIZE-1:0] o_pack
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

    localparam WIN_WIDTH   = 16        ;
    localparam WIN_HEIGHT  = WIN_SIZE  ;
    localparam COMP_WIDTH  = 16        ;
    localparam COMP_HEIGHT = WIN_SIZE*2;

    compress_window #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_compress_window (
        .rstn  (rstn    ),
        .i_pack(buf_pack),
        .window(window  )
    );

endmodule : binary_process
