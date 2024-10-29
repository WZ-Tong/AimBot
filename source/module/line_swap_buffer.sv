module line_swap_buffer #(
    parameter H_ACT = 1280,
    parameter V_ACT = 720
) (
    input         rstn     ,
    input         trig     ,
    input  [48:0] cam1_pack,
    input  [48:0] cam2_pack,

    input         rclk     ,
    output        aquire     /*synthesis PAP_MARK_DEBUG="true"*/,
    input         read_en    /*synthesis PAP_MARK_DEBUG="true"*/,
    output [ 7:0] cam_data ,
    output [10:0] cam_row  ,
    output [ 4:0] cam_id   ,

    output        error
);

    reg         cam1_trig  ;
    wire        cam1_aquire;
    wire        cam1_re    ;
    wire [ 7:0] cam1_data  ;
    wire [10:0] cam1_row   ;
    wire        cam1_err   ;
    wire        cam1_busy  /*synthesis PAP_MARK_DEBUG="true"*/;
    line_buffer #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_udp_buffer_1 (
        .rstn    (rstn       ),
        .cam_pack(cam1_pack  ),
        .trig    (cam1_trig  ),
        .aquire  (cam1_aquire),
        .rclk    (rclk       ),
        .read_en (cam1_re    ),
        .cam_data(cam1_data  ),
        .cam_row (cam1_row   ),
        .error   (cam1_err   ),
        .busy    (cam1_busy  )
    );

    reg         cam2_trig  ;
    wire        cam2_aquire;
    wire        cam2_re    ;
    wire [ 7:0] cam2_data  ;
    wire [10:0] cam2_row   ;
    wire        cam2_err   ;
    wire        cam2_busy  /*synthesis PAP_MARK_DEBUG="true"*/;
    line_buffer #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_udp_buffer_2 (
        .rstn    (rstn       ),
        .cam_pack(cam2_pack  ),
        .trig    (cam2_trig  ),
        .aquire  (cam2_aquire),
        .rclk    (rclk       ),
        .read_en (cam2_re    ),
        .cam_data(cam2_data  ),
        .cam_row (cam2_row   ),
        .error   (cam2_err   ),
        .busy    (cam2_busy  )
    );

    reg cam_no /*synthesis PAP_MARK_DEBUG="true"*/;
    assign cam_id   = cam_no==0 ? 5'b10000 : 5'b01000;
    assign cam1_re  = cam_no==0 ? read_en : 'b0;
    assign cam2_re  = cam_no==1 ? read_en : 'b0;
    assign aquire   = cam_no==0 ? cam1_aquire : cam2_aquire;
    assign cam_data = cam_no==0 ? cam1_data : cam2_data;
    assign cam_row  = cam_no==0 ? cam1_row : cam2_row;
    assign error    = cam1_err || cam2_err;

    localparam IDLE      = 3'b000;
    localparam TRIG_CAM1 = 3'b001;
    localparam WAIT_CAM1 = 3'b010;
    localparam GAP       = 3'b011;
    localparam TRIG_CAM2 = 3'b100;
    localparam WAIT_CAM2 = 3'b101;

    localparam GAP_WAIT = H_ACT;

    reg [$clog2(GAP_WAIT)-1:0] gap_cnt;

    reg [2:0] state /*synthesis PAP_MARK_DEBUG="true"*/;

    reg trig_d /*synthesis PAP_MARK_DEBUG="true"*/;
    always_ff @(posedge rclk or posedge trig) begin
        if(trig) begin
            trig_d <= #1 'b1;
        end else begin
            if (trig_d && state!=IDLE) begin
                trig_d <= #1 'b0;
            end
        end
    end

    always_ff @(posedge rclk or negedge rstn) begin
        if(~rstn) begin
            cam_no    <= #1 'b0;
            state     <= #1 IDLE;
            cam1_trig <= #1 'b0;
            cam2_trig <= #1 'b0;
            gap_cnt   <= #1 'b0;
        end else begin
            case (state)
                IDLE : begin
                    cam1_trig <= #1 'b0;
                    cam2_trig <= #1 'b0;
                    cam_no    <= #1 'b0;
                    gap_cnt   <= #1 'b0;
                    if (trig_d) begin
                        state <= #1 TRIG_CAM1;
                    end
                end
                TRIG_CAM1 : begin
                    if (cam1_busy) begin
                        cam1_trig <= #1 'b0;
                        state     <= #1 WAIT_CAM1;
                    end else begin
                        cam1_trig <= #1 'b1;
                    end
                end
                WAIT_CAM1 : begin
                    if (~cam1_busy) begin
                        gap_cnt <= #1 'b0;
                        state   <= #1 GAP;
                    end
                end
                GAP : begin
                    if (gap_cnt!=GAP_WAIT) begin
                        gap_cnt <= #1 gap_cnt + 1'b1;
                    end else begin
                        cam_no <= #1 'b1;
                        if (~cam1_busy && ~cam2_busy) begin
                            state <= #1 TRIG_CAM2;
                        end
                    end
                end
                TRIG_CAM2 : begin
                    if (cam2_busy) begin
                        cam2_trig <= #1 'b0;
                        state     <= #1 WAIT_CAM2;
                    end else begin
                        cam2_trig <= #1 'b1;
                    end
                end
                WAIT_CAM2 : begin
                    if (~cam2_busy) begin
                        state <= #1 IDLE;
                    end
                end
                default : begin
                    state <= #1 IDLE;
                end
            endcase
        end
    end


endmodule : line_swap_buffer
