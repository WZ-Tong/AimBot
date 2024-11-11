module color_gradient (
    input        [3:0] step,
    output logic [7:0] r   ,
    output logic [7:0] g   ,
    output logic [7:0] b
);

    always_comb begin
        unique case (step)
            'd00    : {r, g, b} = {8'h00, 8'hbb, 8'hee};
            'd01    : {r, g, b} = {8'h11, 8'haf, 8'heb};
            'd02    : {r, g, b} = {8'h22, 8'ha2, 8'he7};
            'd03    : {r, g, b} = {8'h33, 8'h96, 8'he4};
            'd04    : {r, g, b} = {8'h44, 8'h89, 8'he0};
            'd05    : {r, g, b} = {8'h55, 8'h7d, 8'hdd};
            'd06    : {r, g, b} = {8'h66, 8'h70, 8'hda};
            'd07    : {r, g, b} = {8'h77, 8'h64, 8'hd6};
            'd08    : {r, g, b} = {8'h88, 8'h57, 8'hd3};
            'd09    : {r, g, b} = {8'h99, 8'h4b, 8'hcf};
            'd10    : {r, g, b} = {8'haa, 8'h3e, 8'hcc};
            'd11    : {r, g, b} = {8'hbb, 8'h32, 8'hc9};
            'd12    : {r, g, b} = {8'hcc, 8'h25, 8'hc5};
            'd13    : {r, g, b} = {8'hdd, 8'h19, 8'hc2};
            'd14    : {r, g, b} = {8'hee, 8'h0c, 8'hbe};
            'd15    : {r, g, b} = {8'hff, 8'h00, 8'hbb};
            default : {r, g, b} = {8'h00, 8'h00, 8'h00};
        endcase
    end

endmodule : color_gradient
