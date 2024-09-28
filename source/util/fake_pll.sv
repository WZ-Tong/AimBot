// TODO: Replace with real pll

module fake_pll #(parameter CLK = 1) (
    input            i, // Input clk
    output [CLK-1:0] l, // Output locked
    output [CLK-1:0] o  // Output clk
);

generate
    genvar j;
    for (j = 0; j < CLK; j=j+1) begin
        assign o[j] = i;
        assign l = 1;
    end
endgenerate

endmodule : fake_pll
