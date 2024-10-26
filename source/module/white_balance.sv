module white_balance #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input  [48:0] i_pack,
    input         wb_en ,
    output [48:0] o_pack
);

    wire       clk;
    wire [7:0] i_r;
    wire [7:0] i_g;
    wire [7:0] i_b;

    wire i_vsync;
    wire i_hsync;
    wire i_de   ;

    wire [$clog2(H_ACT)-1:0] i_x;
    wire [$clog2(V_ACT)-1:0] i_y;

    hdmi_unpack u_hdmi_unpack (
        .pack (i_pack ),
        .clk  (clk    ),
        .hsync(i_hsync),
        .vsync(i_vsync),
        .de   (i_de   ),
        .r    (i_r    ),
        .g    (i_g    ),
        .b    (i_b    ),
        .x    (i_x    ),
        .y    (i_y    )
    );

    // MAX=1280*720*256=235929600(e100000)
    reg [27:0] r_last_sum, r_current_sum;
    reg [27:0] g_last_sum, g_current_sum;
    reg [27:0] b_last_sum, b_current_sum;

    wire [8:0] r_v_trim;
    wire [8:0] g_v_trim;
    wire [8:0] b_v_trim;
    assign r_v_trim = r_last_sum[27:19];
    assign g_v_trim = g_last_sum[27:19];
    assign b_v_trim = b_last_sum[27:19];

    localparam DFT = 15'b100100011010001; // [(2^19)/(1280*720)] * (2^15)

    // =[r_sum/(2^19)] * [(2^19)/(1280*720)] * (2^15) = r_v * (2^15)
    wire [23:0] r_v;
    wire [23:0] g_v;
    wire [23:0] b_v;
    mul_15_9 u_mul_r_v (.clk(clk), .a(DFT), .b(r_v_trim), .p(r_v));
    mul_15_9 u_mul_g_v (.clk(clk), .a(DFT), .b(g_v_trim), .p(g_v));
    mul_15_9 u_mul_b_v (.clk(clk), .a(DFT), .b(b_v_trim), .p(b_v));

    wire [25:0] s_v  ;
    wire [25:0] k_v_w;
    assign s_v   = r_v + g_v + b_v;
    assign k_v_w = s_v / 3;

    reg [23:0] k_v;
    always_ff @(posedge clk) begin
        k_v <= #1 k_v_w[23:0];
    end

    reg i_vsync_d;
    always_ff @(posedge clk) begin
        i_vsync_d <= #1 i_vsync;
        if (i_vsync==1 && i_vsync_d==0) begin
            r_current_sum <= #1 'b0;
            g_current_sum <= #1 'b0;
            b_current_sum <= #1 'b0;
            if (wb_en) begin
                r_last_sum <= #1 r_current_sum;
                g_last_sum <= #1 g_current_sum;
                b_last_sum <= #1 b_current_sum;
            end
        end else begin
            if (i_de) begin
                r_current_sum <= #1 r_current_sum + i_r;
                g_current_sum <= #1 g_current_sum + i_g;
                b_current_sum <= #1 b_current_sum + i_b;
            end
        end
    end

    wire [15:0] r_kv, g_kv, b_kv;
    mul_8_8 u_mul_r_kv (.clk(clk), .a(i_r), .b(k_v[22:15]), .p(r_kv));
    mul_8_8 u_mul_g_kv (.clk(clk), .a(i_g), .b(k_v[22:15]), .p(g_kv));
    mul_8_8 u_mul_b_kv (.clk(clk), .a(i_b), .b(k_v[22:15]), .p(b_kv));

    wire [31:0] rev_r_v, rev_g_v, rev_b_v;
    Reciprocal u_rev_r (.Average(r_v[22:15]), .Recip(rev_r_v));
    Reciprocal u_rev_g (.Average(g_v[22:15]), .Recip(rev_g_v));
    Reciprocal u_rev_b (.Average(b_v[22:15]), .Recip(rev_b_v));

    wire [47:0] r_new_full, g_new_full, b_new_full;
    mul_32_16 u_mul_r (.clk(clk), .a(rev_r_v), .b(r_kv), .p(r_new_full));
    mul_32_16 u_mul_g (.clk(clk), .a(rev_g_v), .b(g_kv), .p(g_new_full));
    mul_32_16 u_mul_b (.clk(clk), .a(rev_b_v), .b(b_kv), .p(b_new_full));

    wire [15:0] r_new, g_new, b_new;
    assign r_new = r_new_full[47:32];
    assign g_new = g_new_full[47:32];
    assign b_new = b_new_full[47:32];

    reg [7:0] r_r, r_g, r_b;
    always_ff @(posedge clk) begin
        r_r <= #1 r_new>=16'h00FF ? 8'hFF : r_new[7:0];
        r_g <= #1 g_new>=16'h00FF ? 8'hFF : g_new[7:0];
        r_b <= #1 b_new>=16'h00FF ? 8'hFF : b_new[7:0];
    end

    localparam DELAY = 6;

    wire o_hsync, o_vsync, o_de;
    delay #(.DELAY(DELAY), .WIDTH(1)) u_hsync_delay (
        .clk   (clk    ),
        .i_data(i_hsync),
        .o_data(o_hsync)
    );
    delay #(.DELAY(DELAY), .WIDTH(1)) u_vsync_delay (
        .clk   (clk    ),
        .i_data(i_vsync),
        .o_data(o_vsync)
    );
    delay #(.DELAY(DELAY), .WIDTH(1)) u_de_delay (
        .clk   (clk ),
        .i_data(i_de),
        .o_data(o_de)
    );

    wire [10:0] o_x;
    wire [ 9:0] o_y;
    delay #(.DELAY(DELAY), .WIDTH(11)) u_x_delay (
        .clk   (clk),
        .i_data(i_x),
        .o_data(o_x)
    );
    delay #(.DELAY(DELAY), .WIDTH(10)) u_y_delay (
        .clk   (clk),
        .i_data(i_y),
        .o_data(o_y)
    );

    hdmi_pack u_hdmi_pack (
        .clk  (clk    ),
        .hsync(o_hsync),
        .vsync(o_vsync),
        .de   (o_de   ),
        .r    (r_r    ),
        .g    (r_g    ),
        .b    (r_b    ),
        .x    (o_x    ),
        .y    (o_y    ),
        .pack (o_pack )
    );

endmodule : white_balance
