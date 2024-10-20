module hdmi_display (
    input         clk    ,
    input         rstn   ,
    input         href   ,
    input  [15:0] i_data ,

    output        error  ,
    output        hsync  ,
    output        vsync  ,
    output        data_en,
    output [15:0] o_data ,
    output [10:0] x      ,
    output [ 9:0] y
);

    wire read_en;

    localparam THRESH  = 0; // TODO
    localparam DELAY   = 0; // TODO
    localparam V_FP    = 0; // TODO
    localparam V_SYNC  = 0; // TODO
    localparam V_BP    = 0; // TODO
    localparam H_FP    = 0; // TODO
    localparam H_SYNC  = 0; // TODO
    localparam H_BP    = 0; // TODO
    localparam V_BLANK = 0; // TODO
    localparam H_BLANK = 0; // TODO

    localparam UNINIT   = 2'b00;
    localparam WAITING  = 2'b01;
    localparam DELAYING = 2'b10;
    localparam INITED   = 2'b11;

    reg [10:0] cnt /*synthesis PAP_MARK_DEBUG="true"*/;
    reg [1:0] state /*synthesis PAP_MARK_DEBUG="true"*/;
    reg svg_rstn, href_d /*synthesis PAP_MARK_DEBUG="true"*/;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            cnt      <= #1 'b0;
            href_d   <= #1 'b1;
            state    <= #1 UNINIT;
            svg_rstn <= #1 'b0;
        end else begin
            href_d   <= #1 href;
            svg_rstn <= #1 'b0;
            case (state)
                UNINIT : begin
                    if (href==0 && href_d==1) begin
                        state <= #1 WAITING;
                        cnt   <= #1 'b0;
                    end
                end
                WAITING : begin
                    if (href==1) begin
                        state <= #1 UNINIT;
                    end else begin
                        cnt <= #1 cnt + 1'b1;
                        if (cnt==THRESH-1) begin
                            cnt   <= #1 'b0;
                            state <= #1 DELAYING;
                        end
                    end
                end
                DELAYING : begin
                    cnt <= #1 cnt + 1'b1;
                    if (cnt==DELAY-1) begin
                        state <= #1 INITED;
                    end
                end
                INITED : begin
                    svg_rstn <= #1 'b1;
                end
            endcase
        end
    end
    
    sync_gen #(
        .THRESH (THRESH ),
        .DELAY  (DELAY  ),
        .V_FP   (V_FP   ),
        .V_SYNC (V_SYNC ),
        .V_BP   (V_BP   ),
        .H_FP   (H_FP   ),
        .H_SYNC (H_SYNC ),
        .H_BP   (H_BP   ),
        .V_BLANK(V_BLANK),
        .H_BLANK(H_BLANK)
    ) u_sync_gen (
        .clk    (clk     ),
        .rstn   (svg_rstn),
        .href   (href    ),
        .vsync  (vsync   ),
        .hsync  (hsync   ),
        .data_en(data_en ),
        .x      (x       ),
        .y      (y       ),
        .read_en(read_en )
    );

    wire full, err_fulln;
    rstn_gen #(.TICK(500_000)) u_err_full (
        .clk   (clk      ),
        .i_rstn(~full    ),
        .o_rstn(err_fulln)
    );
    assign err_full = ~err_fulln;

    wire empty, err_emptyn;
    rstn_gen #(.TICK(500_000)) u_err_empty (
        .clk   (clk       ),
        .i_rstn(~empty    ),
        .o_rstn(err_emptyn)
    );
    assign err_empty = ~err_emptyn;

    assign error = err_full || err_empty;

    sync_fifo u_sync_fifo (
        .clk         (clk       ),
        .rst         (svg_rstn  ),
        .wr_data     (i_data    ),
        .wr_en       (href      ),
        .wr_full     (full      ),
        .almost_full (/*unused*/),
        .rd_data     (o_data    ),
        .rd_en       (read_en   ),
        .rd_empty    (empty     ),
        .almost_empty(/*unused*/)
    );

endmodule : hdmi_display
