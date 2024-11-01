`timescale 1ns / 1ps

module draw_window #(
    parameter BOX_WIDTH = 1'b1    ,
    parameter BOX_NUM   = 1       ,

    parameter V_ACT     = 12'd720 ,
    parameter H_ACT     = 12'd1280
) (
    input                                          en      ,
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] i_pack  ,
    output [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] o_pack  ,

    input  [            BOX_NUM*$clog2(H_ACT)-1:0] start_xs,
    input  [            BOX_NUM*$clog2(V_ACT)-1:0] start_ys,

    input  [            BOX_NUM*$clog2(H_ACT)-1:0] end_xs  ,
    input  [            BOX_NUM*$clog2(V_ACT)-1:0] end_ys  ,

    input  [                       BOX_NUM*24-1:0] colors
);

    localparam H_ACT_BITS = $clog2(H_ACT);
    localparam V_ACT_BITS = $clog2(V_ACT);

    localparam CENTER_WIDTH = BOX_WIDTH * 3;

    wire clk;

    wire [H_ACT_BITS-1:0] x;
    wire [V_ACT_BITS-1:0] y;

    wire [BOX_NUM-1:0] active          ;
    wire [        7:0] color_r[BOX_NUM];
    wire [        7:0] color_g[BOX_NUM];
    wire [        7:0] color_b[BOX_NUM];

    genvar i;
    for (i = 0; i < BOX_NUM; i=i+1) begin : g_boxes
        wire [8*3-1:0] color;
        assign color = colors[(i+1)*(8*3)-1:i*(8*3)];
        assign {color_r[i], color_g[i], color_b[i]} = color;

        wire [H_ACT_BITS-1:0] start_x0, start_x1;
        assign start_x0 = start_xs[(i+1)*H_ACT_BITS-1:i*H_ACT_BITS];
        assign start_x1 = start_x0 + BOX_WIDTH;

        wire [H_ACT_BITS-1:0] end_x0, end_x1;
        assign end_x0 = end_xs[(i+1)*H_ACT_BITS-1:i*H_ACT_BITS];
        assign end_x1 = end_x0 + BOX_WIDTH;

        wire [V_ACT_BITS-1:0] start_y0, start_y1;
        assign start_y1 = start_ys[(i+1)*V_ACT_BITS-1:i*V_ACT_BITS];
        assign start_y0 = start_y1 - BOX_WIDTH;

        wire [V_ACT_BITS-1:0] end_y0, end_y1;
        assign end_y1 = end_ys[(i+1)*V_ACT_BITS-1:i*V_ACT_BITS];
        assign end_y0 = end_y1 - BOX_WIDTH;

        // Box is not (0,0)->(0,0)
        wire start_valid, end_valid, xy_valid;
        assign start_valid = start_x0!=0 && start_y0!=0;
        assign end_valid   = end_x0!=0 && end_y0!=0;
        assign xy_valid    = start_valid||end_valid;

        // Box is outside inner bound, inside outer bound
        wire box_outer_active, box_inner_active, box_active;
        assign box_outer_active = x>=start_x0 && x<=end_x1 && y>=start_y0 && y<=end_y1;
        assign box_inner_active = x>=start_x1 && x<=end_x0 && y>=start_y1 && y<=end_y0;
        assign box_active       = box_outer_active && !box_inner_active;

        // Box should be able to contain center cross
        wire x_gap_valid, y_gap_valid, gap_valid;
        assign x_gap_valid = (end_x0-start_x0) >= (CENTER_WIDTH*2+BOX_WIDTH);
        assign y_gap_valid = (end_y1-start_y1) >= (CENTER_WIDTH*2+BOX_WIDTH);
        assign gap_valid   = x_gap_valid && y_gap_valid;

        wire [H_ACT_BITS:0] x_total_start, x_total_end;
        wire [V_ACT_BITS:0] y_total_start, y_total_end;
        assign x_total_start = start_x0 + end_x0;
        assign y_total_start = start_y1 + end_y1;
        assign x_total_end   = start_x1 + end_x1;
        assign y_total_end   = start_y0 + end_y0;

        wire [H_ACT_BITS-1:0] x_center_start, x_center_end;
        wire [V_ACT_BITS-1:0] y_center_start, y_center_end;
        assign x_center_start = x_total_start[H_ACT_BITS:1];
        assign y_center_start = y_total_start[V_ACT_BITS:1];
        assign x_center_end   = x_total_end[H_ACT_BITS:1];
        assign y_center_end   = y_total_end[V_ACT_BITS:1];

        wire [H_ACT_BITS-1:0] x_cb_start, x_cb_end; // Center boundary
        wire [V_ACT_BITS-1:0] y_cb_start, y_cb_end; // Center boundary
        assign x_cb_start = x_center_start - CENTER_WIDTH;
        assign y_cb_start = y_center_start - CENTER_WIDTH;
        assign x_cb_end   = x_center_end + CENTER_WIDTH;
        assign y_cb_end   = y_center_end + CENTER_WIDTH;

        // Center cross pattern
        wire ch_active, cv_active, center_active;
        assign ch_active     = x>=x_cb_start && x<=x_cb_end && y>=y_center_start && y<=y_center_end;
        assign cv_active     = y>=y_cb_start && y<=y_cb_end && x>=x_center_start && x<=x_center_end;
        assign center_active = ch_active || cv_active;

        assign active[i] = (xy_valid && gap_valid) && (box_active || center_active);
    end

    wire [7:0] hdmi_r;
    wire [7:0] hdmi_g;
    wire [7:0] hdmi_b;

    wire hdmi_hsync, hdmi_vsync, hdmi_de;
    hdmi_unpack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_hdmi_unpack (
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
        for (j = 0; j < BOX_NUM; j=j+1) begin
            if (active[j]) begin
                c_r = color_r[j];
                c_g = color_g[j];
                c_b = color_b[j];
            end
        end
    end

    reg r_hsync, r_vsync, r_de;

    reg [7:0] r_r, r_g, r_b;

    reg [$clog2(H_ACT)-1:0] r_x;
    reg [$clog2(V_ACT)-1:0] r_y;

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

    hdmi_pack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_hdmi_pack (
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
