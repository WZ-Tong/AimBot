module ddr_writer (
    input          rstn           ,
    input          trig           ,

    input          cam1_pclk      ,
    input          cam1_href      ,
    input          cam1_vsync     ,
    input  [ 15:0] cam1_data      ,

    input          cam2_pclk      ,
    input          cam2_href      ,
    input          cam2_vsync     ,
    input  [ 15:0] cam2_data      ,

    output         error          ,

    input          ddr_clk        ,

    // Write address
    output [ 27:0] axi_awaddr     ,
    output [  3:0] axi_awlen      ,
    input          axi_awready    ,
    output         axi_awvalid    ,

    // Write data
    output [255:0] axi_wdata      ,
    output [ 31:0] axi_wstrb      ,
    input          axi_wready     ,
    input          axi_wusero_last
);

    localparam BLINK_TICK  = 375_000;
    localparam FRAME_TOTAL = 5596992;

    reg [$clog2(FRAME_TOTAL)-1:0] r1_cnt;

    reg  w1_rst ;
    wire w1_full, r1_empty;
    always_ff @(posedge cam1_pclk or negedge rstn) begin
        if(~rstn) begin
            w1_rst <= #1 'b1;
        end else begin
            if (w1_rst=='b1) begin
                if (cam1_vsync=='b1) begin
                    w1_rst <= #1 'b0;
                end
            end else begin
                if (r1_cnt!=FRAME_TOTAL-1) begin
                    r1_cnt <= #1 r1_cnt + 1'b1;
                end else begin
                    if (r1_empty) begin
                        w1_rst <= #1 'b1;
                    end
                end
            end
        end
    end

    async_fifo u_pix_buffer (
        // Write
        .wr_clk      (cam1_pclk ),
        .wr_rst      (w1_rst    ),
        .wr_en       (cam1_href ),
        .wr_data     (cam1_data ),
        .wr_full     (w1_full   ),
        .almost_full (/*unused*/),
        // Read
        .rd_clk      (ddr_clk   ),
        .rd_rst      (          ),
        .rd_en       (          ),
        .rd_data     (          ),
        .rd_empty    (r1_empty  ),
        .almost_empty(/*unused*/)
    );

    rst_gen #(.TICK(BLINK_TICK)) u_err_gen (
        .clk  (pix_clk),
        .i_rst(w1_full),
        .o_rst(error  )
    );

endmodule : ddr_writer
