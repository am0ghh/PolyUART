`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/23/2026 08:34:39 AM
// Design Name: 
// Module Name: uart_tx_tb
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


module uart_tx_tb(

    );
    logic clk;
    logic rst;
    logic tick;
    logic tx_start;
    logic [7:0] data_in;
    
    logic tx_out;
    logic tx_done_tick;
    
    
    
    uart_tx uut ( 
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .tx_start(tx_start),
        .data_in(data_in),
        .tx_out(tx_out),
        .tx_done_tick(tx_done_tick)
    );
    
    // Small divisor for simulation so a full frame is ~us, not ~86us.
    // Use the default DIV (53) for real hardware.
    baud_gen #(.DIV(2)) baud(
        .clk(clk),
        .rst(rst),
        .tick(tick)
    );
    
    
    always begin
        #5 clk = ~clk;
    end
    
    initial begin
        clk = 0;
        rst = 0;
        
        tx_start = 0;
        data_in = 8'b01010101;
        
        
        #20 rst = 1;
        #20 rst = 0;
        
        #40;
       
        tx_start = 1;
        
        #10;
        
        tx_start = 0;
        #100000;
        $finish;
    end
    
endmodule
