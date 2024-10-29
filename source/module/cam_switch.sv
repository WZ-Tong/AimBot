module cam_switch #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720 ,
    parameter DELAY = 5   ,
    parameter TICK  = 5
) (
    input                                          rstn      ,
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] main_pack ,
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] minor_pack,
    input                                          switch_key,
    output [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] pack
);

    // Note: Ensured: main cam is later than minor cam

    wire cam_id;
    key_to_switch #(
        .TICK(TICK),
        .INIT(1'b1)
    ) u_cam_id_gen (
        .clk   (main_clk  ),
        .rstn  (rstn      ),
        .key   (switch_key),
        .switch(cam_id    )
    );

    wire                     main_clk  ;
    wire                     main_hsync;
    wire                     main_vsync;
    wire                     main_de   ;
    wire [              7:0] main_r    ;
    wire [              7:0] main_g    ;
    wire [              7:0] main_b    ;
    wire [$clog2(H_ACT)-1:0] main_x    ;
    wire [$clog2(V_ACT)-1:0] main_y    ;
    hdmi_unpack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_main_unpack (
        .pack (main_pack ),
        .clk  (main_clk  ),
        .hsync(main_hsync),
        .vsync(main_vsync),
        .de   (main_de   ),
        .r    (main_r    ),
        .g    (main_g    ),
        .b    (main_b    ),
        .x    (main_x    ),
        .y    (main_y    )
    );

    async_fifo_lite u_pack_sync (
        // Write
        .wr_clk      (main_clk  ),
        .wr_rst      (main_vsync),
        .wr_en       (          ),
        .wr_data     (          ),
        .wr_full     (          ),
        .almost_full (          ),
        // Read
        .rd_clk      (          ),
        .rd_rst      (main_vsync),
        .rd_en       (          ),
        .rd_data     (          ),
        .rd_empty    (          ),
        .almost_empty(          )
    );


endmodule : cam_switch
