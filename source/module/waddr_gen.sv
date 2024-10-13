module waddr_gen #(parameter NUM = 1280) (
    input                        clk ,
    input                        rstn,
    input                        en  ,
    output reg [$clog2(NUM)-1:0] addr
);

    reg en_d;
    always_ff @(posedge clk) begin
        en_d <= #1 en;
    end

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            addr <= #1 'b0;
        end else begin
            if (en && ~en_d) begin
                addr <= #1 'b0;
            end else if (addr<NUM) begin
                addr <= #1 addr + 1'b1;
            end
        end
    end

endmodule : waddr_gen
