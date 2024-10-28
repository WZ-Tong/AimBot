module udp_reader #(parameter CAPACITY = 1) (
    input                       clk   ,
    input                       rstn  ,

    input                       valid ,
    input      [           7:0] i_data,

    output     [CAPACITY*8-1:0] o_data,
    output reg                  error
);

    reg [$clog2(CAPACITY)-1:0] wptr          ;
    reg [                 7:0] mem [CAPACITY];

    integer i;
    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            error <= #1 'b0;
            wptr  <= #1 'b0;
            for (i = 0; i < CAPACITY; i=i+1) begin
                mem[i] <= #1 'b0;
            end
        end else if (valid) begin
            if (wptr!=CAPACITY-1) begin
                mem[wptr] <= #1 i_data;
                wptr      <= #1 wptr + 1'b1;
            end else begin
                error <= #1 'b1;
                wptr  <= #1 'b0;
            end
        end
    end

    genvar j;
    for (j = 0; j < CAPACITY; j=j+1) begin : gen_unpack
        assign o_data[(j+1)*8-1:j*8] = mem[CAPACITY-j-1];
    end

endmodule : udp_reader
