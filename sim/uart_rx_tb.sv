`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 10:37:03 AM
// Design Name: 
// Module Name: uart_rx_tb
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


module uart_rx_tb(
   
    );
    logic clk;
    logic rst;
    logic tick;
    logic rx_in;
    
    logic [7:0] data_out;
    logic rx_done_tick;
    
    
    uart_rx uut ( 
        .clk(clk),
        .rst(rst),
        .tick(tick),
        .rx_in(rx_in),
        .data_out(data_out),
        .rx_done_tick(rx_done_tick)
    );
    
    
    baud_gen baud (
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
        rx_in = 1;
        
        #20 rst = 1;
        #20 rst = 0;
        
        #100;
        
        rx_in = 0;
        #8680;
        
        rx_in = 1; #8680;
        rx_in = 0; #8680;
        rx_in = 1; #8680;
        rx_in = 0; #8680;
        rx_in = 1; #8680;
        rx_in = 0; #8680;
        rx_in = 1; #8680;
        rx_in = 0; #8680;
        
        rx_in = 1; #8680;
        
        #5000;
        
        rx_in = 0;
        
        #2000;
        
        rx_in = 1;
        #100000;
        
        $finish;
        
    end
        
        

endmodule
