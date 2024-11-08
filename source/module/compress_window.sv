module compress_window #(
    parameter  H_ACT       = 12'd1280                         ,
    parameter  V_ACT       = 12'd720                          ,

    localparam COMP_WIDTH  = 8                                ,
    localparam COMP_HEIGHT = 10                               ,
    localparam WIN_WIDTH   = 8                                ,
    localparam WIN_HEIGHT  = 5                                ,
    localparam WIN_SIZE    = WIN_WIDTH*WIN_HEIGHT             ,
    localparam WIN_THRESH  = WIN_SIZE/2                       ,
    localparam PACK_SIZE   = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  rstn  ,
    input [ PACK_SIZE-1:0] i_pack,
    input [WIN_HEIGHT-1:0] window
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

    genvar i;
    for (i = 0; i < WIN_HEIGHT; i=i+1) begin: g_col_sum
        wire [$clog2(WIN_HEIGHT)-1:0] temp_col_sum;
        if (i==0) begin: g_col_initial
            assign temp_col_sum=window[0];
        end else begin: g_col_last
            assign temp_col_sum = g_col_sum[i-1].temp_col_sum+window[i];
        end
    end

    wire [$clog2(WIN_HEIGHT)-1:0] col_sum;
    assign col_sum = g_col_sum[WIN_HEIGHT-1].temp_col_sum;

    reg [$clog2(WIN_SIZE)-1:0] sum;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            sum <= #1 'b0;
        end else begin

        end
    end

    bin_buffer #(
        .WIDTH(H_ACT/COMP_WIDTH ),
        .ROWS (V_ACT/COMP_HEIGHT)
    ) u_bin_buffer (
        .clk   (clk ),
        .rstn  (rstn),
        .valid (    ),
        .bin   (    ),
        .cls   (    ),
        .next  (    ),
        .window(    )
    );

endmodule : compress_window
