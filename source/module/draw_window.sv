`timescale 1ns / 1ps

module draw_window #(
    parameter BITS    = 8       ,

    // 默认参数为720p
    parameter V_TOTAL = 12'd750 ,
    parameter V_FP    = 12'd5   ,
    parameter V_BP    = 12'd20  ,
    parameter V_SYNC  = 12'd5   ,
    parameter V_ACT   = 12'd720 ,

    parameter H_TOTAL = 12'd1650,
    parameter H_FP    = 12'd110 ,
    parameter H_BP    = 12'd220 ,
    parameter H_SYNC  = 12'd40  ,
    parameter H_ACT   = 12'd1280,

    parameter N_BOX   = 1
) (
    input                            pix_clk ,
    input                            hsync   ,
    input                            vsync   ,

    input  [N_BOX*$clog2(H_ACT)-1:0] start_xs,
    input  [N_BOX*$clog2(V_ACT)-1:0] start_ys,

    input  [N_BOX*$clog2(H_ACT)-1:0] end_xs  ,
    input  [N_BOX*$clog2(V_ACT)-1:0] end_ys  ,

    input  [               BITS-1:0] i_r     ,
    input  [               BITS-1:0] i_g     ,
    input  [               BITS-1:0] i_b     ,

    output [               BITS-1:0] o_r     ,
    output [               BITS-1:0] o_g     ,
    output [               BITS-1:0] o_b
);

    generate
        genvar i;
        for (i = 0; i < N_BOX; i=i+1) begin : box
            wire [$clog2(H_ACT)-1:0] start_x, end_x;
            wire [$clog2(V_ACT)-1:0] start_y, end_y;
            assign start_x = start_xs[(i+1)*$clog2(H_ACT)-1:i*$clog2(H_ACT)];
            assign start_y = start_ys[(i+1)*$clog2(V_ACT)-1:i*$clog2(V_ACT)];
            assign end_x   = end_xs[(i+1)*$clog2(H_ACT)-1:i*$clog2(H_ACT)];
            assign end_y   = end_ys[(i+1)*$clog2(V_ACT)-1:i*$clog2(V_ACT)];
        end
    endgenerate

    reg [$clog2(V_TOTAL)-1:0] v_cnt;
    reg [$clog2(H_TOTAL)-1:0] h_cnt;

endmodule : draw_window
