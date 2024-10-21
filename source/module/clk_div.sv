module clk_div #(parameter CNT = 50_000_000) (
    input      i_clk,
    output reg o_clk
);

    reg [$clog2(CNT)-1:0] cnt;

    always_ff @(posedge i_clk) begin
        if (cnt<CNT) begin
            cnt <= #1 cnt + 1'b1;
        end else begin
            cnt   <= #1 'b0;
            o_clk <= #1 ~o_clk;
        end
    end

endmodule : clk_div
