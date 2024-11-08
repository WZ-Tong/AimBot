// Non-universal compress:
//    Win: 8*5
//   Repr: 16*10
module compress_window #(
    localparam H_ACT     = 12'd1280                         ,
    localparam V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                 rstn  ,
    input [PACK_SIZE-1:0] i_pack,
    input [          4:0] window
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

    wire [2:0] col_sum; // MAX: 5
    assign col_sum = 3'b0
        + window[0]
        + window[1]
        + window[2]
        + window[3]
        + window[4]
        + 3'b0;

    reg de_d;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            de_d <= #1 'b0;
        end else begin
            de_d <= #1 de;
        end
    end
    wire de_f;
    assign de_f = de_d==1 && de==0;

    reg [5:0] sum    ; // MAX: 5*8=40
    reg [3:0] row_cnt; // MAX: 10
    reg [2:0] col_cnt; // MAX: 8

    reg col_en;
    reg bin   ;
    reg valid ;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn | vsync) begin
            sum     <= #1 'b0;
            row_cnt <= #1 'b0;
            col_cnt <= #1 'b0;
            bin     <= #1 'b0;
            valid   <= #1 'b0;
            col_en  <= #1 'b1;
        end else begin
            if (de_f) begin
                if (row_cnt==10-1) begin
                    row_cnt <= #1 'b0;
                end else begin
                    row_cnt <= #1 row_cnt + 1'b1;
                end
            end

            if (de) begin
                if (col_cnt==8-1) begin
                    col_cnt <= #1 'b0;
                    col_en  <= #1 ~col_en;
                end else begin
                    col_cnt <= #1 col_cnt + 1'b1;
                end
            end else begin
                col_cnt <= #1 'b0;
                col_en  <= #1 'b1;
            end

            if (row_cnt==5-1 && de && col_en) begin
                sum <= #1 sum + col_sum;
            end else begin
                sum <= #1 'b0;
            end
        end
    end

    wire buf_valid;
    assign buf_valid = (col_cnt==8-1 && col_en) && (row_cnt==5-1);

    wire buf_val;
    assign buf_val = sum>=((5*8)/2) ? 1'b1 : 1'b0;

    bin_buffer #(.WIDTH(80), .ROWS(72)) u_bin_buffer (
        .clk   (clk      ),
        .rstn  (rstn     ),
        .valid (buf_valid),
        .bin   (buf_val  ),
        .cls   (vsync    ),
        .next  (hsync    ),
        .window(         )
    );

endmodule : compress_window
