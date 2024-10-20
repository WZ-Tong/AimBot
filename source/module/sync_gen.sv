module sync_gen #(
    parameter  H_FP      = 1                           ,
    parameter  V_FP      = 1                           ,

    localparam V_BP      = 5                           ,
    localparam V_SYNC    = 5                           ,
    localparam H_BP      = 200                         ,
    localparam H_SYNC    = 50                          ,

    localparam HV_OFFSET = 0                           ,
    localparam V_ACT     = 720                         ,
    localparam H_ACT     = 1280                        ,

    localparam H_TOTAL   = H_ACT + H_FP + H_SYNC + H_BP,
    localparam V_TOTAL   = V_ACT + V_FP + V_SYNC + V_BP,

    localparam X_BITS    = $clog2(H_TOTAL)             ,
    localparam Y_BITS    = $clog2(V_TOTAL)
) (
    input               clk     ,
    input               rstn    ,
    input               cam_href,

    output              vsync   ,
    output              hsync   ,
    output              data_en ,
    output              read_en ,

    output [X_BITS-1:0] x       ,
    output [Y_BITS-1:0] y
);

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
        .clk   (clk    ),
        .rstn  (rstn   ),
        .vs_out(vsync  ),
        .hs_out(hsync  ),
        .de_out(data_en),
        .de_re (read_en),
        .x_act (x      ),
        .y_act (y      )
    );

endmodule : sync_gen
