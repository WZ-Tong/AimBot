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

    reg  [$clog2(256)-1:0] k_v  ;
    wire [$clog2(256)-1:0] k_v_w;
    assign k_v_w = s_v / 3;
    always_ff @(posedge clk) begin
        k_v <= #1 k_v_w;
    end

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

    // Delay: 1, 8bit*8bit
    reg [$clog2(256*256)-1:0] r_kv, g_kv, b_kv;
    always_ff @(posedge clk) begin
        r_kv <= #1 i_r * k_v;
        g_kv <= #1 i_g * k_v;
        b_kv <= #1 i_b * k_v;
    end

    wire [31:0] rev_r_v, rev_g_v, rev_b_v;
    Reciprocal u_rev_r (.Average(r_v), .Recip(rev_r_v));
    Reciprocal u_rev_g (.Average(g_v), .Recip(rev_g_v));
    Reciprocal u_rev_b (.Average(b_v), .Recip(rev_b_v));

    wire [47:0] r_new_full, g_new_full, b_new_full;
    mul_32_16 u_mul_r (.clk(clk), .a(rev_r_v), .b(r_kv), .p(r_new_full));
    mul_32_16 u_mul_g (.clk(clk), .a(rev_g_v), .b(g_kv), .p(g_new_full));
    mul_32_16 u_mul_b (.clk(clk), .a(rev_b_v), .b(b_kv), .p(b_new_full));

    // TODO

endmodule : white_balance
