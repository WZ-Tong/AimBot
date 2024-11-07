module frame_process_3 #(
    parameter  H_ACT       = 1280                                     ,
    parameter  V_ACT       = 720                                      ,

    parameter  KEY_TICK    = 500_000                                  ,

    localparam I_PACK_SIZE = 3*8+4+$clog2(H_ACT-0)+$clog2(V_ACT-0)    ,
    localparam O_PACK_SIZE = 3*8+4+$clog2(H_ACT-2*2)+$clog2(V_ACT-2*2)
) (
    input                    rstn    ,
    input                    face_key,
    input  [I_PACK_SIZE-1:0] i_pack  ,
    output [O_PACK_SIZE-1:0] o_pack
);

    wire [I_PACK_SIZE-1:0] pack3;

    wire [23:0] line1;
    wire [23:0] line2;
    wire [23:0] line3;
    three_line_buffer #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_three_line_buffer (
        .rstn  (rstn  ),
        .i_pack(i_pack),
        .line1 (line1 ),
        .line2 (line2 ),
        .line3 (line3 ),
        .o_pack(pack3 )
    );

    wire [7:0] r1, b1, g1;
    wire [7:0] r2, b2, g2;
    wire [7:0] r3, b3, g3;
    assign {r1,b1,g1} = line1;
    assign {r2,b2,g2} = line2;
    assign {r3,b3,g3} = line3;

    wire face_en;
    key_to_switch #(
        .TICK(KEY_TICK),
        .INIT(1'b1    )
    ) u_face_en (
        .clk   (clk     ),
        .rstn  (rstn    ),
        .key   (face_key),
        .switch(face_en )
    );

    bin_face #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_bin_face (
        .rstn  (rstn   ),
        .en    (face_en),
        .i_pack(i_pack ),
        .o_pack(o_pack )
    );

endmodule : frame_process_3
