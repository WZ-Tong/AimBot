module ddr_writer (
    input          pix_clk        ,
    input          pix_href       ,
    input          pix_vsync      ,
    input          trig           ,

    input          ddr_clk        ,

    // Write address
    output [ 27:0] axi_awaddr     ,
    output         axi_awuser_ap  ,
    output [  3:0] axi_awuser_id  ,
    output [  3:0] axi_awlen      ,
    input          axi_awready    ,
    output         axi_awvalid    ,

    // Write data
    output [255:0] axi_wdata      ,
    output [ 31:0] axi_wstrb      ,
    input          axi_wready     ,
    input  [  3:0] axi_wusero_id  ,
    input          axi_wusero_last
);

    assign axi_awuser_ap = 1'bz;
    assign axi_awuser_id = 4'bz;
    assign axi_wusero_id = 4'bz;

    

endmodule : ddr_writer
