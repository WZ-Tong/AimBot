`timescale 1ns / 1ps

module draw_window #(
    parameter BITS        = 8       ,

    // 默认参数为720p
    parameter V_TOTAL     = 12'd750 ,
    parameter V_FP        = 12'd5   ,
    parameter V_BP        = 12'd20  ,
    parameter V_SYNC      = 12'd5   ,
    parameter V_ACT       = 12'd720 ,

    parameter H_TOTAL     = 12'd1650,
    parameter H_FP        = 12'd110 ,
    parameter H_BP        = 12'd220 ,
    parameter H_SYNC      = 12'd40  ,
    parameter H_ACT       = 12'd1280,

    parameter V_BOX_WIDTH = 1'b1    ,
    parameter H_BOX_WIDTH = 1'b1    ,
    parameter N_BOX       = 1
) (
    input                                 pix_clk ,
    input                                 hsync   ,
    input                                 vsync   ,

    input      [ N_BOX*$clog2(H_ACT)-1:0] start_xs,
    input      [ N_BOX*$clog2(V_ACT)-1:0] start_ys,

    input      [ N_BOX*$clog2(H_ACT)-1:0] end_xs  ,
    input      [ N_BOX*$clog2(V_ACT)-1:0] end_ys  ,

    input      [N_BOX*$clog2(3*BITS)-1:0] colors  ,

    input      [                BITS-1:0] i_r     ,
    input      [                BITS-1:0] i_g     ,
    input      [                BITS-1:0] i_b     ,

    output reg [                BITS-1:0] o_r     ,
    output reg [                BITS-1:0] o_g     ,
    output reg [                BITS-1:0] o_b
);

    localparam H_SYNC_ACTIVE = 1'b1;
    localparam V_SYNC_ACTIVE = 1'b1;

    reg  last_hsync, last_vsync;
    wire hsync_pulse, vsync_pulse;
    always_ff @(posedge pix_clk) begin
        last_hsync <= #1 hsync;
        last_vsync <= #1 vsync;
    end
    assign hsync_pulse = last_hsync!=H_SYNC_ACTIVE && hsync==H_SYNC_ACTIVE;
    assign vsync_pulse = last_vsync!=V_SYNC_ACTIVE && vsync==V_SYNC_ACTIVE;

    reg [$clog2(H_TOTAL)-1:0] h_cnt;
    reg [$clog2(V_TOTAL)-1:0] v_cnt;
    always_ff @(posedge pix_clk) begin
        if (hsync_pulse) begin
            h_cnt <= #1 'b0;
        end else if (h_cnt != H_TOTAL-1) begin
            h_cnt <= #1 h_cnt + 1'b1;
        end
        if (vsync_pulse) begin
            v_cnt <= #1 'b0;
        end else if (v_cnt != V_TOTAL-1) begin
            v_cnt <= #1 v_cnt + 1'b1;
        end
    end

    wire [N_BOX-1:0] active;
    wire [BITS-1:0] color_r [N_BOX-1:0];
    wire [BITS-1:0] color_g [N_BOX-1:0];
    wire [BITS-1:0] color_b [N_BOX-1:0];
    generate
        genvar i;
        for (i = 0; i < N_BOX; i=i+1) begin : boxes
            wire [$clog2(H_ACT)-1:0] start_x1, start_x2;
            assign start_x1 = start_xs[(i+1)*$clog2(H_ACT)-1:i*$clog2(H_ACT)] + H_SYNC + H_BP;
            assign start_x2 = start_xs[(i+1)*$clog2(H_ACT)-1:i*$clog2(H_ACT)] + H_SYNC + H_BP + H_BOX_WIDTH;

            wire [$clog2(H_ACT)-1:0] end_x1, end_x2;
            assign end_x1 = end_xs[(i+1)*$clog2(H_ACT)-1:i*$clog2(H_ACT)] + H_SYNC + H_BP;
            assign end_x2 = end_xs[(i+1)*$clog2(H_ACT)-1:i*$clog2(H_ACT)] + H_SYNC + H_BP + H_BOX_WIDTH;

            wire [$clog2(V_ACT)-1:0] start_y1, start_y2;
            assign start_y1 = start_ys[(i+1)*$clog2(V_ACT)-1:i*$clog2(V_ACT)] + V_SYNC + V_BP;
            assign start_y2 = start_ys[(i+1)*$clog2(V_ACT)-1:i*$clog2(V_ACT)] + V_SYNC + V_BP + V_BOX_WIDTH;

            wire [$clog2(V_ACT)-1:0] end_y1, end_y2;
            assign end_y1 = end_ys[(i+1)*$clog2(V_ACT)-1:i*$clog2(V_ACT)] + V_SYNC + V_BP;
            assign end_y2 = end_ys[(i+1)*$clog2(V_ACT)-1:i*$clog2(V_ACT)] + V_SYNC + V_BP + V_BOX_WIDTH;

            wire [BITS*3-1:0] color;
            assign color = colors[(i+1)*$clog2(BITS*3)-1:i*$clog2(BITS*3)];
            assign {color_r[i], color_g[i], color_b[i]} = color;

            wire outer_active, inner_active;
            assign outer_active = h_cnt>=start_x1 && h_cnt<=end_x2 && v_cnt>=start_y1 && v_cnt<=end_y2;
            assign inner_active = h_cnt>=start_x2 && h_cnt<=end_x1 && v_cnt>=start_y2 && v_cnt<=end_y1;

            assign active[i] = outer_active && !inner_active;
        end
    endgenerate

    always_comb begin
        o_r = i_r;
        o_g = i_g;
        o_b = i_b;
        for (int j = 0; j < N_BOX; j=j+1) begin
            if (active[j]) begin
                o_r = color_r[j];
                o_g = color_g[j];
                o_b = color_b[j];
            end
        end
    end

endmodule : draw_window
