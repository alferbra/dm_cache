import cache_definition::*;

module top_memory_hierarchy (
    input bit clk,
    input bit rst,
    input cache_data_type ram_data_r,
    input cpu_to_cache_type cpu_to_cache,
    output cache_to_cpu_type cache_to_cpu,
    output bit WE,
    output bit [3:0] BE,
    output bit [19:0] ram_addr,
    output cache_data_type ram_data_w
);

    //Cache <-> Memory controller signals
    cache_to_mem_type cache_to_mem;
    mem_to_cache_type mem_to_cache;
    
    ram32_controller ram32_controller_inst(
        .clk (clk),
        .rst (rst),
        .data_r (ram_data_r),
        .cache_to_mem (cache_to_mem),
        .mem_to_cache (mem_to_cache),
        .addr (ram_addr),
        .data_w (ram_data_w),
        .BE (BE),
        .WE (WE)
    );

    dm_cache_controller dm_cache_controller_inst (
        .clk (clk),
        .rst (rst),
        .cpu_to_cache (cpu_to_cache),
        .mem_to_cache (mem_to_cache),
        .cache_to_mem (cache_to_mem),
        .cache_to_cpu (cache_to_cpu)
    );

endmodule