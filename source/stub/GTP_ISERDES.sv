module GTP_ISERDES (
    output [7:0] DO,
    input [2:0] RADDR,
    input [2:0] WADDR,
    input DESCLK,
    input DI,
    input ICLK,
    input RCLK,
    input RST
);
    parameter ISERDES_MODE = "IDDR";
    parameter GRS_EN = "TRUE";
    parameter LRS_EN = "TRUE";
endmodule
