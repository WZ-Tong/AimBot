// Remove 2 outer bounds to form a matrix
// ####
// #===
// #===
// #===(First)
module three_line_matrix #(
    parameter  H_ACT       = 1280                                     ,
    parameter  V_ACT       = 720                                      ,

    parameter  MODE        = "BLANK"                                  , // TRIM

    localparam I_PACK_SIZE = 3*8+4+$clog2(H_ACT-0)+$clog2(V_ACT-0)    ,
    localparam O_PACK_SIZE = 3*8+4+$clog2(H_ACT-2*2)+$clog2(V_ACT-2*2)
) (
    input  [I_PACK_SIZE-1:0] i_pack_3,
    input  [           23:0] line1   ,
    input  [           23:0] line2   ,
    input  [           23:0] line3   ,
    output [O_PACK_SIZE-1:0] o_pack_m,

    output reg [            7:0] r11, r12, r13,
    output reg [            7:0] r21, r22, r23,
    output reg [            7:0] r31, r32, r33,

    output reg [            7:0] g11, g12, g13,
    output reg [            7:0] g21, g22, g23,
    output reg [            7:0] g31, g32, g33,

    output reg [            7:0] b11, b12, b13,
    output reg [            7:0] b21, b22, b23,
    output reg [            7:0] b31, b32, b33
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
    hdmi_unpack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_unpack_3 (
        .pack (i_pack_3),
        .clk  (clk     ),
        .hsync(hsync   ),
        .vsync(vsync   ),
        .de   (de      ),
        .r    (r       ),
        .g    (g       ),
        .b    (b       ),
        .x    (x       ),
        .y    (y       )
    );

    wire in_range;
    assign in_range = 1
        && x>=2 && x<H_ACT-2
        && y>=2 && y<V_ACT-2;

    wire                         o_de;
    wire [                  7:0] o_r ;
    wire [                  7:0] o_g ;
    wire [                  7:0] o_b ;
    wire [$clog2(H_ACT-2*2)-1:0] o_x ;
    wire [$clog2(V_ACT-2*2)-1:0] o_y ;

    if (MODE=="BLANK") begin: g_blank_mode
        assign o_de = de;
        assign o_x = x;
        assign o_y = y;

        assign o_r = in_range?r:8'b0;
        assign o_g = in_range?g:8'b0;
        assign o_b = in_range?b:8'b0;
    end else if (MODE=="TRIM") begin: g_trim_mode
        assign o_de = de&&in_range;
        assign o_x  = x-8'd2;
        assign o_y  = y-8'd2;

        assign o_r = r ;
        assign o_g = g ;
        assign o_b = b ;
    end else begin: g_unknown_mode
        $display("Must be `BLANK` or `TRIM`");
    end

    hdmi_pack #(.H_ACT(H_ACT-2*2), .V_ACT(V_ACT-2*2)) u_hdmi_pack_m (
        .clk  (clk     ),
        .hsync(hsync   ),
        .vsync(vsync   ),
        .de   (o_de    ),
        .r    (o_r     ),
        .g    (o_g     ),
        .b    (o_b     ),
        .x    (o_x     ),
        .y    (o_y     ),
        .pack (o_pack_m)
    );

    wire [7:0] r1, b1, g1;
    wire [7:0] r2, b2, g2;
    wire [7:0] r3, b3, g3;
    assign {r1,b1,g1} = line1;
    assign {r2,b2,g2} = line2;
    assign {r3,b3,g3} = line3;

    always_ff @(posedge clk) begin
        {r11, r12, r13} <= #1 {r12, r13, r1};
        {r21, r22, r23} <= #1 {r22, r23, r2};
        {r31, r32, r33} <= #1 {r32, r33, r3};
    end

    always_ff @(posedge clk) begin
        {g11, g12, g13} <= #1 {g12, g13, g1};
        {g21, g22, g23} <= #1 {g22, g23, g2};
        {g31, g32, g33} <= #1 {g32, g33, g3};
    end

    always_ff @(posedge clk) begin
        {b11, b12, b13} <= #1 {b12, b13, b1};
        {b21, b22, b23} <= #1 {b22, b23, b2};
        {b31, b32, b33} <= #1 {b32, b33, b3};
    end

endmodule : three_line_matrix
