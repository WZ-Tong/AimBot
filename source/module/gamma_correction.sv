module gamma_correction #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  en    ,
    input  [PACK_SIZE-1:0] i_pack,
    output [PACK_SIZE-1:0] o_pack
);

    wire [    PACK_SIZE-1:0] pack ;
    wire                     clk  ;
    wire                     hsync;
    wire                     vsync;
    wire                     de   ;
    wire [              7:0] r    ;
    wire [              7:0] g    ;
    wire [              7:0] b    ;
    wire [$clog2(H_ACT)-1:0] x    ;
    wire [$clog2(V_ACT)-1:0] y    ;

    hdmi_unpack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_unpack (
        .pack (pack ),
        .clk  (clk  ),
        .hsync(hsync),
        .vsync(vsync),
        .de   (de   ),
        .r    (r    ),
        .g    (g    ),
        .b    (b    ),
        .x    (x    ),
        .y    (y    )
    );

    wire [7:0] post_r;
    wire [7:0] post_g;
    wire [7:0] post_b;

    Curve_Gamma_2P2 u_gct_r (
        .Pre_Data (r     ),
        .Post_Data(post_r)
    );
    Curve_Gamma_2P2 u_gct_g (
        .Pre_Data (g     ),
        .Post_Data(post_g)
    );
    Curve_Gamma_2P2 u_gct_b (
        .Pre_Data (b     ),
        .Post_Data(post_b)
    );

    hdmi_pack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_pack (
        .clk  (clk        ),
        .hsync(hsync      ),
        .vsync(vsync      ),
        .de   (de         ),
        .r    (en?post_r:r),
        .g    (en?post_g:g),
        .b    (en?post_b:b),
        .x    (x          ),
        .y    (y          ),
        .pack (pack       )
    );

endmodule : gamma_correction
