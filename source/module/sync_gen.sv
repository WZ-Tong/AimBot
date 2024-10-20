module sync_gen #(
    parameter  THRESH    = 0                           ,
    parameter  DELAY     = 0                           ,

    parameter  V_FP      = 0                           ,
    parameter  V_SYNC    = 0                           ,
    parameter  V_BP      = 0                           ,

    parameter  H_FP      = 0                           ,
    parameter  H_SYNC    = 0                           ,
    parameter  H_BP      = 0                           ,

    parameter  V_BLANK   = 0                           ,
    parameter  H_BLANK   = 0                           ,

    localparam HV_OFFSET = 0                           ,
    localparam H_ACT     = 1280                        ,
    localparam V_ACT     = 720                         ,
    localparam H_TOTAL   = H_ACT + H_FP + H_SYNC + H_BP,
    localparam V_TOTAL   = V_ACT + V_FP + V_SYNC + V_BP,
    localparam X_BITS    = $clog2(H_TOTAL)             ,
    localparam Y_BITS    = $clog2(V_TOTAL)
) (
    input               clk    ,
    input               rstn   ,
    input               href   ,

    output              vsync  ,
    output              hsync  ,
    output              data_en,
    output              read_en,

    output [X_BITS-1:0] x      ,
    output [Y_BITS-1:0] y
);

    if (H_TOTAL-H_ACT!=H_BLANK) begin
        wrong_h u_error_h();
    end
    if (V_TOTAL-V_ACT!=V_BLANK) begin
        wrong_v u_error_v();
    end

    sync_vg #(
        .X_BITS   (X_BITS   ),
        .Y_BITS   (Y_BITS   ),
        .V_TOTAL  (V_TOTAL  ),
        .V_FP     (V_FP     ),
        .V_BP     (V_BP     ),
        .V_SYNC   (V_SYNC   ),
        .V_ACT    (V_ACT    ),
        .H_TOTAL  (H_TOTAL  ),
        .H_FP     (H_FP     ),
        .H_BP     (H_BP     ),
        .H_SYNC   (H_SYNC   ),
        .H_ACT    (H_ACT    ),
        .HV_OFFSET(HV_OFFSET)
    ) u_sync_vg (
        .clk   (clk     ),
        .rstn  (svg_rstn),
        .vs_out(vsync   ),
        .hs_out(hsync   ),
        .de_out(data_en ),
        .de_re (read_en ),
        .x_act (x       ),
        .y_act (y       )
    );

endmodule : sync_gen
