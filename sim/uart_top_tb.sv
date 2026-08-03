`timescale 1ns / 1ps

module uart_top_tb;

    localparam int ADDR_BITS = 2;
    localparam int DIV       = 2;                       // fast sim
    // frame = start + ADDR_BITS + 8 data + stop bits, 16 ticks/bit, (DIV+1) clocks/tick
    localparam int FRAME_CLOCKS = (1 + ADDR_BITS + 8 + 1) * 16 * (DIV + 1);

    logic                 clk, rst, tx_start;
    logic [7:0]           data_in;
    logic [ADDR_BITS-1:0] addr;
    logic                 tx_out, tx_done;
    logic [7:0]           rx_data [1<<ADDR_BITS];
    logic                 rx_done [1<<ADDR_BITS];

    uart_top #(.ADDR_BITS(ADDR_BITS), .DIV(DIV)) dut (
        .clk, .rst, .tx_start, .data_in, .addr,
        .tx_out, .tx_done, .rx_data, .rx_done
    );

    always #5 clk = ~clk;                                // 100 MHz

    // Send one frame to address a with byte d, then wait out the whole frame
    task automatic send(input [ADDR_BITS-1:0] a, input [7:0] d);
        @(negedge clk); addr = a; data_in = d; tx_start = 1;
        @(negedge clk); tx_start = 0;
        repeat (FRAME_CLOCKS + 200) @(posedge clk);      // let frame finish + margin
    endtask

    // Console proof: print whenever any receiver reports
    always @(posedge clk)
        for (int k = 0; k < (1<<ADDR_BITS); k++)
            if (rx_done[k])
                $display("[%0t] RX%0d captured 0x%02h", $time, k, rx_data[k]);

    initial begin
        clk = 0; rst = 0; tx_start = 0; addr = 0; data_in = 0;
        #20 rst = 1; #20 rst = 0;                        // active-high reset pulse
        #100;

        send(2'd2, 8'hA5);   // expect ONLY RX2 -> 0xA5
        send(2'd0, 8'h3C);   // expect ONLY RX0 -> 0x3C
        send(2'd3, 8'h55);   // expect ONLY RX3 -> 0x55
        send(2'd1, 8'hF0);   // expect ONLY RX1 -> 0xF0

        #2000;
        $finish;
    end

endmodule