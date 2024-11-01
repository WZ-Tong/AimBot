module line_buffer #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input                                          rstn    ,
    input                                          trig    ,
    input  [3*8+4+$clog2(H_ACT)+$clog2(V_ACT)-1:0] cam_pack,

    input                                          rclk    ,
    output                                         aquire  ,
    input                                          read_en ,
    output [                                  7:0] cam_data,
    output [                                 10:0] cam_row ,
    output                                         busy    ,

    output                                         error
);

    wire       cam_clk  ;
    wire       cam_vsync;
    wire       cam_de   ;
    wire [7:0] cam_r    ;
    wire [7:0] cam_g    ;
    wire [7:0] cam_b    ;
    hdmi_unpack #(
        .H_ACT(H_ACT),
        .V_ACT(V_ACT)
    ) u_cam_unpack (
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

    localparam IDLE         = 3'b000;
    localparam WAIT_VSYNC   = 3'b001;
    localparam WAIT_CAM_1   = 3'b010;
    localparam READ_CAM_1   = 3'b011;
    localparam WAIT_CAM_2   = 3'b100;
    localparam READ_CAM_2   = 3'b101;
    localparam FIFO_READOUT = 3'b110;

    reg [2:0] state;

    wire cam_we;
    assign cam_we = cam_de && state!=IDLE && state!=WAIT_VSYNC;

    wire cam_re;
    reg state_re;
    assign cam_re = read_en || state_re;

    assign busy = state!=IDLE;

    wire cam_ready, cam_readyn, cam_full;
    assign cam_ready = ~cam_readyn;
    assign aquire    = cam_ready;

    wire cam_empty;
    async_fifo_16_8_1280 u_cam_buffer (
        // Write
        .wr_clk      (cam_clk    ),
        .wr_rst      (cam_vsync  ),
        .wr_en       (cam_we     ),
        .wr_data     (cam_data_16),
        .wr_full     (cam_full   ),
        .almost_full (/*unused*/ ),
        // Read
        .rd_clk      (rclk       ),
        .rd_rst      (cam_vsync  ),
        .rd_en       (cam_re     ),
        .rd_data     (cam_data   ),
        .rd_empty    (cam_empty  ),
        .almost_empty(cam_readyn )
    );
    rst_gen #(.TICK(100_000)) u_cam_err_gen (
        .clk  (cam_clk ),
        .i_rst(cam_full),
        .o_rst(error   )
    );

    localparam X_PACK = H_ACT    ; // 1280
    localparam Y_PACK = V_ACT * 2; // 1440

    reg [$clog2(X_PACK)-1:0] x;
    reg [$clog2(Y_PACK)-1:0] y;
    assign cam_row = y;

    reg trig_r;
    always_ff @(posedge rclk or posedge trig) begin
        if(trig) begin
            trig_r <= #1 'b1;
        end else begin
            if (trig_r && state!=IDLE) begin
                trig_r <= #1 'b0;
            end
        end
    end

    reg cam_vsync_r;
    always_ff @(posedge rclk or posedge cam_vsync) begin
        if(cam_vsync) begin
            cam_vsync_r <= #1 'b1;
        end else begin
            if (cam_vsync_r && state!=WAIT_VSYNC) begin
                cam_vsync_r <= #1 'b0;
            end
        end
    end

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            x        <= #1 'b0;
            y        <= #1 'b0;
            state    <= #1 IDLE;
            state_re <= #1 'b0;
        end else begin
            if (state==IDLE) begin
                x <= #1 'b0;
                y <= #1 'b0;
            end else begin
                if (cam_re) begin
                    if (x!=X_PACK-1) begin
                        x <= #1 x + 1'b1;
                    end else begin
                        x <= #1 'b0;
                        if (y!=Y_PACK-1) begin
                            y <= #1 y + 1'b1;
                        end else begin
                            y <= #1 'b0;
                        end
                    end
                end
            end

            state_re <= #1 'b0;
            case (state)
                IDLE : begin
                    if (trig_r) begin
                        state <= #1 WAIT_VSYNC;
                    end
                end
                WAIT_VSYNC : begin
                    if (cam_vsync_r) begin
                        state <= #1 WAIT_CAM_1;
                    end
                end
                WAIT_CAM_1 : begin
                    if (cam_ready) begin
                        state <= #1 READ_CAM_1;
                    end
                end
                READ_CAM_1 : begin
                    if (x==X_PACK-1) begin
                        state <= #1 WAIT_CAM_2;
                    end
                end
                WAIT_CAM_2 : begin
                    if (cam_ready) begin
                        state <= #1 READ_CAM_2;
                    end
                end
                READ_CAM_2 : begin
                    if (x==X_PACK-1) begin
                        state <= #1 FIFO_READOUT;
                    end
                end
                FIFO_READOUT : begin
                    if (cam_empty) begin
                        state_re <= #1 'b0;
                        if (y!=0) begin
                            state <= #1 WAIT_CAM_1;
                        end else begin
                            state <= #1 IDLE;
                        end
                    end else begin
                        state_re <= #1 'b1;
                    end
                end
                default : begin
                    state <= #1 IDLE;
                end
            endcase
        end
    end

endmodule : line_buffer
