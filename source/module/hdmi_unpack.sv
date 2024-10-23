module hdmi_unpack (
    input  [48:0] pack ,
    output        clk  ,
    output        hsync,
    output        vsync,
    output        de   ,
    output [ 7:0] r    ,
    output [ 7:0] g    ,
    output [ 7:0] b    ,
    output [10:0] x    ,
    output [ 9:0] y
);

    assign {clk, hsync, vsync, de, r, g, b, x, y} = pack;

endmodule : hdmi_unpack
