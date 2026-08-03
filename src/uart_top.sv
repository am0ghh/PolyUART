`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/21/2026 10:58:12 PM
// Design Name: 
// Module Name: uart_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: One UART transmitter and 2**ADDR_BITS addressed receivers sharing
//              a single serial line (multi-drop bus).
// 
// Dependencies: baud_gen, uart_tx, uart_rx
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_top #(
    parameter int ADDR_BITS = 2,     // 2 address bits -> 4 devices
    parameter int DIV       = 53     // baud divisor; override (e.g. 2) in sim for speed
)(
    input  logic                 clk,
    input  logic                 rst,
    input  logic                 tx_start,
    input  logic [7:0]           data_in,
    input  logic [ADDR_BITS-1:0] addr,       // destination address for this transmission
    output logic                 tx_out,      // the shared serial bus line
    output logic                 tx_done,
    // one receiver per address: 2**ADDR_BITS of them
    output logic [7:0]           rx_data [1<<ADDR_BITS],
    output logic                 rx_done [1<<ADDR_BITS]
    );

    localparam int NUM_RX = 1 << ADDR_BITS;   // 2**ADDR_BITS receivers, one per address

    logic tick_wire;

    // Baud-rate generator shared by the transmitter and every receiver
    baud_gen #(.DIV(DIV)) baud_inst (
        .clk  (clk),
        .rst  (rst),
        .tick (tick_wire)
    );

    // Single transmitter. Its serial output (tx_out) IS the shared bus line.
    uart_tx #(.ADDR_BITS(ADDR_BITS)) tx_inst (
        .clk          (clk),
        .rst          (rst),
        .tick         (tick_wire),
        .tx_start     (tx_start),
        .data_in      (data_in),
        .addr         (addr),
        .tx_out       (tx_out),
        .tx_done_tick (tx_done)
    );

    
    genvar i;
    generate
        for (i = 0; i < NUM_RX; i++) begin : gen_rx
            uart_rx #(
                .ADDR_BITS (ADDR_BITS),
                .MY_ADDR   (ADDR_BITS'(i))
            ) rx_inst (
                .clk          (clk),
                .rst          (rst),
                .tick         (tick_wire),
                .rx_in        (tx_out),       // shared bus: all receivers listen here
                .data_out     (rx_data[i]),
                .rx_done_tick (rx_done[i])
            );
        end
    endgenerate

endmodule