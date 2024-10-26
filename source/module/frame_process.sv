module frame_process #(
    parameter N_BOX       = 1   ,
    parameter V_BOX_WIDTH = 1   ,
    parameter H_BOX_WIDTH = 1   ,

    parameter H_ACT       = 1280,
    parameter V_ACT       = 720
) (
    input                            clk      ,

    input                            wb_en    ,
    input                            wb_switch,
    input                            dw_switch,

    input  [N_BOX*$clog2(H_ACT)-1:0] start_xs ,
    input  [N_BOX*$clog2(V_ACT)-1:0] start_ys ,
    input  [N_BOX*$clog2(H_ACT)-1:0] end_xs   ,
    input  [N_BOX*$clog2(V_ACT)-1:0] end_ys   ,
    input  [           N_BOX*24-1:0] colors   ,

    input  [                   48:0] i_pack   ,
    output [                   48:0] o_pack
);

    wire [48:0] disp_pack;
    assign disp_pack = i_pack;

    wire [48:0] wb_pack;
    white_balance #(
        .H_ACT(1280),
        .V_ACT(720 )
    ) u_white_balance (
        .i_pack(disp_pack),
        .wb_en (wb_en    ),
        .o_pack(wb_pack  )
    );

    wire [48:0] wbs_pack;
    pack_switch u_switch_white_balance (
        .clk     (clk      ),
        .switch  (wb_switch),
        .i_pack_1(wb_pack  ),
        .i_pack_2(disp_pack),
        .o_pack  (wbs_pack )
    );

    wire [48:0] win_pack;
    draw_window #(
        .V_BOX_WIDTH(N_BOX      ),
        .H_BOX_WIDTH(V_BOX_WIDTH),
        .N_BOX      (H_BOX_WIDTH)
    ) u_draw_window (
        .i_pack  (wbs_pack),
        .o_pack  (win_pack),
        .start_xs(start_xs),
        .start_ys(start_ys),
        .end_xs  (end_xs  ),
        .end_ys  (end_ys  ),
        .colors  (colors  )
    );

    wire [48:0] wins_pack;
    pack_switch u_switch_draw_window (
        .clk     (clk      ),
        .switch  (dw_switch),
        .i_pack_1(win_pack ),
        .i_pack_2(wbs_pack ),
        .o_pack  (wins_pack)
    );

    assign o_pack = wins_pack;

endmodule : frame_process
