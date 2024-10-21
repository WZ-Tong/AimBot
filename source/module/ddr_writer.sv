module ddr_writer (
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

    reg write_rst; // TODO

    wire write_full;

    async_fifo u_pix_buffer (
        // Write
        .wr_clk      (          ),
        .wr_rst      (write_rst ),
        .wr_en       (          ),
        .wr_data     (          ),
        .wr_full     (write_full),
        .almost_full (          ),
        // Read
        .rd_clk      (ddr_clk   ),
        .rd_rst      (          ),
        .rd_en       (          ),
        .rd_data     (          ),
        .rd_empty    (          ),
        .almost_empty(          )
    );

    rst_gen #(.TICK(375_000)) u_err_gen (
        .clk  (pix_clk   ),
        .i_rst(write_full),
        .o_rst(error     )
    );

endmodule : ddr_writer
