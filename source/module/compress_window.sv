// Non-universal compress:
//    Win: 8*5
//   Repr: 16*10
module compress_window #(
    localparam WIN_W     = 16                               ,
    localparam WIN_H     = 5                                ,
    localparam FAC_W     = 2                                ,
    localparam FAC_H     = 2                                ,
    localparam WIN_S     = WIN_W*WIN_H                      ,
    localparam H_ACT     = 12'd1280                         ,
    localparam V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                  rstn    ,
    input  [PACK_SIZE-1:0] i_pack  ,
    input  [    WIN_H-1:0] window  ,
    output [PACK_SIZE-1:0] dbg_pack
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

    wire [2:0] col_sum; // MAX: WIN_H=5
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

    reg [      $clog2(WIN_S)-1:0] sum    ;
    reg [$clog2(WIN_H*FAC_H)-1:0] row_cnt;
    reg [      $clog2(WIN_W)-1:0] col_cnt;

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
                if (row_cnt==(WIN_H*FAC_H)-1) begin
                    row_cnt <= #1 'b0;
                end else begin
                    row_cnt <= #1 row_cnt + 1'b1;
                end
            end

            if (de) begin
                if (col_cnt==WIN_W-1) begin
                    col_cnt <= #1 'b0;
                    col_en  <= #1 ~col_en;
                end else begin
                    col_cnt <= #1 col_cnt + 1'b1;
                end
            end else begin
                col_cnt <= #1 'b0;
                col_en  <= #1 'b1;
            end

            if (row_cnt==WIN_H-1 && de && col_en) begin
                sum <= #1 sum + col_sum;
            end else begin
                sum <= #1 'b0;
            end
        end
    end

    wire row_valid;
    assign row_valid = row_cnt==WIN_H-1;

    wire col_valid;
    assign col_valid = col_cnt==WIN_W-1 && col_en;

    wire buf_valid;
    assign buf_valid = col_valid && row_valid;

    localparam SUM_THRESH = WIN_S/2;

    wire buf_val;
    assign buf_val = sum>=SUM_THRESH ? 1'b1 : 1'b0;

    bin_buffer #(
        .WIDTH(H_ACT/(FAC_W*WIN_W)),
        .ROWS (V_ACT/(FAC_H*WIN_H))
    ) u_bin_buffer (
        .clk   (clk      ),
        .rstn  (rstn     ),
        .valid (buf_valid),
        .bin   (buf_val  ),
        .cls   (vsync    ),
        .next  (hsync    ),
        .window(         )    // TODO
    );

    reg [$clog2(H_ACT/(FAC_W*WIN_W))-1:0] dbg_addr   ;
    reg [        H_ACT/(FAC_W*WIN_W)-1:0] dbg_line   ;
    reg                                   dbg_current;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            dbg_line    <= #1 'b0;
            dbg_addr    <= #1 'b0;
            dbg_current <= #1 'b0;
        end else if (de) begin
            if (row_valid) begin
                if (col_valid) begin
                    dbg_addr           <= #1 dbg_addr + 1'b1;
                    dbg_line[dbg_addr] <= #1 buf_val;
                    dbg_current        <= #1 buf_val;
                end
            end else begin
                if (col_valid) begin
                    dbg_current <= #1 dbg_line[dbg_addr];
                    dbg_addr    <= #1 dbg_addr + 1'b1;
                end
            end
        end else begin
            dbg_addr <= #1 'b0;
        end
    end

    wire [7:0] dbg_rgb;
    assign dbg_rgb = dbg_current ? (~8'b0) : 8'b0;

    hdmi_pack #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_hdmi_pack (
        .clk  (clk     ),
        .hsync(hsync   ),
        .vsync(vsync   ),
        .de   (de      ),
        .r    (dbg_rgb ),
        .g    (dbg_rgb ),
        .b    (dbg_rgb ),
        .x    (x       ),
        .y    (y       ),
        .pack (dbg_pack)
    );


endmodule : compress_window
