module uart_rx #(parameter int ADDR_BITS = 2, parameter [ADDR_BITS-1:0] MY_ADDR = 0)(
    input logic clk,
    input logic rst,
    input logic tick,
    input logic rx_in,
    output logic [7:0] data_out, 
    output logic rx_done_tick
);
    
    typedef enum {IDLE, START, ADDR, DATA, STOP} state_t;
    state_t state; 
    
    logic [3:0] tick_count;
    logic [2:0] bit_count;
    logic [7:0] shift;
    logic [ADDR_BITS -1 :0] addr_reg;
    logic [$clog2(ADDR_BITS) - 1:0] addr_count;
    
    //initial $display("%m : MY_ADDR = %0d", MY_ADDR);
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            tick_count <= 0;
            bit_count <= 0;
            rx_done_tick <= 0;
            data_out <= 0;
            shift <= 0;
            addr_reg <= 0;
            addr_count <= 0;
        end else begin
            rx_done_tick <= 1'b0;
            
            if (state == IDLE) begin
                if (rx_in == 1'b0) begin
                    tick_count <= 0;
                    state <= START; 
                end
                
            end else if (state == START) begin
                if (tick) begin
                    if (tick_count == 4'b0111) begin 
                        if (rx_in == 1'b0) begin
                            tick_count <= 0;
                            bit_count <= 0;
                            addr_count <= 0;
                            state <= ADDR;
                        end else begin
                            state <= IDLE;
                        end
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                end   
            end else if (state == ADDR) begin
                if (tick) begin
                    if (tick_count == 4'b1111) begin
                        tick_count <= 0;
                        addr_reg <= {rx_in, addr_reg[ADDR_BITS-1:1]};
                        
                        if (addr_count == ADDR_BITS - 1) begin
                            state <= DATA;    
                        end else begin
                            addr_count <= addr_count + 1;
                        end 
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                    
                end
            end else if (state == DATA) begin
                if (tick) begin
                    if (tick_count == 4'b1111) begin 
                        tick_count <= 0;
                        shift <= {rx_in, shift[7:1]};
                        
                        if (bit_count == 3'b111) begin
                            state <= STOP; 
                        end else begin
                            bit_count <= bit_count + 1; 
                        end
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                end
                
            end else if (state == STOP) begin
                if (tick) begin
                    if (tick_count == 4'b1111) begin 
                        if (addr_reg == MY_ADDR) begin
                            rx_done_tick <= 1'b1;
                            data_out <= shift;
                        end
                        state <= IDLE;
                    end else begin
                        tick_count <= tick_count + 1;
                    end
                end
            end
     
        end
    end
    
endmodule