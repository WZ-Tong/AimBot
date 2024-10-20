module hdmi_display (
    input         clk    ,
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

    sync_gen #(
        .THRESH (),
        .DELAY  (),
        .V_FP   (),
        .V_SYNC (),
        .V_BP   (),
        .H_FP   (),
        .H_SYNC (),
        .H_BP   (),
        .V_BLANK(),
        .H_BLANK()
    ) u_sync_gen (
        .clk    (clk    ),
        .rstn   (rstn   ),
        .href   (href   ),
        .vsync  (vsync  ),
        .hsync  (hsync  ),
        .data_en(data_en),
        .x      (x      ),
        .y      (y      ),
        .read_en(read_en)
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
        .clk   (clk      ),
        .i_rstn(~empty    ),
        .o_rstn(err_emptyn)
    );
    assign err_empty = ~err_emptyn;

    assign error = err_full || err_empty;

    sync_fifo u_sync_fifo (
        .clk         (clk       ),
        .rst         (rstn      ),
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
