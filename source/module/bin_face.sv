module bin_face #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,
    localparam CB_LB     = 8'd77                            ,
    localparam CB_HB     = 8'd127                           ,
    localparam CR_LB     = 8'd133                           ,
    localparam CR_HB     = 8'd173                           ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  rstn  ,
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

    wire [7:0] cy;
    wire [7:0] cb;
    wire [7:0] cr;
    rgb_to_ycbcr u_rgb_to_ycbcr (
        .clk (clk ),
        .rstn(rstn),
        .r   (r   ),
        .g   (g   ),
        .b   (b   ),
        .y   (cy  ),
        .cb  (cb  ),
        .cr  (cr  )
    );

    wire active;
    assign active = 1
        && cb>=CB_LB
        && cb<=CB_HB
        && cr>=CR_LB
        && cr<=CR_HB;

    wire [7:0] bin;
    assign bin = active ? 8'hFF : 8'h00;

    localparam DELAY_YCBCR = 3+1;

    wire                     o_h;
    wire                     o_v;
    wire                     o_d;
    wire [$clog2(H_ACT)-1:0] o_x;
    wire [$clog2(V_ACT)-1:0] o_y;
    delay #(.DELAY(DELAY_YCBCR), .WIDTH(PACK_SIZE-1-3*8)) u_delay_ycbcr (
        .clk   (clk                  ),
        .i_data({hsync,vsync,de,x,y} ),
        .o_data({o_h,o_v,o_d,o_x,o_y})
    );

    hdmi_pack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_pack (
        .clk  (clk     ),
        .hsync(o_h     ),
        .vsync(o_v     ),
        .de   (o_d     ),
        .r    (en?bin:r),
        .g    (en?bin:g),
        .b    (en?bin:b),
        .x    (o_x     ),
        .y    (o_y     ),
        .pack (o_pack  )
    );

endmodule : bin_face
