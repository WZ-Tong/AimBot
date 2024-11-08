module binary_process #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,

    parameter  WIN_SIZE  = 5                                ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  rstn  ,
    input                  trig  ,
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
    hdmi_unpack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_unpack (
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

    wire bin;
    assign bin = (r==0&&g==0&&b==0) ? 1'b0 : 1'b1;

    wire [WIN_SIZE-1:0] window;
    bin_buffers #(.CAPACITY(H_ACT), .PARALLEL(WIN_SIZE)) u_bin_buffers (
        .clk   (clk   ),
        .rstn  (rstn  ),
        .hsync (hsync ),
        .cls   (vsync ),
        .bin   (bin   ),
        .de    (de    ),
        .window(window)
    );

    localparam DELAY = 1;

    wire o_hsync, o_vsync, o_de;
    delay #(
        .DELAY(DELAY),
        .WIDTH(3    )
    ) u_sync_de_delay (
        .clk   (clk                     ),
        .i_data({hsync, vsync, de}      ),
        .o_data({o_hsync, o_vsync, o_de})
    );

    wire [$clog2(H_ACT)-1:0] o_x;
    wire [$clog2(V_ACT)-1:0] o_y;
    delay #(
        .DELAY(DELAY                      ),
        .WIDTH($clog2(H_ACT)+$clog2(V_ACT))
    ) u_xy_delay (
        .clk   (clk       ),
        .i_data({x, y}    ),
        .o_data({o_x, o_y})
    );

    wire [7:0] test;
    assign test = window[0]==0 ? 8'b0 : (~8'b0);

    hdmi_pack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_pack (
        .clk  (clk    ),
        .hsync(o_hsync),
        .vsync(o_vsync),
        .de   (o_de   ),
        .r    (test   ),
        .g    (test   ),
        .b    (test   ),
        .x    (o_x    ),
        .y    (o_y    ),
        .pack (o_pack )
    );

endmodule : binary_process
