module pixel_combine (
    input                         rclk    ,
    input                         rstn    ,
    output [                15:0] pixel_1 ,
    output [                15:0] pixel_2 ,
    output [$clog2(LINE_PIX)-1:0] ahead   ,
    output                        valid   ,
    output                        finish  ,

    input                         inited_1,
    input                         pclk_1  ,
    input                         href_1  ,
    input  [                15:0] data_1  ,

    input                         inited_2,
    input                         pclk_2  ,
    input                         href_2  ,
    input  [                15:0] data_2
);

    wire inited;
    assign inited = inited_1 && inited_2;

    localparam LINE_PIX = 1280;

    wire [$clog2(LINE_PIX)-1:0] head   ;
    reg  [$clog2(LINE_PIX)-1:0] waddr_1, waddr_2, raddr;

    waddr_gen #(.NUM(LINE_PIX)) u_cam1_waddr (
        .clk (pclk_1     ),
        .rstn(rstn&inited),
        .en  (href_1     ),
        .addr(waddr_1    )
    );
    waddr_gen #(.NUM(LINE_PIX)) u_cam2_waddr (
        .clk (pclk_2     ),
        .rstn(rstn&inited),
        .en  (href_2     ),
        .addr(waddr_2    )
    );
    assign head = waddr_1 > waddr_2 ? waddr_1 : waddr_2;
    raddr_gen #(.NUM(LINE_PIX)) u_raddr (
        .clk   (rclk       ),
        .rstn  (rstn&inited),
        .head  (head       ),
        .addr  (raddr      ),
        .valid (valid      ),
        .finish(finish     )
    );
    assign ahead = head - raddr;

    wire cam1_rstn = rstn&inited_1;
    line_buf u_cam1_buf (
        .wr_clk (pclk_1    ),
        .wr_rst (~cam1_rstn),
        .wr_en  (href_1    ),
        .wr_addr(waddr_1   ),
        .wr_data(data_1    ),
        .rd_clk (rclk      ),
        .rd_rst (~rstn     ),
        .rd_addr(raddr     ),
        .rd_data(pixel_1   )
    );

    wire cam2_rstn = rstn&inited_2;
    line_buf u_cam2_buf (
        .wr_clk (pclk_2    ),
        .wr_rst (~cam1_rstn),
        .wr_en  (href_2    ),
        .wr_addr(waddr_2   ),
        .wr_data(data_2    ),
        .rd_clk (rclk      ),
        .rd_rst (~rstn     ),
        .rd_addr(raddr     ),
        .rd_data(pixel_2   )
    );

endmodule : pixel_combine
