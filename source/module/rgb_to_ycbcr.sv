// Delay=4(3+1)
module rgb_to_ycbcr (
    input            clk ,
    input            rstn,
    input      [7:0] r   ,
    input      [7:0] g   ,
    input      [7:0] b   ,
    output reg [7:0] y   ,
    output reg [7:0] cb  ,
    output reg [7:0] cr
);

    wire [15:0] r1, g1, b1;
    wire [15:0] r2, g2, b2;
    wire [15:0] r3, g3, b3;

    mul_8_8 u_mul_r1 (.clk(clk), .a(r), .b(8'd077), .p(r1));
    mul_8_8 u_mul_g1 (.clk(clk), .a(g), .b(8'd150), .p(g1));
    mul_8_8 u_mul_b1 (.clk(clk), .a(b), .b(8'd029), .p(b1));
    mul_8_8 u_mul_r2 (.clk(clk), .a(r), .b(8'd043), .p(r2));
    mul_8_8 u_mul_g2 (.clk(clk), .a(g), .b(8'd085), .p(g2));
    mul_8_8 u_mul_b2 (.clk(clk), .a(b), .b(8'd128), .p(b2));
    mul_8_8 u_mul_r3 (.clk(clk), .a(r), .b(8'd128), .p(r3));
    mul_8_8 u_mul_g3 (.clk(clk), .a(g), .b(8'd107), .p(g3));
    mul_8_8 u_mul_b3 (.clk(clk), .a(b), .b(8'd021), .p(b3));

    wire [15:0] y1, cb1, cr1;
    assign y1  = r1 + g1 + b1;
    assign cb1 = b2 - r2 - g2 + 16'd32768;
    assign cr1 = r3 - g3 - b3 + 16'd32768;

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            y  <= #1 'b0;
            cb <= #1 'b0;
            cr <= #1 'b0;
        end else begin
            y  <= y1[15:8];
            cb <= cb1[15:8];
            cr <= cr1[15:8];
        end
    end

endmodule : rgb_to_ycbcr
