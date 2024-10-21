module white_balance #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input            clk    ,
    input            i_vsync,
    input            i_hsync,
    input            i_href ,
    input      [7:0] i_r    ,
    input      [7:0] i_g    ,
    input      [7:0] i_b    ,
    output reg       o_hsync,
    output reg       o_vsync,
    output reg       o_r    ,
    output reg       o_g    ,
    output reg       o_b
);

    localparam FRAME_TOTAL = V_ACT*H_ACT;
    localparam TRIM_BITS = $clog2(FRAME_TOTAL);

    reg [$clog2(FRAME_TOTAL*256)-1:0] r_last_sum, r_current_sum;
    reg [$clog2(FRAME_TOTAL*256)-1:0] g_last_sum, g_current_sum;
    reg [$clog2(FRAME_TOTAL*256)-1:0] b_last_sum, b_current_sum;

    wire [$clog2(256)-1:0] r_v;
    wire [$clog2(256)-1:0] g_v;
    wire [$clog2(256)-1:0] b_v;

    assign r_v = r_last_sum[$clog2(FRAME_TOTAL*256)-1:TRIM_BITS];
    assign g_v = g_last_sum[$clog2(FRAME_TOTAL*256)-1:TRIM_BITS];
    assign b_v = b_last_sum[$clog2(FRAME_TOTAL*256)-1:TRIM_BITS];

    wire [$clog2(256*3)-1:0] s_v;
    assign s_v = r_v + g_v + b_v;

    wire [$clog2(256)-1:0] k_v;
    assign k_v = s_v / 3;

    always_ff @(posedge clk) begin
        if (i_vsync) begin
            r_current_sum <= #1 'b0;
            g_current_sum <= #1 'b0;
            b_current_sum <= #1 'b0;

            r_last_sum <= #1 r_current_sum;
            g_last_sum <= #1 g_current_sum;
            b_last_sum <= #1 b_current_sum;
        end else begin
            if (i_href) begin
                r_current_sum <= #1 r_current_sum + i_r;
                g_current_sum <= #1 g_current_sum + i_g;
                b_current_sum <= #1 b_current_sum + i_b;
            end
        end
    end

endmodule : white_balance
