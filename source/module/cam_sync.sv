module cam_sync (
    input         cam_clk    ,
    input  [15:0] cam_data   ,
    input         cam_href   ,
    input         cam_vsync  ,
    input         sys_clk    ,
    input         sys_read_en,
    output [15:0] sys_data
);

    async_fifo u_sync (
        .wr_clk      (cam_clk    ),
        .wr_rst      (cam_vsync  ),
        .wr_en       (cam_href   ),
        .wr_data     (cam_data   ),
        .wr_full     (/*unused*/ ),
        .almost_full (/*unused*/ ),
        .rd_clk      (sys_clk    ),
        .rd_rst      (cam_vsync  ),
        .rd_en       (sys_read_en),
        .rd_data     (sys_data   ),
        .rd_empty    (/*unused*/ ),
        .almost_empty(/*unused*/ )
    );

endmodule : cam_sync
