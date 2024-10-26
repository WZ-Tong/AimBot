module udp_reader #(parameter CAPACITY = 1) (
    input                         clk     ,
    input                         rstn    ,

    input                         valid   ,
    input      [             7:0] i_data  ,
    input      [            15:0] data_len,

    output reg [(CAPACITY*8)-1:0] o_data  ,
    output reg                    cap_err
);

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            o_data <= #1 'b0;
        end else begin
            cap_err <= #1 'b0;
            if (valid) begin
                if (data_len<=CAPACITY) begin
                    if (CAPACITY==1) begin
                        o_data <= #1 i_data;
                    end else begin
                        o_data <= #1 {o_data[(CAPACITY*8)-1:8], i_data};
                    end
                end else begin
                    cap_err <= #1 'b1;
                end
            end
        end
    end

endmodule : udp_reader
