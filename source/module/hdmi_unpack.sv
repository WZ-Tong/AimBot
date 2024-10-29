module hdmi_unpack #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] pack ,
    output                                         clk  ,
    output                                         hsync,
    output                                         vsync,
    output                                         de   ,
    output [                                  7:0] r    ,
    output [                                  7:0] g    ,
    output [                                  7:0] b    ,
    output [                    $clog2(H_ACT)-1:0] x    ,
    output [                    $clog2(V_ACT)-1:0] y
);

    assign {clk, hsync, vsync, de, r, g, b, x, y} = pack;

endmodule : hdmi_unpack
