module GTP_DLL (
    output [7:0] DELAY_STEP,
    output LOCK,
    input CLKIN,
    input PWD,
    input RST,
    input UPDATE_N
);
    parameter GRS_EN = "TRUE";
    parameter FAST_LOCK = "TRUE";
    parameter DELAY_STEP_OFFSET = 0;
endmodule
