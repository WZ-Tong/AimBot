`timescale 1ns / 1ps

module draw_window #(
    parameter V_BOX_WIDTH = 1'b1    ,
    parameter H_BOX_WIDTH = 1'b1    ,
    parameter N_BOX       = 1       ,

    parameter V_ACT       = 12'd720 ,
    parameter H_ACT       = 12'd1280
) (
    input                                clk     ,

    input      [      $clog2(H_ACT)-1:0] x       ,
    input      [      $clog2(V_ACT)-1:0] y       ,

    input      [N_BOX*$clog2(H_ACT)-1:0] start_xs,
    input      [N_BOX*$clog2(V_ACT)-1:0] start_ys,

    input      [N_BOX*$clog2(H_ACT)-1:0] end_xs  ,
    input      [N_BOX*$clog2(V_ACT)-1:0] end_ys  ,

    input      [           N_BOX*24-1:0] colors  ,

    input                                i_hsync ,
    input                                i_vsync ,
    input      [                    7:0] i_r     ,
    input      [                    7:0] i_g     ,
    input      [                    7:0] i_b     ,

    output reg                           o_hsync ,
    output reg                           o_vsync ,
    output reg [                    7:0] o_r     ,
    output reg [                    7:0] o_g     ,
    output reg [                    7:0] o_b
);

    wire [N_BOX-1:0] active /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [7:0] color_r [N_BOX-1:0];
    wire [7:0] color_g [N_BOX-1:0];
    wire [7:0] color_b [N_BOX-1:0];
    generate
        localparam H_ACT_BITS = $clog2(H_ACT);
        localparam V_ACT_BITS = $clog2(V_ACT);

        genvar i;
        for (i = 0; i < N_BOX; i=i+1) begin : boxes
            wire [H_ACT_BITS-1:0] start_x0, start_x1, start_x2;
            assign start_x0 = start_xs[(i+1)*H_ACT_BITS-1:i*H_ACT_BITS];
            assign start_x1 = start_x0;
            assign start_x2 = start_x1 + H_BOX_WIDTH;

            wire [H_ACT_BITS-1:0] end_x0, end_x1, end_x2;
            assign end_x0 = end_xs[(i+1)*H_ACT_BITS-1:i*H_ACT_BITS];
            assign end_x1 = end_x0;
            assign end_x2 = end_x1 + H_BOX_WIDTH;

            wire [V_ACT_BITS-1:0] start_y0, start_y1, start_y2;
            assign start_y0 = start_ys[(i+1)*V_ACT_BITS-1:i*V_ACT_BITS];
            assign start_y2 = start_y0;
            assign start_y1 = start_y2 - V_BOX_WIDTH;

            wire [V_ACT_BITS-1:0] end_y0, end_y1, end_y2;
            assign end_y0 = end_ys[(i+1)*V_ACT_BITS-1:i*V_ACT_BITS];
            assign end_y2 = end_y0;
            assign end_y1 = end_y2 - V_BOX_WIDTH;

            wire [8*3-1:0] color;
            assign color = colors[(i+1)*(8*3)-1:i*(8*3)];
            assign {color_r[i], color_g[i], color_b[i]} = color;

            wire outer_active, inner_active;
            assign outer_active = x>=start_x1 && x<=end_x2 && y>=start_y1 && y<=end_y2;
            assign inner_active = x>=start_x2 && x<=end_x1 && y>=start_y2 && y<=end_y1;

            wire box_valid, start_valid, end_valid;
            assign start_valid = start_x0!=0 && start_y0!=0;
            assign end_valid   = end_x0!=0 && end_y0!=0;
            assign box_valid   = start_valid||end_valid;

            assign active[i] = box_valid && outer_active && !inner_active;
        end
    endgenerate

    integer j;
    reg [7:0] r_r, r_g, r_b;
    always_comb begin
        r_r = i_r;
        r_g = i_g;
        r_b = i_b;
        for (j = 0; j < N_BOX; j=j+1) begin
            if (active[j]) begin
                r_r = color_r[j];
                r_g = color_g[j];
                r_b = color_b[j];
            end
        end
    end

    always_ff @(posedge clk) begin
        o_r     <= #1 r_r;
        o_g     <= #1 r_g;
        o_b     <= #1 r_b;
        o_hsync <= #1 i_hsync;
        o_vsync <= #1 i_vsync;
    end

endmodule : draw_window
