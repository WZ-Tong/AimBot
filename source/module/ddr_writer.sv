module ddr_writer (
    input          pix_clk        ,
    input          pix_href       ,
    input          pix_vsync      ,
    input          trig           ,

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

    async_fifo u_pix_buffer (
        .wr_data     (),
        .wr_en       (),
        .wr_clk      (),
        .wr_rst      (),
        .wr_full     (),
        .almost_full (),
        .rd_data     (),
        .rd_en       (),
        .rd_clk      (),
        .rd_rst      (),
        .rd_empty    (),
        .almost_empty()
    );


endmodule : ddr_writer
