module line_buffer #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input         rstn    ,
    input         trig    ,
    input  [48:0] cam_pack,

    input         rclk    ,
    output        aquire    /*synthesis PAP_MARK_DEBUG="true"*/,
    input         read_en   /*synthesis PAP_MARK_DEBUG="true"*/,
    output [15:0] cam_data,
    output [10:0] cam_row ,
    output        busy    ,

    output        error
);

    wire       cam_clk  ;
    wire       cam_vsync;
    wire       cam_de   ;
    wire [7:0] cam_r    ;
    wire [7:0] cam_g    ;
    wire [7:0] cam_b    ;
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

    localparam IDLE       = 2'b00;
    localparam WAIT_VSYNC = 2'b01;
    localparam WAIT_CAM   = 2'b10;
    localparam READ_CAM   = 2'b11;

    reg [1:0] state /*synthesis PAP_MARK_DEBUG="true"*/;

    wire cam_re /*synthesis PAP_MARK_DEBUG="true"*/;
    assign cam_re = cam_de&&state!=IDLE&&state!=WAIT_VSYNC;
    assign busy   = state!=IDLE;

    wire cam_ready, cam_readyn, cam_full;
    rst_gen #(.TICK(100_000)) u_cam_err_gen (
        .clk  (cam_clk ),
        .i_rst(cam_full),
        .o_rst(error   )
    );
    assign cam_ready = ~cam_readyn;
    assign aquire    = cam_ready;
    async_fifo_16_1280 u_cam_buffer (
        // Write
        .wr_clk      (cam_clk    ),
        .wr_rst      (cam_vsync  ),
        .wr_en       (cam_re     ),
        .wr_data     (cam_data_16),
        .wr_full     (cam_full   ),
        .almost_full (/*unused*/ ),
        // Read
        .rd_clk      (rclk       ),
        .rd_rst      (cam_vsync  ),
        .rd_en       (read_en    ),
        .rd_data     (cam_data   ),
        .rd_empty    (/*unused*/ ),
        .almost_empty(cam_readyn )
    );

    localparam X_PACK = H_ACT; // 1280
    localparam Y_PACK = V_ACT; // 720

    reg [$clog2(X_PACK)-1:0] x; // [10:0]
    reg [$clog2(Y_PACK)-1:0] y; // [10:0]
    assign cam_row = y;

    wire x_end, y_end;
    assign x_end = x>=X_PACK-1;
    assign y_end = y>=Y_PACK-1;

    reg trig_r /*synthesis PAP_MARK_DEBUG="true"*/;
    always_ff @(posedge rclk or posedge trig) begin
        if(trig) begin
            trig_r <= #1 'b1;
        end else begin
            if (trig_r && state!=IDLE) begin
                trig_r <= #1 'b0;
            end
        end
    end

    reg cam_vsync_r /*synthesis PAP_MARK_DEBUG="true"*/;
    always_ff @(posedge rclk or posedge cam_vsync) begin
        if(cam_vsync) begin
            cam_vsync_r <= #1 'b1;
        end else begin
            if (cam_vsync_r && state!=WAIT_VSYNC) begin
                cam_vsync_r <= #1 'b0;
            end
        end
    end

    reg read_en_d, read_en_dd;
    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            read_en_d  <= #1 'b0;
            read_en_dd <= #1 'b0;
        end else begin
            read_en_d  <= #1 read_en;
            read_en_dd <= #1 read_en_d;
        end
    end

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            x     <= #1 'b0;
            y     <= #1 'b0;
            state <= #1 IDLE;
        end else begin
            if (state==IDLE) begin
                x <= #1 'b0;
                y <= #1 'b0;
            end else begin
                if (read_en) begin
                    x <= #1 x_end ? 'b0 : (x + 1'b1);
                end
                if (read_en_dd==1 && read_en_d==0 && read_en==0) begin
                    y <= #1 y_end ? 'b0 : (y + 1'b1);
                end
            end

            if (cam_vsync_r) begin
                state <= #1 IDLE;
            end else begin
                case (state)
                    IDLE : begin
                        if (trig_r) begin
                            state <= #1 WAIT_VSYNC;
                        end
                    end
                    WAIT_VSYNC : begin
                        if (cam_vsync_r) begin
                            state <= #1 WAIT_CAM;
                        end
                    end
                    WAIT_CAM : begin
                        if (cam_ready) begin
                            state <= #1 READ_CAM;
                        end
                    end
                    READ_CAM : begin
                        case ({x_end, y_end})
                            2'b10 : begin
                                state <= #1 WAIT_CAM;
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
    end

endmodule : line_buffer
