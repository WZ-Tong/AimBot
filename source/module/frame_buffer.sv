module frame_buffer (
    input         rstn     ,
    input  [48:0] cam1_pack,
    input  [48:0] cam2_pack,
    input         trig     ,

    input         rclk     ,
    input         read_en  ,
    output        cam_id   ,
    output [15:0] cam1_data,
    output [15:0] cam2_data,

    output        error
);

    // FIFO control
    reg wr_rstn;
    reg read_id;
    reg cam1_re;

    wire        cam1_clk  ;
    wire        cam1_vsync;
    wire        cam1_de   ;
    wire [ 7:0] cam1_r    ;
    wire [ 7:0] cam1_g    ;
    wire [ 7:0] cam1_b    ;
    hdmi_unpack u_cam1_unpack (
        .pack (cam1_pack ),
        .clk  (cam1_clk  ),
        .vsync(cam1_vsync),
        .de   (cam1_de   ),
        .r    (cam1_r    ),
        .g    (cam1_g    ),
        .b    (cam1_b    )
    );

    wire [15:0] cam1_data ;
    assign cam1_data = {cam1_r[7:3], cam1_g[7:2], cam1_b[7:3]};

    wire cam1_ready, cam1_full;
    async_fifo u_cam1_buffer (
        // Write
        .wr_clk      (cam1_clk  ),
        .wr_rst      (~wr_rstn  ),
        .wr_en       (cam1_de   ),
        .wr_data     (cam1_data ),
        .wr_full     (cam1_full ),
        .almost_full (cam1_ready),
        // Read
        .rd_clk      (rclk      ),
        .rd_rst      (~wr_rstn  ),
        .rd_en       (cam1_re   ),
        .rd_data     (cam1_data ),
        .rd_empty    (/*unused*/),
        .almost_empty(/*unused*/)
    );

    wire cam1_error;
    rst_gen #(.TICK(37_500_000)) u_cam1_err_gen (
        .clk  (cam1_clk ),
        .i_rst(cam1_full),
        .o_rst(cam1_error)
    );

    wire        cam2_clk  ;
    wire        cam2_vsync;
    wire        cam2_de   ;
    wire [ 7:0] cam2_r    ;
    wire [ 7:0] cam2_g    ;
    wire [ 7:0] cam2_b    ;
    hdmi_unpack u_cam2_unpack (
        .pack (cam2_pack ),
        .clk  (cam2_clk  ),
        .vsync(cam2_vsync),
        .de   (cam2_de   ),
        .r    (cam2_r    ),
        .g    (cam2_g    ),
        .b    (cam2_b    )
    );

    wire [15:0] cam2_data ;
    assign cam2_data = {cam2_r[7:3], cam2_g[7:2], cam2_b[7:3]};

    wire cam2_ready, cam2_full;
    async_fifo u_cam2_buffer (
        // Write
        .wr_clk      (cam2_clk  ),
        .wr_rst      (~wr_rstn  ),
        .wr_en       (cam2_de   ),
        .wr_data     (cam2_data ),
        .wr_full     (cam2_full ),
        .almost_full (cam2_ready),
        // Read
        .rd_clk      (rclk      ),
        .rd_rst      (~wr_rstn  ),
        .rd_en       (cam2_re   ),
        .rd_data     (cam2_data ),
        .rd_empty    (/*unused*/),
        .almost_empty(/*unused*/)
    );

    wire cam2_error;
    rst_gen #(.TICK(37_500_000)) u_cam2_err_gen (
        .clk  (cam2_clk ),
        .i_rst(cam2_full),
        .o_rst(cam2_error)
    );

    // TODO
    reg cam1_vsyncing, cam2_vsyncing;
    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin

        end else begin

        end
    end

    assign error = cam1_error || cam2_error;

endmodule : frame_buffer
