module raddr_gen #(parameter NUM = 1280) (
    input                        clk   ,
    input                        rstn  ,
    input      [$clog2(NUM)-1:0] head_1,
    input      [$clog2(NUM)-1:0] head_2,
    output reg [$clog2(NUM)-1:0] addr    /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg                   valid   /*synthesis PAP_MARK_DEBUG="true"*/,
    output reg                   finish  /*synthesis PAP_MARK_DEBUG="true"*/
);

    always_ff @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            valid  <= #1 'b0;
            addr   <= #1 'b0;
            finish <= #1 'b0;
        end else if (addr!=NUM) begin
            if (addr<head_1 && addr<head_2) begin
                addr  <= #1 addr + 1'b1;
                valid <= #1 'b1;
            end else begin
                valid <= #1 'b0;
            end
            finish <= #1 addr==NUM-1;
        end else begin
            valid <= #1 'b0;
            if (head_1!=NUM || head_2!=NUM) begin
                finish <= #1 'b0;
                addr   <= #1 'b0;
            end
        end
    end

endmodule : raddr_gen
