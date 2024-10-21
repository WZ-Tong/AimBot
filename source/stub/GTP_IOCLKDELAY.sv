module GTP_IOCLKDELAY (
    input [7:0] DELAY_STEP,
    input CLKIN,
    input DIRECTION,
    input LOAD,
    input MOVE,
    output CLKOUT,
    output DELAY_OB
);
    parameter DELAY_STEP_VALUE = 'b00000000;
    parameter DELAY_STEP_SEL = "PARAMETER";
    parameter SIM_DEVICE = "TITAN";
endmodule
