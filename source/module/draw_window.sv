`timescale 1ns / 1ps

module draw_window #(
    parameter V_BOX_WIDTH = 1'b1    ,
    parameter H_BOX_WIDTH = 1'b1    ,
    parameter N_BOX       = 1       ,

    parameter V_ACT       = 12'd720 ,
    parameter H_ACT       = 12'd1280
) (
    input                            en      ,
    input  [                   48:0] i_pack  ,
    output [                   48:0] o_pack  ,

    input  [N_BOX*$clog2(H_ACT)-1:0] start_xs,
    input  [N_BOX*$clog2(V_ACT)-1:0] start_ys,

    input  [N_BOX*$clog2(H_ACT)-1:0] end_xs  ,
    input  [N_BOX*$clog2(V_ACT)-1:0] end_ys  ,

    input  [           N_BOX*24-1:0] colors
);

    wire clk;

    wire [$clog2(H_ACT)-1:0] x;
    wire [$clog2(V_ACT)-1:0] y;

    wire [N_BOX-1:0] active;
    wire [7:0] color_r [N_BOX];
    wire [7:0] color_g [N_BOX];
    wire [7:0] color_b [N_BOX];
    generate
        localparam H_ACT_BITS = $clog2(H_ACT);
        localparam V_ACT_BITS = $clog2(V_ACT);

        genvar i;
        for (i = 0; i < N_BOX; i=i+1) begin : gen_boxes
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

    wire [7:0] hdmi_r;
    wire [7:0] hdmi_g;
    wire [7:0] hdmi_b;

    wire hdmi_hsync, hdmi_vsync, hdmi_de;
    hdmi_unpack u_hdmi_unpack (
        .pack (i_pack    ),
        .clk  (clk       ),
        .hsync(hdmi_hsync),
        .vsync(hdmi_vsync),
        .de   (hdmi_de   ),
        .r    (hdmi_r    ),
        .g    (hdmi_g    ),
        .b    (hdmi_b    ),
        .x    (x         ),
        .y    (y         )
    );

    integer j;

    logic [7:0] c_r, c_g, c_b;

    always_comb begin
        c_r = hdmi_r;
        c_g = hdmi_g;
        c_b = hdmi_b;
        for (j = 0; j < N_BOX; j=j+1) begin
            if (active[j]) begin
                c_r = color_r[j];
                c_g = color_g[j];
                c_b = color_b[j];
            end
        end
    end

    reg r_hsync, r_vsync, r_de;

    reg [7:0] r_r, r_g, r_b;

    reg [10:0] r_x;
    reg [ 9:0] r_y;

    always_ff @(posedge clk) begin
        r_hsync <= #1 hdmi_hsync;
        r_vsync <= #1 hdmi_vsync;
        r_de    <= #1 hdmi_de;
        r_x     <= #1 x;
        r_y     <= #1 y;

        r_r <= #1 en ? c_r : hdmi_r;
        r_g <= #1 en ? c_g : hdmi_g;
        r_b <= #1 en ? c_b : hdmi_b;
    end

    hdmi_pack u_hdmi_pack (
        .clk  (clk    ),
        .hsync(r_hsync),
        .vsync(r_vsync),
        .de   (r_de   ),
        .r    (r_r    ),
        .g    (r_g    ),
        .b    (r_b    ),
        .x    (r_x    ),
        .y    (r_y    ),
        .pack (o_pack )
    );

endmodule : draw_window
