module sync_gen #(
    parameter V_TOTAL = 12'd750 ,
    parameter V_FP    = 12'd5   ,
    parameter V_BP    = 12'd20  ,
    parameter V_SYNC  = 12'd5   ,
    parameter V_ACT   = 12'd720 ,

    parameter H_TOTAL = 12'd1650,
    parameter H_FP    = 12'd110 ,
    parameter H_BP    = 12'd220 ,
    parameter H_SYNC  = 12'd40  ,
    parameter H_ACT   = 12'd1280
) (
    input      clk      ,
    input      cam_href ,
    input      cam_vsync,

    output reg hsync    ,
    output reg vsync
);

endmodule : sync_gen
