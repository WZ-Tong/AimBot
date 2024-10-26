module line_swap_buffer #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input             rstn     ,
    input      [48:0] cam1_pack,
    input      [48:0] cam2_pack,
    input             trig     ,

    input             rclk     ,
    input             read_en  ,
    output reg        cam_id   ,
    output reg        valid    ,
    output reg [ 7:0] cam_data ,
    output     [ 9:0] cam_row  ,

    output            error
);

    reg wr_rstn;
    reg cam1_re;
    reg cam2_re;

    wire       cam1_clk  ;
    wire       cam1_vsync;
    wire       cam1_de   ;
    wire [7:0] cam1_r    ;
    wire [7:0] cam1_g    ;
    wire [7:0] cam1_b    ;
    hdmi_unpack u_cam1_unpack (
        .pack (cam1_pack ),
        .clk  (cam1_clk  ),
        .vsync(cam1_vsync),
        .de   (cam1_de   ),
        .r    (cam1_r    ),
        .g    (cam1_g    ),
        .b    (cam1_b    )
    );

    wire [15:0] cam1_wdata;
    wire [ 7:0] cam1_rdata;
    assign cam1_wdata = {cam1_r[7:3], cam1_g[7:2], cam1_b[7:3]};

    wire cam1_ready, cam1_full;
    async_fifo_16_8_1280 u_cam1_buffer (
        // Write
        .wr_clk      (cam1_clk  ),
        .wr_rst      (~wr_rstn  ),
        .wr_en       (cam1_de   ),
        .wr_data     (cam1_wdata),
        .wr_full     (cam1_full ),
        .almost_full (cam1_ready),
        // Read
        .rd_clk      (rclk      ),
        .rd_rst      (~wr_rstn  ),
        .rd_en       (cam1_re   ),
        .rd_data     (cam1_rdata),
        .rd_empty    (/*unused*/),
        .almost_empty(/*unused*/)
    );

    wire cam1_error;
    rst_gen #(.TICK(37_500_000)) u_cam1_err_gen (
        .clk  (cam1_clk  ),
        .i_rst(cam1_full ),
        .o_rst(cam1_error)
    );

    wire       cam2_clk  ;
    wire       cam2_vsync;
    wire       cam2_de   ;
    wire [7:0] cam2_r    ;
    wire [7:0] cam2_g    ;
    wire [7:0] cam2_b    ;
    hdmi_unpack u_cam2_unpack (
        .pack (cam2_pack ),
        .clk  (cam2_clk  ),
        .vsync(cam2_vsync),
        .de   (cam2_de   ),
        .r    (cam2_r    ),
        .g    (cam2_g    ),
        .b    (cam2_b    )
    );

    wire [15:0] cam2_wdata;
    wire [ 7:0] cam2_rdata;
    assign cam2_data = {cam2_r[7:3], cam2_g[7:2], cam2_b[7:3]};

    wire cam2_ready, cam2_full;
    async_fifo_16_8_1280 u_cam2_buffer (
        // Write
        .wr_clk      (cam2_clk  ),
        .wr_rst      (~wr_rstn  ),
        .wr_en       (cam2_de   ),
        .wr_data     (cam2_wdata),
        .wr_full     (cam2_full ),
        .almost_full (cam2_ready),
        // Read
        .rd_clk      (rclk      ),
        .rd_rst      (~wr_rstn  ),
        .rd_en       (cam2_re   ),
        .rd_data     (cam2_rdata),
        .rd_empty    (/*unused*/),
        .almost_empty(/*unused*/)
    );

    wire cam2_error;
    rst_gen #(.TICK(37_500_000)) u_cam2_err_gen (
        .clk  (cam2_clk  ),
        .i_rst(cam2_full ),
        .o_rst(cam2_error)
    );

    localparam IDLE       = 3'b000;
    localparam WAIT_VSYNC = 3'b001;
    localparam WAIT_CAM1  = 3'b010;
    localparam READ_CAM1  = 3'b011;
    localparam WAIT_CAM2  = 3'b100;
    localparam READ_CAM2  = 3'b101;

    reg [2:0] state;

    reg [$clog2(H_ACT):0] x;
    reg [$clog2(V_ACT):0] y;
    assign cam_row = y;

    reg cvs_err, cam1_vsync_d, cam2_vsync_d;

    wire cam1_vsync_f, cam2_vsync_f;
    assign cam1_vsync_f = cam1_vsync_d==1 && cam1_vsync==0;
    assign cam2_vsync_f = cam2_vsync_d==1 && cam2_vsync==0;

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            cvs_err <= #1 'b0;
            state   <= #1 IDLE;
            cam1_re <= #1 'b0;
            cam2_re <= #1 'b0;
            cam_id  <= #1 'b0;
        end else begin
            case (state)
                IDLE : begin
                    cam_id  <= #1 'b0;
                    cvs_err <= #1 'b0;
                    wr_rstn <= #1 'b0;
                    cam1_re <= #1 'b0;
                    cam2_re <= #1 'b0;
                    if (trig) begin
                        state        <= #1 WAIT_VSYNC;
                        cam1_vsync_d <= #1 'b0;
                        cam2_vsync_d <= #1 'b0;
                    end
                end
                WAIT_VSYNC : begin
                    cam_id       <= #1 'b0;
                    cam1_re      <= #1 'b0;
                    cam2_re      <= #1 'b0;
                    cam1_vsync_d <= #1 cam1_vsync;
                    cam2_vsync_d <= #1 cam2_vsync;
                    wr_rstn      <= #1 'b1;
                    if ((cam1_vsync_f&&(~cam2_vsync_f)) || (cam2_vsync_f&&(~cam1_vsync_f))) begin
                        state   <= #1 IDLE;
                        cvs_err <= #1 'b1;
                    end else if (cam1_vsync&&cam2_vsync) begin
                        y     <= #1 'b0;
                        state <= #1 WAIT_CAM1;
                    end
                end
                WAIT_CAM1 : begin
                    x       <= #1 'b0;
                    cam_id  <= #1 'b0;
                    cam2_re <= #1 'b0;
                    if (cam1_ready) begin
                        state <= #1 READ_CAM1;
                    end
                end
                READ_CAM1 : begin
                    cam_id  <= #1 'b0;
                    cam2_re <= #1 'b0;
                    if (read_en && x!=H_ACT-1) begin
                        cam1_re <= #1 'b1;
                    end else begin
                        cam1_re <= #1 'b0;
                    end
                    if (cam1_re) begin
                        valid    <= #1 'b1;
                        cam_data <= #1 cam1_rdata;
                        if (x==H_ACT-1) begin
                            state <= #1 WAIT_CAM2;
                        end else begin
                            x <= #1 x + 1'b1;
                        end
                    end else begin
                        valid <= #1 'b0;
                    end
                end
                WAIT_CAM2 : begin
                    x       <= #1 'b0;
                    cam_id  <= #1 'b1;
                    cam1_re <= #1 'b0;
                    if (cam2_ready) begin
                        state <= #1 READ_CAM2;
                    end
                end
                READ_CAM2 : begin
                    cam_id  <= #1 'b1;
                    cam1_re <= #1 'b0;
                    if (read_en && x!=H_ACT-1) begin
                        cam2_re <= #1 'b1;
                    end else begin
                        cam2_re <= #1 'b0;
                    end
                    if (cam2_re) begin
                        valid    <= #1 'b1;
                        cam_data <= #1 cam2_rdata;
                        if (x==H_ACT-1) begin
                            if (y==V_ACT-1) begin
                                state <= #1 IDLE;
                            end else begin
                                y     <= #1 y + 1'b1;
                                state <= #1 WAIT_CAM1;
                            end
                        end else begin
                            x <= #1 x + 1'b1;
                        end
                    end else begin
                        valid <= #1 'b0;
                    end
                end
                default : begin
                    state <= #1 IDLE;
                end
            endcase
        end
    end

    wire cam_vsync_err;
    rst_gen #(.TICK(125_000_000)) u_cam_vsync_err_gen (
        .clk  (rclk         ),
        .i_rst(cvs_err      ),
        .o_rst(cam_vsync_err)
    );
    assign error = cam1_error || cam2_error || cam_vsync_err;

endmodule : line_swap_buffer
