module sync_gen #(
    parameter V_FP   = 5   ,
    // parameter V_BP    = 20  ,
    parameter V_SYNC = 5   ,
    parameter V_ACT  = 720 ,

    parameter H_FP   = 110 ,
    // parameter H_BP    = 220 ,
    parameter H_SYNC = 40  ,
    parameter H_ACT  = 1280
) (
    input      clk      ,
    input      rstn     ,
    input      cam_href ,
    input      cam_vsync,

    output reg hsync    ,
    output reg vsync
);

    reg cam_href_d;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            cam_href_d <= #1 'b0;
        end else begin
            cam_href_d <= #1 cam_href;
        end
    end

    localparam V_TOTAL = V_FP + /*V_BP +*/ V_SYNC + V_ACT;
    localparam H_TOTAL = H_FP + /*H_BP +*/ H_SYNC + H_ACT;

    reg [$clog2(V_TOTAL)-1:0] v_cnt /*synthesis PAP_MARK_DEBUG="true"*/;
    reg [$clog2(H_TOTAL)-1:0] h_cnt /*synthesis PAP_MARK_DEBUG="true"*/;

    reg [$clog2(H_TOTAL)-1:0] h_total /*synthesis PAP_MARK_DEBUG="true"*/;

    reg vsynced /*synthesis PAP_MARK_DEBUG="true"*/;

    localparam PASSIVE_H_ACTIVE   = 3'b000;
    localparam PASSIVE_H_FP       = 3'b001;
    localparam PASSIVE_H_SYNC     = 3'b010;
    localparam PASSIVE_H_WAIT_REF = 3'b011;

    localparam ACTIVE_H_ACTIVE   = 3'b100;
    localparam ACTIVE_H_FP       = 3'b101;
    localparam ACTIVE_H_SYNC     = 3'b110;
    localparam ACTIVE_H_WAIT_REF = 3'b111;

    reg [2:0] state /*synthesis PAP_MARK_DEBUG="true"*/;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            state   <= #1 PASSIVE_H_ACTIVE;
            v_cnt   <= #1 'b0;
            h_cnt   <= #1 'b0;
            hsync   <= #1 'b0;
            h_total <= #1 'b0;
            vsynced <= #1 'b0;
        end else begin
            if (cam_vsync) begin
                vsynced <= #1 'b1;
            end

            case (state)
                PASSIVE_H_ACTIVE : begin
                    if (cam_href==0 && cam_href_d==1) begin
                        v_cnt <= #1 v_cnt + 1'b1;
                        h_cnt <= #1 'b0;
                        state <= #1 PASSIVE_H_FP;
                    end
                end
                PASSIVE_H_FP : begin
                    if (h_cnt!=H_FP-1) begin
                        h_cnt <= #1 h_cnt + 1'b1;
                    end else begin
                        h_cnt <= #1 'b0;
                        hsync <= #1 'b1;
                        state <= #1 PASSIVE_H_SYNC;
                    end
                end
                PASSIVE_H_SYNC : begin
                    if (h_cnt!=H_SYNC-1) begin
                        h_cnt <= #1 h_cnt + 1'b1;
                    end else begin
                        h_cnt <= #1 'b0;
                        hsync <= #1 'b0;
                        if (v_cnt==V_ACT+V_FP+V_SYNC /* TODO: Check this */) begin
                            state <= #1 ACTIVE_H_WAIT_REF;
                        end else begin
                            state   <= #1 PASSIVE_H_WAIT_REF;
                            h_total <= #1 'b0;
                        end
                    end
                end
                PASSIVE_H_WAIT_REF : begin
                    if (cam_href==1 && cam_href_d==0) begin
                        state <= #1 PASSIVE_H_ACTIVE;
                    end else if (vsynced) begin
                        vsynced <= #1 'b0;
                        v_cnt   <= #1 'b0;
                    end else begin
                        h_total <= #1 h_total + 1'b1;
                    end
                end

                ACTIVE_H_WAIT_REF : begin
                    if (h_cnt!=h_total-1) begin
                        h_cnt <= #1 h_cnt + 1'b1;
                    end else begin
                        h_cnt <= #1 'b0;
                        state <= #1 ACTIVE_H_ACTIVE;
                    end
                end
                ACTIVE_H_ACTIVE : begin
                    if (h_cnt!=H_ACT-1) begin
                        h_cnt <= #1 h_cnt + 1'b1;
                    end else begin
                        h_cnt <= #1 'b0;
                        v_cnt <= #1 v_cnt + 1'b1;
                        state <= #1 ACTIVE_H_FP;
                    end
                end
                ACTIVE_H_FP : begin
                    if (h_cnt!=H_FP-1) begin
                        h_cnt <= #1 h_cnt + 1'b1;
                    end else begin
                        h_cnt <= #1 'b0;
                        hsync <= #1 'b1;
                        state <= #1 ACTIVE_H_SYNC;
                    end
                end
                ACTIVE_H_SYNC : begin
                    if (h_cnt!=H_SYNC-1) begin
                        h_cnt <= #1 h_cnt + 1'b1;
                    end else begin
                        h_cnt <= #1 'b0;
                        hsync <= #1 'b0;
                        if (v_cnt!=V_TOTAL-1 /* TODO: Check this */) begin
                            state <= #1 ACTIVE_H_WAIT_REF;
                        end else begin
                            state <= #1 PASSIVE_H_ACTIVE;
                        end
                    end
                end
            endcase
        end
    end

endmodule : sync_gen
