module frame_process #(
    parameter  H_ACT     = 1280                                 ,
    parameter  V_ACT     = 720                                  ,

    parameter  KEY_TICK  = 500_000                              ,

    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT-0)+$clog2(V_ACT-0)
) (
    input                      clk           ,
    input                      rstn          ,

    input                      balance_update,
    input                      balance_key   ,
    input                      gamma_key     ,
    input                      gray_key      ,
    input                      face_key      ,

    output [$clog2(H_ACT)-1:0] face_start_x  ,
    output [$clog2(V_ACT)-1:0] face_start_y  ,
    output [$clog2(H_ACT)-1:0] face_end_x    ,
    output [$clog2(V_ACT)-1:0] face_end_y    ,

    input  [    PACK_SIZE-1:0] i_pack        ,
    output [    PACK_SIZE-1:0] o_pack
);

    wire gamma_en;
    key_to_switch #(
        .TICK(KEY_TICK),
        .INIT(1'b0    )
    ) u_gamma_en (
        .clk   (clk      ),
        .rstn  (rstn     ),
        .key   (gamma_key),
        .switch(gamma_en )
    );

    wire [PACK_SIZE-1:0] gamma_pack;
    gamma_correction #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_gamma_correction (
        .en    (gamma_en  ),
        .i_pack(i_pack    ),
        .o_pack(gamma_pack)
    );

    wire wb_en;
    key_to_switch #(
        .TICK(KEY_TICK),
        .INIT(1'b0    )
    ) u_wb_en (
        .clk   (clk        ),
        .rstn  (rstn       ),
        .key   (balance_key),
        .switch(wb_en      )
    );

    wire [PACK_SIZE-1:0] wb_pack;
    white_balance #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_white_balance (
        .i_pack(gamma_pack    ),
        .rstn  (rstn          ),
        .en    (wb_en         ),
        .update(balance_update),
        .o_pack(wb_pack       )
    );

    wire gray_en;
    key_to_switch #(
        .TICK(KEY_TICK),
        .INIT(1'b0    )
    ) u_gray_en (
        .clk   (clk     ),
        .rstn  (rstn    ),
        .key   (gray_key),
        .switch(gray_en )
    );

    wire [PACK_SIZE-1:0] gray_pack;
    gray_convert #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_gray_convert (
        .en    (gray_en),
        .i_pack(wb_pack),
        .o_pack(o_pack )
    );

    wire face_en;
    key_to_switch #(
        .TICK(KEY_TICK),
        .INIT(1'b0    )
    ) u_face_en (
        .clk   (clk     ),
        .rstn  (rstn    ),
        .key   (face_key),
        .switch(face_en )
    );

    // Binaryzation
    wire [PACK_SIZE-1:0] face_pack;
    bin_face #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_bin_face (
        .rstn  (rstn     ),
        .en    (face_en  ),
        .i_pack(wb_pack  ),
        .o_pack(face_pack)
    );

    wire [PACK_SIZE-1:0] face_dbg_pack;
    binary_process #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_binary_process (
        .rstn    (rstn         ),
        .en      (face_en      ),
        .i_pack  (face_pack    ),
        .start_x (face_start_x ),
        .start_y (face_start_y ),
        .end_x   (face_end_x   ),
        .end_y   (face_end_y   ),
        .dbg_pack(face_dbg_pack)
    );

endmodule : frame_process
