module gus_filter #(
    parameter  V_ACT     = 12'd720                          ,
    parameter  H_ACT     = 12'd1280                         ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  en    ,
    input  [PACK_SIZE-1:0] i_pack,
    output [PACK_SIZE-1:0] o_pack
);

    //            1 2 1
    // w = 1/16 * 2 4 2
    //            1 2 1

endmodule : gus_filter
