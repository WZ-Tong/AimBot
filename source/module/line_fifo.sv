module line_fifo (
    input         wclk  ,
    input         wrst  ,
    input         wen   ,
    input  [15:0] wdata   /*synthesis PAP_MARK_DEBUG="true"*/,

    input         rclk  ,
    input         ren   ,
    output [ 7:0] rdata   /*synthesis PAP_MARK_DEBUG="true"*/,
    output        rready,

    output        error
);

    wire wfull, aempty;
    async_fifo_16_8_1280 u_cam_buffer (
        // Write
        .wr_clk      (wclk      ),
        .wr_rst      (wrst      ),
        .wr_en       (wen       ),
        .wr_data     (wdata     ),
        .wr_full     (wfull     ),
        .almost_full (/*unused*/),
        // Read
        .rd_clk      (rclk      ),
        .rd_rst      (1'b0      ),
        .rd_en       (ren       ),
        .rd_data     (rdata     ),
        .rd_empty    (/*unused*/),
        .almost_empty(aempty    )
    );

    rst_gen #(.TICK(37_500_000)) u_cam_err_gen (
        .clk  (wclk ),
        .i_rst(wfull),
        .o_rst(error)
    );

    assign rready = ~aempty;

endmodule : line_fifo
