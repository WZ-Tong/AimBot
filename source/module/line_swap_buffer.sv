module line_swap_buffer #(
    parameter  H_ACT       = 1280                             ,
    parameter  V_ACT       = 720                              ,
    parameter  DEAFULT_CAM = 1                                ,

    localparam PACK_SIZE   = 3*8+4+$clog2(H_ACT)+$clog2(V_ACT)
) (
    input                      rstn     ,
    input                      trig     ,
    input      [PACK_SIZE-1:0] cam1_pack,
    input      [PACK_SIZE-1:0] cam2_pack,

    input                      rclk     ,
    output                     aquire   ,
    input                      read_en  ,
    output     [          7:0] cam_data ,
    output     [         10:0] cam_row  ,
    output                     cam_id   ,
    output reg [          3:0] cnt      ,

    output                     busy     ,
    output                     error
);

    reg cam_id  ;
    reg cam_trig;

    wire [PACK_SIZE-1:0] cam_pack;
    assign cam_pack = cam_id==DEAFULT_CAM ? cam1_pack : cam2_pack;

    wire buf_busy;
    line_buffer #(.H_ACT(H_ACT), .V_ACT(V_ACT)) u_udp_buffer (
        .rstn    (rstn    ),
        .cam_pack(cam_pack),
        .trig    (cam_trig),
        .aquire  (aquire  ),
        .rclk    (rclk    ),
        .read_en (read_en ),
        .cam_data(cam_data),
        .cam_row (cam_row ),
        .error   (error   ),
        .busy    (buf_busy)
    );

    localparam IDLE      = 3'b000;
    localparam TRIG_CAM1 = 3'b001;
    localparam WAIT_CAM1 = 3'b010;
    localparam GAP       = 3'b011;
    localparam TRIG_CAM2 = 3'b100;
    localparam WAIT_CAM2 = 3'b101;

    localparam GAP_WAIT = H_ACT;

    reg [$clog2(GAP_WAIT)-1:0] gap_cnt;

    reg [2:0] state;
    assign busy = state != IDLE;

    reg trig_d;
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
            cnt      <= #1 'b0;
            cam_id   <= #1 'b0;
            state    <= #1 IDLE;
            cam_trig <= #1 'b0;
            gap_cnt  <= #1 'b0;
        end else begin
            case (state)
                IDLE : begin
                    cam_trig <= #1 'b0;
                    cam_id   <= #1 'b0;
                    gap_cnt  <= #1 'b0;
                    if (trig_d) begin
                        cnt   <= #1 cnt + 1'b1;
                        state <= #1 TRIG_CAM1;
                    end
                end
                TRIG_CAM1 : begin
                    if (buf_busy) begin
                        cam_trig <= #1 'b0;
                        state    <= #1 WAIT_CAM1;
                    end else begin
                        cam_trig <= #1 'b1;
                    end
                end
                WAIT_CAM1 : begin
                    if (~buf_busy) begin
                        gap_cnt <= #1 'b0;
                        state   <= #1 GAP;
                    end
                end
                GAP : begin
                    if (gap_cnt!=GAP_WAIT) begin
                        gap_cnt <= #1 gap_cnt + 1'b1;
                    end else begin
                        cam_id <= #1 'b1;
                        if (~buf_busy) begin
                            state <= #1 TRIG_CAM2;
                        end
                    end
                end
                TRIG_CAM2 : begin
                    if (buf_busy) begin
                        cam_trig <= #1 'b0;
                        state    <= #1 WAIT_CAM2;
                    end else begin
                        cam_trig <= #1 'b1;
                    end
                end
                WAIT_CAM2 : begin
                    if (~buf_busy) begin
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
