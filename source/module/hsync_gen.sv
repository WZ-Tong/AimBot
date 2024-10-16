module hsync_gen #(
    parameter AFTER = 100,
    parameter HOLD  = 100
) (
    input      clk  ,
    input      rstn ,
    input      href ,

    output reg hsync
);

    localparam CNT = AFTER > HOLD ? AFTER : HOLD;

    reg href_d;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            href_d <= #1 'b0;
        end else begin
            href_d <= #1 href;
        end
    end

    localparam IDLE = 2'b00;
    localparam WAIT = 2'b01;
    localparam SYNC = 2'b10;

    reg state;

    reg [$clog2(CNT)-1:0] cnt;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            cnt   <= #1 'b0;
            state <= #1 IDLE;
            hsync <= #1 'b0;
        end else begin
            case (state)
                IDLE : begin
                    if (href_d==1 && href==0) begin
                        cnt   <= #1 'b0;
                        state <= #1 WAIT;
                    end
                end
                WAIT : begin
                    if (cnt<AFTER) begin
                        cnt <= #1 cnt + 1'b1;
                    end else begin
                        cnt   <= #1 'b0;
                        state <= #1 SYNC;
                        hsync <= #1 'b1;
                    end
                end
                SYNC : begin
                    if (cnt<HOLD) begin
                        cnt <= #1 cnt + 1'b1;
                    end else begin
                        cnt   <= #1 'b0;
                        state <= #1 WAIT;
                        hsync <= #1 'b0;
                    end
                end
                default : begin
                    state <= #1 WAIT;
                end
            endcase
        end
    end

endmodule : hsync_gen
