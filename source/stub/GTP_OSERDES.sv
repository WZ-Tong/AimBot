module GTP_OSERDES (
    input [7:0] DI,
    input [3:0] TI,
    input OCLK,
    input RCLK,
    input RST,
    input SERCLK,
    output DO,
    output TQ
);
    parameter OSERDES_MODE = "ODDR";
    parameter WL_EXTEND = "FALSE";
    parameter GRS_EN = "TRUE";
    parameter LRS_EN = "TRUE";
    parameter TSDDR_INIT = 1'b0;
endmodule
