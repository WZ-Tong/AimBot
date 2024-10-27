module trig_gen #(parameter TICK = 1) (
    input  clk   ,
    input  rstn  ,
    input  switch,
    output trig
);

    wire press  ;
    reg  press_d;

    reg trigged;

    rstn_gen #(.TICK(TICK)) u_rstn_gen (
        .clk   (clk   ),
        .i_rstn(switch),
        .o_rstn(press )
    );

    always_ff @(posedge clk or negedge rstn) begin
        if(~rstn) begin
            trigged    <= #1 'b0;
            press_d <= #1 'b1;
        end else begin
            press_d <= #1 press;
            if (press_d==0 && press==1) begin
                trigged <= #1 'b1;
            end else if (press_d==1 && press==1) begin
                trigged <= #1 'b0;
            end
        end
    end

    rst_gen #(.TICK(10)) u_rst_gen (.clk(clk), .i_rst(trigged), .o_rst(trig));

endmodule : trig_gen
