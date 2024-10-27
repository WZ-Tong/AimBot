module line_buffer #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input             clk     ,
    input             rstn    ,
    input      [48:0] cam_pack,

    input             trig      /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg        aquire    /*synthesis PAP_MARK_DEBUG="true"*/,

    input             rclk    ,
    input             read_en ,
    output     [ 7:0] cam_data,
    output     [ 9:0] cam_row ,

    output            error
);

    reg wr_rstn;

    wire       cam_clk   /*synthesis PAP_MARK_DEBUG="true"*/;
    wire       cam_vsync /*synthesis PAP_MARK_DEBUG="true"*/;
    wire       cam_de    /*synthesis PAP_MARK_DEBUG="true"*/;
    wire [7:0] cam_r;
    wire [7:0] cam_g;
    wire [7:0] cam_b;
    hdmi_unpack u_cam_unpack (
        .pack (cam_pack ),
        .clk  (cam_clk  ),
        .vsync(cam_vsync),
        .de   (cam_de   ),
        .r    (cam_r    ),
        .g    (cam_g    ),
        .b    (cam_b    )
    );

    wire [15:0] cam_data_16;
    assign cam_data_16 = {cam_r[7:3], cam_g[7:2], cam_b[7:3]};

    wire cam_ready, cam_full /*synthesis PAP_MARK_DEBUG="true"*/;
    async_fifo_16_8_1280 u_cam_buffer (
        // Write
        .wr_clk      (cam_clk    ),
        .wr_rst      (~wr_rstn   ),
        .wr_en       (cam_de     ),
        .wr_data     (cam_data_16),
        .wr_full     (cam_full   ),
        .almost_full (cam_ready  ),
        // Read
        .rd_clk      (rclk       ),
        .rd_rst      (~wr_rstn   ),
        .rd_en       (read_en    ),
        .rd_data     (cam_data   ),
        .rd_empty    (/*unused*/ ),
        .almost_empty(/*unused*/ )
    );

    rst_gen #(.TICK(37_500_000)) u_cam_err_gen (
        .clk  (cam_clk ),
        .i_rst(cam_full),
        .o_rst(error   )
    );

    localparam IDLE       = 2'b00;
    localparam WAIT_VSYNC = 2'b01;
    localparam WAIT_CAM   = 2'b10;
    localparam READ_CAM   = 2'b11;

    reg [1:0] state /*synthesis PAP_MARK_DEBUG="true"*/;

    reg [$clog2(H_ACT):0] x;
    reg [$clog2(V_ACT):0] y;

    wire x_end, y_end;
    assign x_end = x>=H_ACT-1;
    assign y_end = y>=V_ACT-1;

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            x <= #1 'b0;
            y <= #1 'b0;
        end else begin
            if (read_en) begin
                if (x_end) begin
                    x <= #1 'b0;
                    if (y_end) begin
                        y <= #1 'b0;
                    end else begin
                        y <= #1 y + 1'b1;
                    end
                end else begin
                    x <= #1 x + 1'b1;
                end
            end
        end
    end

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            state   <= #1 IDLE;
            wr_rstn <= #1 'b0;
            aquire  <= #1 'b0;
        end else begin
            case (state)
                IDLE : begin
                    wr_rstn <= #1 'b0;
                    aquire  <= #1 'b0;
                    if (trig) begin
                        state <= #1 WAIT_VSYNC;
                    end
                end
                WAIT_VSYNC : begin
                    aquire <= #1 'b0;
                    if (cam_vsync) begin
                        wr_rstn <= #1 'b1;
                        state   <= #1 WAIT_CAM;
                    end else begin
                        wr_rstn <= #1 'b0;
                    end
                end
                WAIT_CAM : begin
                    wr_rstn <= #1 'b1;
                    if (cam_ready) begin
                        state  <= #1 READ_CAM;
                        aquire <= #1 'b1;
                    end else begin
                        aquire <= #1 'b0;
                    end
                end
                READ_CAM : begin
                    aquire <= #1 'b1;
                    case ({x_end, y_end})
                        2'b10 : begin
                            wr_rstn <= #1 'b0;
                            state   <= #1 WAIT_CAM;
                        end
                        2'b11 : begin
                            state <= #1 IDLE;
                        end
                        default : begin end
                    endcase
                end
                default : begin
                    state <= #1 IDLE;
                end
            endcase
        end
    end

endmodule : line_buffer
