module udp_reader #(parameter CAPACITY = 1) (
    input                       clk   ,
    input                       rstn  ,

    input                       valid ,
    input      [           7:0] i_data,

    output reg [CAPACITY*8-1:0] o_data,
    output reg                  error
);

    reg [$clog2(CAPACITY)-1:0] wptr;

    integer i;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            error  <= #1 'b0;
            wptr   <= #1 'b0;
            o_data <= #1 'b0;
        end else if (valid) begin
            if (wptr!=CAPACITY-1) begin
                for (i = 0; i < 8; i=i+1) begin
                    o_data[wptr*8+i] <= #1 i_data[i];
                end
                wptr <= #1 wptr + 1'b1;
            end else begin
                error <= #1 'b1;
            end
        end else begin
            error <= #1 'b0;
            wptr  <= #1 'b0;
        end
    end

endmodule : udp_reader
