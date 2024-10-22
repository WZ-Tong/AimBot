module ov5640_reader (
    input         clk25   ,
    input         rstn    ,

    input         vsync   ,
    input         href    ,
    input         pclk    ,
    input  [ 7:0] data    ,

    output        inited  ,
    output        href_565,
    output        pclk_565,
    output [15:0] data_565,

    // Configure
    inout         cfg_scl ,
    inout         cfg_sda ,
    output        cfg_rstn
);

    wire cfg_clk;
    assign cfg_clk = clk25;

    localparam CFG_RSTN_HOLD = 25_000_000;
    localparam H_SYNC_ACTIVE = 1'b1            ;

    rstn_gen #(.TICK(CFG_RSTN_HOLD)) cam_cfg_rstn_gen (
        .clk   (cfg_clk ),
        .i_rstn(rstn    ),
        .o_rstn(cfg_rstn)
    );

    reg_config cam_reg_config (
        .clk_25M      (cfg_clk   ),
        .camera_rstn  (cfg_rstn  ),
        .initial_en   (/*unused*/),
        .reg_conf_done(inited    ),
        .i2c_sclk     (cfg_scl   ),
        .i2c_sdat     (cfg_sda   ),
        .clock_20k    (/*unused*/),
        .reg_index    (/*unused*/)
    );

    reg [7:0] data_d;

    reg vsync_d, href_d;

    always_ff @(posedge pclk) begin
        data_d  <= #1 data ;
        vsync_d <= #1 vsync;
        href_d  <= #1 href ;
    end

    cmos_8_16bit cam_pix_reader (
        .pclk     (pclk    ),
        .rst_n    (inited  ),
        .pdata_i  (data_d  ),
        .de_i     (href_d  ),
        .vs_i     (vsync_d ),
        .pixel_clk(pclk_565),
        .pdata_o  (data_565),
        .de_o     (href_565)
    );

endmodule : ov5640_reader
