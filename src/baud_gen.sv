`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 08:21:13 PM
// Design Name: 
// Module Name: baud_gen
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


module baud_gen #(
//assuming 115200 baud rate: 100MHz / 115200 / 16 ~= 54 clocks per tick
    parameter int DIV = 53
)(
    input logic clk,
    input logic rst,
    output logic tick
    );

    logic [5:0] count_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            tick <= 1'b0;
            count_reg <= 6'b000000;
        end else if (count_reg == DIV) begin
            tick <= 1'b1;
            count_reg <= 6'b000000;
        end else begin
            tick <= 1'b0;
            count_reg <= count_reg + 1;
        end  
    end
        
endmodule
