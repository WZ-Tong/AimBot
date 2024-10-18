module pixel_combine (
    input             rclk      /*synthesis PAP_MARK_DEBUG="true"*/,
    input             rstn    ,
    output     [15:0] pixel_1 ,
    output     [15:0] pixel_2 ,
    output            valid     /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg        error     /*synthesis PAP_MARK_DEBUG="true"*/,

    input             inited_1,
    input             pclk_1    /*synthesis PAP_MARK_DEBUG="true"*/,
    input             href_1    /*synthesis PAP_MARK_DEBUG="true"*/,
    input      [15:0] data_1  ,

    input             inited_2,
    input             pclk_2    /*synthesis PAP_MARK_DEBUG="true"*/,
    input             href_2    /*synthesis PAP_MARK_DEBUG="true"*/,
    input      [15:0] data_2
);

    reg read_en /*synthesis PAP_MARK_DEBUG="true"*/;
    assign valid = read_en;

    reg fifo_rst /*synthesis PAP_MARK_DEBUG="true"*/;

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

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            fifo_rst <= #1 'b1;
        end else begin
            if (href_1==0 && href_2==0 && empty_1 && empty_2) begin
                fifo_rst <= #1 'b1;
            end else begin
                fifo_rst <= #1 'b0;
            end
        end
    end

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            error <= #1 'b0;
        end else begin
            error <= #1 full_1 || full_2;
        end
    end

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            read_en <= #1 'b0;
        end else begin
            if (read_en) begin
                if (empty_1 || empty_2) begin
                    read_en <= #1 'b0;
                end
            end begin
                if (~aempty_1 && ~aempty_2) begin
                    read_en <= #1 'b1;
                end
            end
        end
    end

endmodule : pixel_combine
