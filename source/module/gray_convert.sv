module gray_convert #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  en    ,
    input  [PACK_SIZE-1:0] i_pack,
    output [PACK_SIZE-1:0] o_pack
);

    wire                     clk  ;
    wire                     hsync;
    wire                     vsync;
    wire                     de   ;
    wire [              7:0] r    ;
    wire [              7:0] g    ;
    wire [              7:0] b    ;
    wire [$clog2(H_ACT)-1:0] x    ;
    wire [$clog2(V_ACT)-1:0] y    ;
    hdmi_unpack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_hdmi_unpack (
        .pack (i_pack),
        .clk  (clk   ),
        .hsync(hsync ),
        .vsync(vsync ),
        .de   (de    ),
        .r    (r     ),
        .g    (g     ),
        .b    (b     ),
        .x    (x     ),
        .y    (y     )
    );

    // Gray = R*38 + G*75 + B*15 >> 7
    wire [15:0] mul_r;
    wire [15:0] mul_g;
    wire [15:0] mul_b;
    mul_8_8 u_mul_r (
        .clk(clk  ),
        .a  (r    ),
        .b  (8'd38),
        .p  (mul_r)
    );
    mul_8_8 u_mul_g (
        .clk(clk  ),
        .a  (g    ),
        .b  (8'd75),
        .p  (mul_g)
    );
    mul_8_8 u_mul_b (
        .clk(clk  ),
        .a  (b    ),
        .b  (8'd15),
        .p  (mul_b)
    );

    wire [17:0] mul_sum;
    assign mul_sum = mul_r + mul_g + mul_b;

    wire [7:0] gray;
    assign gray = mul_sum[14:7];

    reg [7:0] r_gray;
    delay #(.DELAY(1), .WIDTH(8)) u_make_reg (
        .clk   (clk   ),
        .i_data(gray  ),
        .o_data(r_gray)
    );

    wire                     bypass_hsync;
    wire                     bypass_vsync;
    wire                     bypass_de   ;
    wire [              7:0] bypass_r    ;
    wire [              7:0] bypass_g    ;
    wire [              7:0] bypass_b    ;
    wire [$clog2(H_ACT)-1:0] bypass_x    ;
    wire [$clog2(V_ACT)-1:0] bypass_y    ;
    wire [  PACK_SIZE-1-1:0] bypass_delay;
    delay #(.DELAY(3+1), .WIDTH(PACK_SIZE-1)) u_bypass_delay (
        .clk   (clk                              ),
        .i_data({hsync, vsync, de, r, g, b, x, y}),
        .o_data(bypass_delay                     )
    );
    assign {
        bypass_hsync, bypass_vsync, bypass_de,
        bypass_r, bypass_g, bypass_b,
        bypass_x, bypass_y
    } = bypass_delay;

    hdmi_pack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_gray_pack (
        .clk  (clk               ),
        .hsync(bypass_hsync      ),
        .vsync(bypass_vsync      ),
        .de   (bypass_de         ),
        .r    (en?r_gray:bypass_r),
        .g    (en?r_gray:bypass_g),
        .b    (en?r_gray:bypass_b),
        .x    (bypass_x          ),
        .y    (bypass_y          ),
        .pack (o_pack            )
    );

endmodule : gray_convert
