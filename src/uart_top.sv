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
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_top(
    input logic clk,
    input logic rst,
    input logic tx_start,
    input logic [7:0] data_in,
    output logic tx_out,
    output logic tx_done
    );
    
    logic tick_wire;
    
    baud_gen baud_inst(
        .tick (tick_wire)
    );
    
    uart_tx uart_inst(
        .tick (tick_wire)
    );
    
    uart_rx uart_inst2(
        .tick (tick_wire)
    );
    
endmodule
