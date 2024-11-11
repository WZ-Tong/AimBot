module cam_dis_calc #(
    parameter H_ACT = 12'd1280,
    parameter V_ACT = 12'd720
) (
    input  [$clog2(H_ACT)-1:0] cam1_start_x,
    input  [$clog2(V_ACT)-1:0] cam1_start_y,
    input  [$clog2(H_ACT)-1:0] cam1_end_x  ,
    input  [$clog2(V_ACT)-1:0] cam1_end_y  ,

    input  [$clog2(H_ACT)-1:0] cam2_start_x,
    input  [$clog2(V_ACT)-1:0] cam2_start_y,
    input  [$clog2(H_ACT)-1:0] cam2_end_x  ,
    input  [$clog2(V_ACT)-1:0] cam2_end_y  ,

    output [             23:0] color
);

    localparam MAX_DIST = 256;

    wire [$clog2(H_ACT)-1+1:0] cam1_sum;
    assign cam1_sum = cam1_start_x + cam1_end_x;

    wire [$clog2(H_ACT)-1+1:0] cam2_sum;
    assign cam2_sum = cam2_start_x + cam2_end_x;

    wire [$clog2(H_ACT)-1:0] distance;
    assign distance = cam1_sum>cam2_sum ? cam1_sum-cam2_sum : cam2_sum-cam1_sum;

    localparam OFFSET = 2;

    wire [$clog2(MAX_DIST)-1:0] offset;
    assign offset = distance>MAX_DIST ? MAX_DIST-1 : distance;

    wire [7:0] r, g, b;
    color_gradient u_color_gradient (.step(offset[7:4]), .r(r), .g(g), .b(b));
    assign color = {r, g, b};

endmodule : cam_dis_calc
