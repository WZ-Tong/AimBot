module rstn_gen #(parameter TICK = 1) (
    input      clk   ,
    input      i_rstn,
    output reg o_rstn
);

    reg [$clog2(TICK)-1:0] cnt = 'b0;

    always_ff @(posedge clk or negedge i_rstn) begin
        if(~i_rstn) begin
            cnt    <= #1 'b0;
            o_rstn <= #1 'b0;
        end else begin
            if (cnt < TICK) begin
                cnt <= #1 cnt + 1'b1;
            end else begin
                o_rstn <= #1 'b1;
            end
        end
    end

endmodule : rstn_gen
