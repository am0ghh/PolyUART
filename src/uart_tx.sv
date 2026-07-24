`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/10/2026 08:19:17 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx(
    input logic clk,
    input logic rst,
    input logic tick,
    input logic tx_start,
    input logic [7:0] data_in,
    output logic tx_out, 
    output logic tx_done_tick
    );
    
    
    typedef enum {IDLE, START, DATA, STOP} state_t;
    state_t state;
    
    logic [7:0] shift;
    logic [2:0] bit_count;
    logic [3:0] tick_count;
    
    always_ff @(posedge clk) begin
        tx_done_tick <= 1'b0;
        if (rst) begin
            state <= IDLE;
            shift <= 0;
            bit_count <= 0;
            tick_count <= 0;
            tx_out <= 1'b1;
            tx_done_tick <= 1'b0;
        
        end else if (state == IDLE) begin
            tx_out <= 1'b1;
            if (tx_start) begin
                shift <= data_in;
                state <= START;
            end
        end else if (state == START) begin
            tx_out <= 1'b0;
            if (tick) begin
                tick_count <= tick_count + 1;
                if (tick_count == 4'b1111) begin
                    bit_count <= 1'b0;
                    tick_count <= 4'b0000;
                    state <= DATA;
                end
            end
        end else if (state == DATA) begin
            tx_out <= shift[0];
            if (tick) begin
                tick_count <= tick_count + 1;
                if (tick_count == 4'b1111) begin
                    tick_count <= 4'b0000;
                    shift <= shift >> 1;
                    bit_count <= bit_count + 1;
                    
                    if (bit_count == 3'b111) begin
                        state <= STOP;
                    end
                end
            end
       end else if (state == STOP) begin
           tx_out <= 1'b1;
           if (tick) begin
               tick_count <= tick_count + 1;
               if (tick_count == 4'b1111) begin
                   tx_done_tick <= 1'b1;
                   state <= IDLE;
               end 
           end
       end   

    end 
    
endmodule
