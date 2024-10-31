module frame_process #(
    parameter H_ACT     = 1280   ,
    parameter V_ACT     = 720    ,

    parameter KEY_TICK  = 500_000
) (
    input                                          clk      ,
    input                                          rstn     ,

    input                                          wb_update,
    input                                          wb_key   ,
    input                                          gc_key   ,

    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] i_pack   ,
    output [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] o_pack
);

    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT);

    wire wb_en;
    key_to_switch #(
        .TICK(KEY_TICK),
        .INIT(1'b1    )
    ) u_ks_wb_en (
        .clk   (clk   ),
        .rstn  (rstn  ),
        .key   (wb_key),
        .switch(wb_en )
    );

    wire [PACK_SIZE-1:0] wb_pack;
    white_balance #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_white_balance (
        .i_pack(i_pack   ),
        .rstn  (rstn     ),
        .en    (wb_en    ),
        .update(wb_update),
        .o_pack(wb_pack  )
    );

    wire gc_en;
    key_to_switch #(
        .TICK(KEY_TICK),
        .INIT(1'b1    )
    ) u_ks_gc_en (
        .clk   (clk   ),
        .rstn  (rstn  ),
        .key   (gc_key),
        .switch(gc_en )
    );

    gray_convert #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_gray_convert (
        .en    (gc_en  ),
        .i_pack(wb_pack),
        .o_pack(o_pack )
    );

endmodule : frame_process
