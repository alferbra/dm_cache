//Controlador para RAM síncrona con escritura tipo byte

import cache_definition::*;

module ram32_controller (
    input clk, rst,
    input cache_data_type data_r,
    input cache_to_mem_type cache_to_mem,
    output mem_to_cache_type mem_to_cache,
    output bit [19:0] addr,
    output cache_data_type data_w,
    output bit [3:0] BE,
    output bit WE
    );

    //posible states
    typedef enum { idle, write, read } ram_state_type;

    //state registers
    ram_state_type current_state, next_state;

    //temporary variable for SRAM memory results (SRAM -> cache)
    mem_to_cache_type next_mem_to_cache;

    //register to keep the cache request
    cache_to_mem_type hold_cache_to_mem;

    assign mem_to_cache.data = next_mem_to_cache.data;
    assign addr = (cache_to_mem.valid) ? cache_to_mem.addr : hold_cache_to_mem.addr;
    assign data_w = (cache_to_mem.rw) ? cache_to_mem.data : hold_cache_to_mem.data;

    always_comb begin
        
        next_state = current_state;

        next_mem_to_cache.ready = '0;
        next_mem_to_cache.data = data_r;

        BE = '0;
        WE = '0;

        case (current_state) 

            idle: begin

                if (cache_to_mem.valid) begin
                    
                    if (cache_to_mem.rw) begin
                        WE = '1;
                        BE = '1;
                        next_state = write;
                    end

                    else if (!cache_to_mem.rw) begin
                        WE = '0;
                        next_state = read;
                    end
                end
            end

            read: begin
                next_mem_to_cache.ready = '1;
                next_state = idle;
            end

            write: begin
                WE = '1;
                BE = '1;
                next_mem_to_cache.ready = '1;
                next_state = idle;
            end

        endcase
    end

    always_ff @(posedge clk) begin
        if (!rst) 
            current_state <= idle;
        else
            current_state <= next_state;

        mem_to_cache.ready <= next_mem_to_cache.ready;
        hold_cache_to_mem <= cache_to_mem;
    end

endmodule
