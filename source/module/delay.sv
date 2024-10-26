module delay #(
    parameter DELAY = 1,
    parameter WIDTH = 1
) (
    input              clk   ,
    input  [WIDTH-1:0] i_data,
    output [WIDTH-1:0] o_data
);

    reg [WIDTH-1:0] delay [DELAY];

    integer i;

    always_ff @(posedge clk) begin
        for (i = 1; i < DELAY; i=i+1) begin
            delay[i] <= #1 delay[i-1];
        end
        delay[0] <= #1 i_data;
    end

    assign o_data = delay[i-1];

endmodule : delay
