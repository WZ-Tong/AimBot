module hdmi_pack #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input                                          clk  ,
    input                                          hsync,
    input                                          vsync,
    input                                          de   ,
    input  [                                  7:0] r    ,
    input  [                                  7:0] g    ,
    input  [                                  7:0] b    ,
    input  [                    $clog2(H_ACT)-1:0] x    ,
    input  [                    $clog2(V_ACT)-1:0] y    ,

    output [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] pack
);

    assign pack = {clk, hsync, vsync, de, r, g, b, x, y};

endmodule : hdmi_pack
