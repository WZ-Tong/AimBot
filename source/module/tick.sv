module tick #(parameter TICK = 1) (
    input      clk ,
    input      rstn,
    input      trig,
    output reg tick
);

    reg last;

    reg [$clog2(TICK)-1:0] cnt;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            cnt  <= #1 'b0;
            tick <= #1 'b0;
            last <= #1 'b0;
        end else begin
            last <= #1 trig;
            if (last!=trig) begin
                if (cnt==TICK-1) begin
                    cnt  <= #1 'b0;
                    tick <= #1 ~tick;
                end else begin
                    cnt <= #1 cnt + 1'b1;
                end
            end
        end
    end

endmodule : tick
