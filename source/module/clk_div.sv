module clk_div #(parameter DIV = 1) (
    input      i_clk,
    output reg o_clk
);

    reg [$clog2(DIV)-1:0] cnt;

    always_ff @(posedge i_clk) begin
        if (cnt<=DIV-1) begin
            cnt <= #1 cnt + 1'b1;
        end else begin
            cnt   <= #1 'b0;
            o_clk <= #1 ~o_clk;
        end
    end

endmodule : clk_div
