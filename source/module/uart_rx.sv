module uart_rx #(
    parameter FREQ_SYS    = 50_000_000,
    parameter FREQ_SERIAL = 115200
) (
    input        clk,
    input        rstn,
    input        i_rx,
    output       o_fini,
    output [7:0] o_data
);

    localparam CNT_SERIAL = FREQ_SYS / FREQ_SERIAL;

    localparam CNT_HALF_BIT = CNT_SERIAL / 2                       ;
    localparam CNT_BIT_0    = CNT_SERIAL * 1 + CNT_HALF_BIT - 1 - 3;
    localparam CNT_BIT_1    = CNT_SERIAL * 2 + CNT_HALF_BIT - 1 - 3;
    localparam CNT_BIT_2    = CNT_SERIAL * 3 + CNT_HALF_BIT - 1 - 3;
    localparam CNT_BIT_3    = CNT_SERIAL * 4 + CNT_HALF_BIT - 1 - 3;
    localparam CNT_BIT_4    = CNT_SERIAL * 5 + CNT_HALF_BIT - 1 - 3;
    localparam CNT_BIT_5    = CNT_SERIAL * 6 + CNT_HALF_BIT - 1 - 3;
    localparam CNT_BIT_6    = CNT_SERIAL * 7 + CNT_HALF_BIT - 1 - 3;
    localparam CNT_BIT_7    = CNT_SERIAL * 8 + CNT_HALF_BIT - 1 - 3;
    localparam CNT_FINI     = CNT_SERIAL * 9 + CNT_HALF_BIT - 1 - 3;

    reg [$clog2(CNT_FINI)-1:0] r_bit_cnt;

    reg  [2:0] r_rxs;
    wire       w_rx;
    assign w_rx = r_rxs[1];
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_rxs <= #1 3'b111;
        end
        else begin
            r_rxs <= #1 {r_rxs[1:0], i_rx};
        end
    end

    reg r_start;
    reg r_busy;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_start <= #1 'b0;
        end
        else begin
            r_start <= #1 r_rxs[2] & (~r_rxs[1]) & (~r_busy);
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_bit_cnt <= #1 'b0;
        end
        else if (r_busy) begin
            if (CNT_FINI != r_bit_cnt)
                r_bit_cnt <= #1 r_bit_cnt + 'b1;
            else
                r_bit_cnt <= #1 'b0;
        end
        else begin
            r_bit_cnt <= #1 'b0;
        end
    end

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_busy <= #1 1'b0;
        end
        else if (r_start) begin
            r_busy <= #1 1'b1;
        end
        else if (r_bit_cnt == CNT_FINI) begin
            r_busy <= #1 1'b0;
        end
    end

    reg r_fini;
    assign o_fini = r_fini;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_fini <= #1 1'b0;
        end
        else if (r_bit_cnt == CNT_FINI) begin
            r_fini <= #1 1'b1;
        end
        else begin
            r_fini <= #1 1'b0;
        end
    end

    reg [7:0] r_data;
    assign o_data = r_data;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_data <= #1 8'h00;
        end
        else if (r_bit_cnt == CNT_BIT_0) begin
            r_data[0] <= #1 w_rx;
        end
        else if (r_bit_cnt == CNT_BIT_1) begin
            r_data[1] <= #1 w_rx;
        end
        else if (r_bit_cnt == CNT_BIT_2) begin
            r_data[2] <= #1 w_rx;
        end
        else if (r_bit_cnt == CNT_BIT_3) begin
            r_data[3] <= #1 w_rx;
        end
        else if (r_bit_cnt == CNT_BIT_4) begin
            r_data[4] <= #1 w_rx;
        end
        else if (r_bit_cnt == CNT_BIT_5) begin
            r_data[5] <= #1 w_rx;
        end
        else if (r_bit_cnt == CNT_BIT_6) begin
            r_data[6] <= #1 w_rx;
        end
        else if (r_bit_cnt == CNT_BIT_7) begin
            r_data[7] <= #1 w_rx;
        end
    end

endmodule : uart_rx
