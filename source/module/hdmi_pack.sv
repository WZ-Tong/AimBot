module hdmi_pack (
    input         clk  ,
    input         hsync,
    input         vsync,
    input         de   ,
    input  [ 7:0] r    ,
    input  [ 7:0] g    ,
    input  [ 7:0] b    ,
    input  [10:0] x    ,
    input  [ 9:0] y    ,

    output [48:0] pack
);

    assign pack = {clk, hsync, vsync, de, r, g, b, x, y};

endmodule : hdmi_pack
