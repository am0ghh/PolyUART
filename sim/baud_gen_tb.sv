`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/15/2026 11:36:00 PM
// Design Name: 
// Module Name: baud_gen_tb
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


module baud_gen_tb(
    );
    logic clk;
    logic rst;
    logic tick;
    
    baud_gen uut(
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
        
        #10 rst = 1;
        #10 rst = 0;
    end
        
endmodule
