module pixel_combine (
    input             rclk    ,
    input             rstn    ,
    output     [15:0] pixel_1 ,
    output     [15:0] pixel_2 ,
    output            valid   ,
    output reg        error     /*synthesis PAP_MARK_DEBUG="true"*/,

    input             inited_1,
    input             hsync_1 ,
    input             pclk_1  ,
    input             href_1  ,
    input      [15:0] data_1  ,

    input             inited_2,
    input             hsync_2 ,
    input             pclk_2  ,
    input             href_2  ,
    input      [15:0] data_2
);

    localparam H_SYNC_ACTIVE = 1'b1;

    reg re;
    assign valid = re /*synthesis PAP_MARK_DEBUG="true"*/;

    wire rst_1, rst_2 /*synthesis PAP_MARK_DEBUG="true"*/;
    reg rst_1_d, rst_2_d /*synthesis PAP_MARK_DEBUG="true"*/;

    assign rst_1 = (~inited_1) || (hsync_1==H_SYNC_ACTIVE);
    assign rst_2 = (~inited_2) || (hsync_2==H_SYNC_ACTIVE);

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            rst_1_d <= #1 'b1;
            rst_2_d <= #1 'b1;
        end else begin
            rst_1_d <= #1 rst_1;
            rst_2_d <= #1 rst_2;
        end
    end

    wire full_1, empty_1, aempty_1 /*synthesis PAP_MARK_DEBUG="true"*/;
    async_fifo u_sync_1 (
        // Write
        .wr_data     (data_1    ),
        .wr_en       (href_1    ),
        .wr_clk      (pclk_1    ),
        .wr_rst      (rst_1     ),
        .wr_full     (full_1    ),
        .almost_full (/*unused*/),
        // Read
        .rd_data     (pixel_1   ),
        .rd_en       (re        ),
        .rd_clk      (rclk      ),
        .rd_rst      (rst_1_d   ),
        .rd_empty    (empty_1   ),
        .almost_empty(aempty_1  )
    );

    wire full_2, empty_2, aempty_2 /*synthesis PAP_MARK_DEBUG="true"*/;
    async_fifo u_sync_2 (
        // Write
        .wr_data     (data_2    ),
        .wr_en       (href_2    ),
        .wr_clk      (pclk_2    ),
        .wr_rst      (rst_2     ),
        .wr_full     (full_2    ),
        .almost_full (/*unused*/),
        // Read
        .rd_data     (pixel_2   ),
        .rd_en       (re        ),
        .rd_clk      (rclk      ),
        .rd_rst      (rst_2_d   ),
        .rd_empty    (empty_2   ),
        .almost_empty(aempty_2  )
    );

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            error <= #1 'b0;
        end else begin
            error <= #1 full_1 || full_2;
        end
    end

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            re <= #1 'b0;
        end else begin
            if (re) begin
                if (empty_1 || empty_2) begin
                    re <= #1 'b0;
                end
            end begin
                if (~aempty_1 && ~aempty_2) begin
                    re <= #1 'b1;
                end
            end
        end
    end

endmodule : pixel_combine
