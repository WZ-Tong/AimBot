module pixel_combine (
    input         rclk    ,
    input         rstn    ,
    output [31:0] pixel   ,
    output        last    ,

    input         inited_1,
    input         pclk_1  ,
    input         href_1  ,
    input  [15:0] data_1  ,

    input         inited_2,
    input         pclk_2  ,
    input         href_2  ,
    input  [15:0] data_2
);

    wire [15:0] pixel_1, pixel_2;
    assign pixel = {pixel_1, pixel_2};

    localparam LINE_PIX = 1280;

    reg [$clog2(LINE_PIX)-1:0] raddr;

    reg last;
    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            raddr <= #1 'b0;
            last  <= #1 'b0;
        end else begin
            if (raddr < LINE_PIX) begin
                raddr <= #1 raddr + 1'b1;
                last  <= #1 'b0;
            end else begin
                raddr <= #1 'b0;
                last  <= #1 'b1;
            end
        end
    end

    // Cam1
    reg [$clog2(LINE_PIX)-1:0] waddr_1;
    always_ff @(posedge pclk_1 or negedge rstn) begin
        if(~rstn) begin
            waddr_1 <= #1 'b0;
        end else begin
            if (href_1) begin
                waddr_1 <= #1 waddr_1 + 1'b1;
            end else begin
                waddr_1 <= #1 'b0;
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

    // Cam2
    reg [$clog2(LINE_PIX)-1:0] waddr_2;
    always_ff @(posedge pclk_2 or negedge rstn) begin
        if(~rstn) begin
            waddr_2 <= #1 'b0;
        end else begin
            if (href_2) begin
                waddr_2 <= #1 waddr_2 + 1'b1;
            end else begin
                waddr_2 <= #1 'b0;
            end
        end
    end

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
