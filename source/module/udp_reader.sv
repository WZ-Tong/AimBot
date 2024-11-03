`ifdef __ICARUS__
    `define UDP_READER_MEM PDS_LITE
`endif

module udp_reader #(parameter CAPACITY = 1) (
    input                       clk   ,
    input                       rstn  ,

    input                       valid   /*synthesis PAP_MARK_DEBUG="true"*/,
    input                       rx_end  /*synthesis PAP_MARK_DEBUG="true"*/,
    input      [           7:0] i_data  /*synthesis PAP_MARK_DEBUG="true"*/,
    input      [          15:0] i_len ,

    output     [CAPACITY*8-1:0] o_data,
    output reg                  error   /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg                  trig    /*synthesis PAP_MARK_DEBUG="true"*/
);

    `ifdef UDP_READER_MEM
        integer i;

        reg  [$clog2(CAPACITY)-1:0] wptr/*synthesis PAP_MARK_DEBUG="true"*/;

        reg  [           7:0] inner_mem [CAPACITY]/*synthesis PAP_MARK_DEBUG="true"*/;
        wire [CAPACITY*8-1:0] inner_data;

        reg [7:0] disp_mem[CAPACITY];

        always_ff @(posedge clk or negedge rstn) begin
            if(~rstn) begin
                error <= #1 'b0;
                wptr  <= #1 'b0;
                for (i = 0; i < CAPACITY; i=i+1) begin
                    inner_mem[i] <= #1 'b0;
                    disp_mem[i]  <= #1 'b0;
                end
                trig <= #1 'b0;
            end else begin
                trig            <= #1 'b0;
                inner_mem[wptr] <= #1 i_data;
                if (valid) begin
                    if (wptr!=CAPACITY-1) begin
                        wptr <= #1 wptr + 1'b1;
                    end else begin
                        wptr <= #1 'b0;
                    end
                end else if (rx_end) begin
                    if (wptr!=0) begin
                        error <= #1 'b1;
                    end else begin
                        error <= #1 'b0;
                    end

                    if ((~inner_data)==0) begin
                        trig <= #1 'b1;
                    end else if (inner_data!=0) begin
                        for (i = 0; i < CAPACITY; i=i+1) begin
                            disp_mem[i]  <= #1 inner_mem[i];
                        end
                    end else begin
                        // `inner_data`==0
                    end
                end
            end
        end

        genvar j;
        for (j = 0; j < CAPACITY; j=j+1) begin : g_unpack
            assign o_data[(j+1)*8-1:j*8]     = disp_mem[CAPACITY-j-1];
            assign inner_data[(j+1)*8-1:j*8] = inner_mem[CAPACITY-j-1];
        end
    `else
        assign o_data = 'b0;
        assign error  = 'b0;
        assign trig   = 'b0;
    `endif

endmodule : udp_reader
