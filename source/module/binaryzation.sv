module binaryzation #(
    parameter  H_ACT     = 12'd1280                         ,
    parameter  V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  rstn  ,
    input                  en    ,
    input  [PACK_SIZE-1:0] i_pack,
    output [PACK_SIZE-1:0] o_pack
);

    wire                     clk  ;
    wire                     hsync;
    wire                     vsync;
    wire                     de   ;
    wire [              7:0] r    ;
    wire [              7:0] g    ;
    wire [              7:0] b    ;
    wire [$clog2(H_ACT)-1:0] x    ;
    wire [$clog2(V_ACT)-1:0] y    ;
    hdmi_unpack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_unpack (
        .pack (i_pack),
        .clk  (clk   ),
        .hsync(hsync ),
        .vsync(vsync ),
        .de   (de    ),
        .r    (r     ),
        .g    (g     ),
        .b    (b     ),
        .x    (x     ),
        .y    (y     )
    );

    reg vsync_d;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            vsync_d <= #1 'b0;
        end else begin
            vsync_d <= #1 vsync;
        end
    end

    wire pos_vsync, neg_vsync;
    assign pos_vsync = vsync==1 && vsync_d==0;
    assign neg_vsync = vsync==0 && vsync_d==1;

    // Triggers whenever set to high
    // Reset to LOW when NEGEDGE vsync
    reg en_d;
    always_ff @(posedge clk or posedge en) begin
        if(en) begin
            en_d <= #1 'b1;
        end else if (neg_vsync) begin
            en_d <= #1 'b0;
        end
    end

    // Keeps at least a frame
    // Changing when NEGEDGE vsync
    // Enable when:
    //   1. Reset
    //   3. Module is enabled
    reg refresh, disp_en;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            refresh <= #1 'b0;
            disp_en <= #1 'b0;
        end else if (neg_vsync) begin
            refresh <= #1 en_d;
            disp_en <= #1 refresh;
        end
    end

    reg [27:0] r_last_sum, r_current_sum;
    reg [27:0] g_last_sum, g_current_sum;
    reg [27:0] b_last_sum, b_current_sum;

    // NEGEDGE: Fixed current frame calc status (refresh)
    //     ACT: Calc sum (refresh holds)
    // POSEDGE: Assign value
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            r_current_sum <= #1 'b0;
            g_current_sum <= #1 'b0;
            b_current_sum <= #1 'b0;
            r_last_sum    <= #1 'b0;
            g_last_sum    <= #1 'b0;
            b_last_sum    <= #1 'b0;
        end else if (refresh) begin
            if (pos_vsync) begin
                r_current_sum <= #1 'b0;
                g_current_sum <= #1 'b0;
                b_current_sum <= #1 'b0;

                r_last_sum <= #1 r_current_sum;
                g_last_sum <= #1 g_current_sum;
                b_last_sum <= #1 b_current_sum;
            end else if (de) begin
                r_current_sum <= #1 r_current_sum + r;
                g_current_sum <= #1 g_current_sum + g;
                b_current_sum <= #1 b_current_sum + b;
            end
        end
    end

    wire [7:0] r_thresh;
    wire [7:0] g_thresh;
    wire [7:0] b_thresh;

    // WARN: HARD CODEDED `TRIM_BITS`
    localparam TRIM_BITS        = 8/2                       ; // 4
    localparam FRAME_TOTAL_BITS = $clog2(H_ACT*V_ACT)       ; // 20
    localparam SELECT_START     = FRAME_TOTAL_BITS+TRIM_BITS;
    localparam SELECT_OFFSET    = 8'h20;

    assign r_thresh = (r_last_sum >> SELECT_START) - SELECT_OFFSET;
    assign g_thresh = (g_last_sum >> SELECT_START) - SELECT_OFFSET;
    assign b_thresh = (b_last_sum >> SELECT_START) - SELECT_OFFSET;

    wire [7:0] r_bin;
    wire [7:0] g_bin;
    wire [7:0] b_bin;
    assign r_bin = r>=r_thresh ? (~8'b0) : (8'b0);
    assign g_bin = r>=g_thresh ? (~8'b0) : (8'b0);
    assign b_bin = r>=b_thresh ? (~8'b0) : (8'b0);

    wire [7:0] r_disp;
    wire [7:0] g_disp;
    wire [7:0] b_disp;
    assign r_disp = disp_en?r_bin:r;
    assign g_disp = disp_en?g_bin:g;
    assign b_disp = disp_en?b_bin:b;

    hdmi_pack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_pack (
        .clk  (clk   ),
        .hsync(hsync ),
        .vsync(vsync ),
        .de   (de    ),
        .r    (r_disp),
        .g    (g_disp),
        .b    (b_disp),
        .x    (x     ),
        .y    (y     ),
        .pack (o_pack)
    );

endmodule : binaryzation
