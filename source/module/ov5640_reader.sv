module ov5640_reader (
    input         clk25    ,
    input         rstn     ,

    output [15:0] rgb_565  ,
    output        href     ,

    inout         cam_scl  ,
    inout         cam_sda  ,
    input         cam_vsync,
    input         cam_href ,
    input         cam_pclk ,
    input  [ 7:0] cam_data ,
    output        cam_rstn
);

    wire cam_cfg_clk;
    assign cam_cfg_clk = clk25;

    localparam CAM_RSTN_HOLD = 'h40000 + 'hffff;

    wire cam_rstn;
    rstn_async_hold #(.TICK(CAM_RSTN_HOLD)) cam_rstn_hold (
        .clk   (cam_cfg_clk),
        .i_rstn(rstn       ),
        .o_rstn(cam_rstn   )
    );

    wire cam_inited;
    reg_config cam_reg_config (
        .clk_25M      (cam_cfg_clk ),
        .camera_rstn  (cam_rstn    ),
        .initial_en   (/* unused */),
        .reg_conf_done(cam_inited  ),
        .i2c_sclk     (cam_scl     ),
        .i2c_sdat     (cam_sda     ),
        .clock_20k    (/* unused */),
        .reg_index    (/* unused */)
    );

    reg [7:0] cam_data_d;

    reg cam_vsync_d, cam_href_d;

    always_ff @(posedge cam_pclk) begin
        cam_data_d  <= #1 cam_data ;
        cam_vsync_d <= #1 cam_vsync;
        cam_href_d  <= #1 cam_href ;
    end

    wire cam_pclk_16;
    wire cam_href_16;

    wire [15:0] cam_pix_565;
    wire [15:0] cam_rgb_565;
    assign cam_rgb_565 = {cam_pix_565[4:0], cam_pix_565[10:5], cam_pix_565[15:11]};

    cmos_8_16bit cam_color_converter (
        .pclk     (cam_pclk   ),
        .rst_n    (cam_inited ),
        .pdata_i  (cam_data_d ),
        .de_i     (cam_href_d ),
        .vs_i     (cam_vsync_d),
        .pixel_clk(cam_pclk_16),
        .pdata_o  (cam_pix_565),
        .de_o     (cam_href_16)
    );

    assign href = cam_href_16;

endmodule : ov5640_reader
