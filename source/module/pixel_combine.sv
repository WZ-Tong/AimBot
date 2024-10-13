module pixel_combine (
    input         rclk    ,
    input         rstn    ,
    output [15:0] pixel_1 ,
    output [15:0] pixel_2 ,
    output        valid   ,

    input         inited_1,
    input         pclk_1  ,
    input         href_1  ,
    input  [15:0] data_1  ,

    input         inited_2,
    input         pclk_2  ,
    input         href_2  ,
    input  [15:0] data_2
);

    wire inited;
    assign inited = inited_1 && inited_2;

    localparam LINE_PIX = 1280;

    reg [$clog2(LINE_PIX)-1:0] waddr_1;
    always_ff @(posedge pclk_1 or negedge rstn) begin
        if (~rstn || ~inited) begin
            waddr_1 <= #1 'b0;
        end else begin
            if (href_1) begin
                waddr_1 <= #1 waddr_1 + 1'b1;
            end else begin
                waddr_1 <= #1 'b0;
            end
        end
    end

    reg [$clog2(LINE_PIX)-1:0] waddr_2;
    always_ff @(posedge pclk_2 or negedge rstn) begin
        if (~rstn || ~inited) begin
            waddr_2 <= #1 'b0;
        end else begin
            if (href_2) begin
                waddr_2 <= #1 waddr_2 + 1'b1;
            end else begin
                waddr_2 <= #1 'b0;
            end
        end
    end

    wire valid_w;
    assign valid_w = raddr<waddr_1 && raddr<waddr_2;

    reg valid_d;
    assign valid = valid_d;

    reg [$clog2(LINE_PIX)-1:0] raddr;
    always_ff @(posedge rclk or negedge rstn) begin
        if (~rstn || ~inited) begin
            raddr   <= #1 'b0;
            valid_d <= #1 'b0;
        end else begin
            valid_d <= #1 valid_w;
            if (raddr<LINE_PIX && valid_d) begin
                raddr <= #1 raddr + 1'b1;
            end else begin
                raddr <= #1 'b0;
            end
        end
    end

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
