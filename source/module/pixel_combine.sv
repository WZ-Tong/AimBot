module pixel_combine (
    input         rclk    ,
    input         rstn    ,
    input         read_en ,
    output [15:0] pixel_1 ,
    output [15:0] pixel_2 ,
    output        error   ,

    input         inited_1,
    input         pclk_1  ,
    input         href_1  ,
    input  [15:0] data_1  ,

    input         inited_2,
    input         pclk_2  ,
    input         href_2  ,
    input  [15:0] data_2
);

    wire fifo_rst;
    assign fifo_rst = 1'b0;

    wire full_1, empty_1, aempty_1 /*synthesis PAP_MARK_DEBUG="true"*/;
    async_fifo u_sync_1 (
        // Write
        .wr_data     (data_1    ),
        .wr_en       (href_1    ),
        .wr_clk      (pclk_1    ),
        .wr_rst      (fifo_rst  ),
        .wr_full     (full_1    ),
        .almost_full (/*unused*/),
        // Read
        .rd_data     (pixel_1   ),
        .rd_en       (read_en   ),
        .rd_clk      (rclk      ),
        .rd_rst      (fifo_rst  ),
        .rd_empty    (empty_1   ),
        .almost_empty(aempty_1  )
    );

    wire full_2, empty_2, aempty_2 /*synthesis PAP_MARK_DEBUG="true"*/;
    async_fifo u_sync_2 (
        // Write
        .wr_data     (data_2    ),
        .wr_en       (href_2    ),
        .wr_clk      (pclk_2    ),
        .wr_rst      (fifo_rst  ),
        .wr_full     (full_2    ),
        .almost_full (/*unused*/),
        // Read
        .rd_data     (pixel_2   ),
        .rd_en       (read_en   ),
        .rd_clk      (rclk      ),
        .rd_rst      (fifo_rst  ),
        .rd_empty    (empty_2   ),
        .almost_empty(aempty_2  )
    );

    // ErrorGen: FIFO should not be full
    wire errorn;
    rstn_gen #(.TICK(500000)) u_comb_err_gen (
        .clk   (rclk             ),
        .i_rstn(~(full_1||full_2)),
        .o_rstn(errorn           )
    );
    assign error = ~errorn;

endmodule : pixel_combine
