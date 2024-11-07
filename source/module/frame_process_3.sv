module frame_process_3 #(
    parameter  H_ACT       = 1280                                 ,
    parameter  V_ACT       = 720                                  ,

    parameter  KEY_TICK    = 500_000                              ,

    localparam I_PACK_SIZE = 3*8+4+$clog2(H_ACT-0)+$clog2(V_ACT-0),
    localparam O_PACK_SIZE = 3*8+4+$clog2(H_ACT-2)+$clog2(V_ACT-2)
) (
    input                    clk     ,
    input                    rstn    ,
    input  [I_PACK_SIZE-1:0] i_pack  ,
    output [O_PACK_SIZE-1:0] o_pack
);

    // Preload matrix start
    wire [23:0] line1;
    wire [23:0] line2;
    wire [23:0] line3;

    wire [I_PACK_SIZE-1:0] pack_3;
    three_line_buffer #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_three_line_buffer (
        .rstn  (rstn  ),
        .i_pack(i_pack),
        .line1 (line1 ),
        .line2 (line2 ),
        .line3 (line3 ),
        .o_pack(pack_3)
    );

    wire [7:0] r11, r12, r13;
    wire [7:0] r21, r22, r23;
    wire [7:0] r31, r32, r33;

    wire [7:0] g11, g12, g13;
    wire [7:0] g21, g22, g23;
    wire [7:0] g31, g32, g33;

    wire [7:0] b11, b12, b13;
    wire [7:0] b21, b22, b23;
    wire [7:0] b31, b32, b33;

    wire [O_PACK_SIZE-1:0] pack_m;
    three_line_matrix #(
        .H_ACT(H_ACT  ),
        .V_ACT(V_ACT  ),
        .MODE ("BLANK")
    ) u_three_line_matrix (
        .i_pack_3(pack_3),
        .line1   (line1 ),
        .line2   (line2 ),
        .line3   (line3 ),
        .o_pack_m(pack_m),
        .r11     (r11   ),
        .r12     (r12   ),
        .r13     (r13   ),
        .r21     (r21   ),
        .r22     (r22   ),
        .r23     (r23   ),
        .r31     (r31   ),
        .r32     (r32   ),
        .r33     (r33   ),
        .g11     (g11   ),
        .g12     (g12   ),
        .g13     (g13   ),
        .g21     (g21   ),
        .g22     (g22   ),
        .g23     (g23   ),
        .g31     (g31   ),
        .g32     (g32   ),
        .g33     (g33   ),
        .b11     (b11   ),
        .b12     (b12   ),
        .b13     (b13   ),
        .b21     (b21   ),
        .b22     (b22   ),
        .b23     (b23   ),
        .b31     (b31   ),
        .b32     (b32   ),
        .b33     (b33   )
    );
    // Preload matrix end

    assign o_pack = pack_m;

endmodule : frame_process_3
