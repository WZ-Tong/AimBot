module sync_gen #(
    parameter V_FP    = 5   ,
    parameter V_BP    = 20  ,
    parameter V_SYNC  = 5   ,
    parameter V_ACT   = 720 ,

    parameter H_FP    = 110 ,
    parameter H_BP    = 220 ,
    parameter H_SYNC  = 40  ,
    parameter H_ACT   = 1280
) (
    input      clk      ,
    input      cam_href ,
    input      cam_vsync,

    output reg hsync    ,
    output reg vsync
);

    localparam V_TOTAL = V_FP + V_BP + V_SYNC + V_ACT;
    localparam H_TOTAL = H_FP + H_BP + H_SYNC + H_ACT;

    reg [$clog2(V_TOTAL)-1:0] v_cnt;
    reg [$clog2(H_TOTAL)-1:0] h_cnt;

endmodule : sync_gen
