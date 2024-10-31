module udp_reader #(parameter CAPACITY = 1) (
    input                       clk   ,
    input                       rstn  ,

    input                       valid ,
    input      [           7:0] i_data,

    output     [CAPACITY*8-1:0] o_data,
    output reg                  filled
);

    `ifdef UDP_READER_MEM
        reg     [$clog2(CAPACITY)-1:0] wptr;
        reg     [      CAPACITY*8-1:0] mem ;
        integer                        i   ;
        always_ff @(posedge clk or negedge rstn) begin
            if(~rstn) begin
                filled <= #1 'b0;
                wptr   <= #1 'b0;
                for (i = 0; i < CAPACITY; i=i+1) begin
                    mem[i] <= #1 'b0;
                end
            end else if (valid) begin
                mem[wptr] <= #1 i_data;
                if (wptr!=CAPACITY-1) begin
                    wptr <= #1 wptr + 1'b1;
                end else begin
                    filled <= #1 'b1;
                    wptr   <= #1 'b0;
                end
            end
        end

        genvar j;
        for (j = 0; j < CAPACITY; j=j+1) begin : g_unpack
            assign o_data[(j+1)*8-1:j*8] = mem[CAPACITY-j-1];
        end
    `else
        assign o_data = 'b0;
    `endif

endmodule : udp_reader
