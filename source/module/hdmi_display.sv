module hdmi_display (
    input         clk    ,
    input         href   ,
    input  [15:0] data   ,

    output        hsync  ,
    output        vsync  ,
    output        data_en,
    output [ 7:0] r, g, b
);

endmodule : hdmi_display
