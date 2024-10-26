module uart_tx #(
    parameter FREQ_SYS    = 50_000_000,
    parameter FREQ_SERIAL = 115200
) (
    input        clk      ,
    input        rstn     ,
    input        i_tx_trig,
    input  [7:0] i_tx_data,
    output       o_idle   ,
    output       o_tx
);

    localparam CNT_SERIAL = FREQ_SYS / FREQ_SERIAL;

    localparam CNT_START  = CNT_SERIAL * 01 - 1;
    localparam CNT_BIT_0  = CNT_SERIAL * 02 - 1;
    localparam CNT_BIT_1  = CNT_SERIAL * 03 - 1;
    localparam CNT_BIT_2  = CNT_SERIAL * 04 - 1;
    localparam CNT_BIT_3  = CNT_SERIAL * 05 - 1;
    localparam CNT_BIT_4  = CNT_SERIAL * 06 - 1;
    localparam CNT_BIT_5  = CNT_SERIAL * 07 - 1;
    localparam CNT_BIT_6  = CNT_SERIAL * 08 - 1;
    localparam CNT_BIT_7  = CNT_SERIAL * 09 - 1;
    localparam CNT_FINI   = CNT_SERIAL * 10 - 1;
    localparam CNT_STOP_1 = CNT_SERIAL * 11 - 1;
    localparam CNT_STOP_2 = CNT_SERIAL * 12 - 1;

    reg r_idle;
    assign o_idle = r_idle;
    reg [$clog2(CNT_STOP_2)-1:0] r_bit_cnt;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_bit_cnt <= #1 'b0;
        end
        else if (~r_idle) begin
            r_bit_cnt <= #1 r_bit_cnt + 'b1;
        end
        else begin
            r_bit_cnt <= #1 'b0;
        end
    end

    reg [7:0] r_tx_data;

    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_idle    <= #1 'b1;
            r_tx_data <= #1 'b0;
        end
        else if (i_tx_trig) begin
            r_idle    <= #1 'b0;
            r_tx_data <= #1 i_tx_data;
        end
        else if (r_bit_cnt == CNT_STOP_2) begin
            r_idle <= #1 'b1;
        end
    end

    reg r_tx;
    assign o_tx = r_tx;
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            r_tx <= #1 'b1;
        end
        else if (r_bit_cnt == CNT_START) begin
            r_tx <= #1 'b0;
        end
        else if (r_bit_cnt == CNT_BIT_0) begin
            r_tx <= #1 r_tx_data[0];
        end
        else if (r_bit_cnt == CNT_BIT_1) begin
            r_tx <= #1 r_tx_data[1];
        end
        else if (r_bit_cnt == CNT_BIT_2) begin
            r_tx <= #1 r_tx_data[2];
        end
        else if (r_bit_cnt == CNT_BIT_3) begin
            r_tx <= #1 r_tx_data[3];
        end
        else if (r_bit_cnt == CNT_BIT_4) begin
            r_tx <= #1 r_tx_data[4];
        end
        else if (r_bit_cnt == CNT_BIT_5) begin
            r_tx <= #1 r_tx_data[5];
        end
        else if (r_bit_cnt == CNT_BIT_6) begin
            r_tx <= #1 r_tx_data[6];
        end
        else if (r_bit_cnt == CNT_BIT_7) begin
            r_tx <= #1 r_tx_data[7];
        end
        else if (r_bit_cnt == CNT_FINI) begin
            r_tx <= #1 'b1;
        end
        else if (r_bit_cnt == CNT_STOP_1) begin
            r_tx <= #1 'b1;
        end
        else if (r_bit_cnt == CNT_STOP_2) begin
            r_tx <= #1 'b1;
        end
    end

endmodule : uart_tx
