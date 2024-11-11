module compress_window #(
    localparam WIN_W     = 4                                ,
    localparam WIN_H     = 5                                ,
    localparam WIN_S     = WIN_W*WIN_H                      ,
    localparam WIN_TH    = WIN_S*2/3                        ,
    localparam H_ACT     = 12'd1280                         ,
    localparam V_ACT     = 12'd720                          ,
    localparam PACK_SIZE = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                          rstn    ,
    input      [    PACK_SIZE-1:0] i_pack  ,
    input      [        WIN_H-1:0] window  ,
    // Position
    output reg [$clog2(H_ACT)-1:0] start_x ,
    output reg [$clog2(V_ACT)-1:0] start_y ,
    output reg [$clog2(H_ACT)-1:0] end_x   ,
    output reg [$clog2(V_ACT)-1:0] end_y   ,
    // Debug only
    output     [    PACK_SIZE-1:0] dbg_pack
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

    reg [$clog2(WIN_S)-1:0] sum    ;
    reg [$clog2(WIN_W)-1:0] col_cnt;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn | vsync) begin
            sum     <= #1 'b0;
            col_cnt <= #1 'b0;
        end else begin
            if (de) begin
                if (col_cnt==WIN_W-1) begin
                    sum     <= #1 'b0;
                    col_cnt <= #1 'b0;
                end else begin
                    sum     <= #1 sum + col_sum;
                    col_cnt <= #1 col_cnt + 1'b1;
                end
            end else begin
                sum     <= #1 'b0;
                col_cnt <= #1 'b0;
            end
        end
    end

    wire row_valid;
    assign row_valid = y>=WIN_H;

    wire col_valid;
    assign col_valid = col_cnt==WIN_W-1;

    wire buf_valid;
    assign buf_valid = col_valid && row_valid;

    wire buf_val;
    assign buf_val = sum>=WIN_TH ? 1'b1 : 1'b0;

    reg vsync_d;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            vsync_d <= #1 'b0;
        end else begin
            vsync_d <= #1 vsync;
        end
    end
    wire vsync_r;
    assign vsync_r = vsync_d==0 && vsync==1;

    reg [$clog2(H_ACT)-1:0] temp_start_x;
    reg [$clog2(V_ACT)-1:0] temp_start_y;
    reg [$clog2(H_ACT)-1:0] temp_end_x  ;
    reg [$clog2(V_ACT)-1:0] temp_end_y  ;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            temp_start_x <= #1 H_ACT;
            temp_start_y <= #1 V_ACT;
            temp_end_x   <= #1 'b0;
            temp_end_y   <= #1 'b0;

            start_x <= #1 'b0;
            start_y <= #1 'b0;
            end_x   <= #1 'b0;
            end_y   <= #1 'b0;
        end else if (vsync_r) begin
            temp_start_x <= #1 H_ACT;
            temp_start_y <= #1 V_ACT;
            temp_end_x   <= #1 'b0;
            temp_end_y   <= #1 'b0;

            start_x <= #1 temp_start_x;
            start_y <= #1 temp_start_y;
            end_x   <= #1 temp_end_x  ;
            end_y   <= #1 temp_end_y  ;
        end else if (buf_valid && buf_val) begin
            temp_start_x <= #1 temp_start_x<=x ? temp_start_x : x;
            temp_start_y <= #1 temp_start_y<=y ? temp_start_y : y;
            temp_end_x   <= #1 temp_end_x>=x ? temp_end_x : x;
            temp_end_y   <= #1 temp_end_y>=y ? temp_end_y : y;
        end
    end

    reg [$clog2(H_ACT/WIN_W)-1:0] dbg_addr   ;
    reg [        H_ACT/WIN_W-1:0] dbg_line   ;
    reg                           dbg_current;
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
