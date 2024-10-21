module rst_gen #(parameter TICK = 1) (
    input      clk  ,
    input      i_rst,
    output reg o_rst
);

    reg [$clog2(TICK)-1:0] cnt;

    always_ff @(posedge clk or posedge i_rst) begin
        if(i_rst) begin
            cnt   <= #1 'b0;
            o_rst <= #1 'b1;
        end else begin
            if (cnt < TICK) begin
                cnt <= #1 cnt + 1'b1;
            end else begin
                o_rst <= #1 'b0;
            end
        end
    end

endmodule : rst_gen
