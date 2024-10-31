module frame_process #(
    parameter BOX_NUM      = 1         ,
    parameter BOX_WIDTH    = 1         ,

    parameter H_ACT        = 1280      ,
    parameter V_ACT        = 720       ,

    parameter KEY_TICK     = 500_000   ,
    parameter WB_INIT_HOLD = 50_000_000
) (
    input                                          clk      ,
    input                                          rstn     ,

    input                                          wb_update,
    input                                          wb_key   ,
    input                                          dw_key   ,

    input  [            BOX_NUM*$clog2(H_ACT)-1:0] start_xs ,
    input  [            BOX_NUM*$clog2(V_ACT)-1:0] start_ys ,
    input  [            BOX_NUM*$clog2(H_ACT)-1:0] end_xs   ,
    input  [            BOX_NUM*$clog2(V_ACT)-1:0] end_ys   ,
    input  [                       BOX_NUM*24-1:0] colors   ,

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
        .H_ACT    (H_ACT       ),
        .V_ACT    (V_ACT       ),
        .INIT_HOLD(WB_INIT_HOLD)
    ) u_white_balance (
        .i_pack(i_pack   ),
        .rstn  (rstn     ),
        .en    (wb_en    ),
        .update(wb_update),
        .o_pack(wb_pack  )
    );

    wire dw_en;
    key_to_switch #(
        .TICK(KEY_TICK),
        .INIT(1'b1    )
    ) u_ks_dw_en (
        .clk   (clk   ),
        .rstn  (rstn  ),
        .key   (dw_key),
        .switch(dw_en )
    );

    wire [PACK_SIZE-1:0] win_pack;
    draw_window #(
        .BOX_WIDTH(BOX_WIDTH),
        .BOX_NUM  (BOX_NUM  )
    ) u_draw_window (
        .en      (dw_en   ),
        .i_pack  (wb_pack ),
        .o_pack  (o_pack  ),
        .start_xs(start_xs),
        .start_ys(start_ys),
        .end_xs  (end_xs  ),
        .end_ys  (end_ys  ),
        .colors  (colors  )
    );

endmodule : frame_process
