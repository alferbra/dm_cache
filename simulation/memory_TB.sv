`timescale 1ns/1ps

`include "../cache_definition.sv"
import cache_definition::*;

module memory_TB();

	bit rst, clk;

    cache_to_cpu_type cache_to_cpu;
	cpu_to_cache_type cpu_to_cache;

    bit CE_N;
    bit OE_N;
    bit WE_N;
    bit LB_N;
    bit UB_N;
    bit [19:0] mem_addr;
    wire [63:0] mem_data;

    initial begin	
	    clk=1'b0;
		forever #5 clk = ~clk;
	end

    initial begin 
        rst = '0;
        #35
        rst = '1;
    end

    initial begin
        #35
        //------------------------------------------------------------------------
        //--------------------------- Check write --------------------------------
        cpu_to_cache.addr = 20'b00000000000000000000;
        cpu_to_cache.data = 16'b0000000000000001;
        cpu_to_cache.rw = '1;
        cpu_to_cache.valid = '1;
        $display("Escribiendo %h en la posicion %h", cpu_to_cache.data, cpu_to_cache.addr);

        @ (posedge cache_to_cpu.ready)
        cpu_to_cache.addr = 20'b00000000000000000001;
        cpu_to_cache.data = 16'b0000000000000010;
        cpu_to_cache.rw = '1;
        cpu_to_cache.valid = '1;
        $display("Escribiendo %h en la posicion %h", cpu_to_cache.data, cpu_to_cache.addr);

        // //------------------------------------------------------------------------
        // //---------------------------- Check read --------------------------------
        @ (posedge cache_to_cpu.ready)
        cpu_to_cache.addr = 20'b00000000000000000000;
        cpu_to_cache.rw = '0;
        cpu_to_cache.valid = '1;

        @ (posedge cache_to_cpu.ready)
        $display("Leyendo %h de la posicion %h", cache_to_cpu.data, cpu_to_cache.addr);

        cpu_to_cache.addr = 20'b00000000000000000001;
        cpu_to_cache.rw = '0;
        cpu_to_cache.valid = '1;
        @ (posedge cache_to_cpu.ready)
        $display("Leyendo %h de la posicion %h", cache_to_cpu.data, cpu_to_cache.addr);

        //------------------------------------------------------------------------
        //-------------------- Check write-back and allocate----------------------
        cpu_to_cache.addr = 20'b10000000000000000000;
        cpu_to_cache.rw = '1;
        cpu_to_cache.valid = '1;
        cpu_to_cache.data = 16'b0000000000000011;
        $display("Escribiendo %h en la posicion %h", cpu_to_cache.data, cpu_to_cache.addr);

        @ (posedge cache_to_cpu.ready)
        cpu_to_cache.addr = 20'b10000000000000000001;
        cpu_to_cache.data = 16'b0000000000000100;
        cpu_to_cache.rw = '1;
        cpu_to_cache.valid = '1;
        $display("Escribiendo %h en la posicion %h", cpu_to_cache.data, cpu_to_cache.addr);

        @ (posedge cache_to_cpu.ready)
        cpu_to_cache.addr = 20'b11000000000000000000;
        cpu_to_cache.data = 16'b0000000000000101;
        cpu_to_cache.rw = '1;
        cpu_to_cache.valid = '1;
        $display("Escribiendo %h en la posicion %h", cpu_to_cache.data, cpu_to_cache.addr);

        @ (posedge cache_to_cpu.ready)
        cpu_to_cache.addr = 20'b11000000000000000001;
        cpu_to_cache.data = 16'b0000000000000110;
        cpu_to_cache.rw = '1;
        cpu_to_cache.valid = '1;
        $display("Escribiendo %h en la posicion %h", cpu_to_cache.data, cpu_to_cache.addr);

        @ (posedge cache_to_cpu.ready)
        cpu_to_cache.addr = 20'b00000000000000000000;
        cpu_to_cache.rw = '0;
        cpu_to_cache.valid = '1;

        @ (posedge cache_to_cpu.ready)
        #1
        $display("Leyendo %h de la posicion %h", cache_to_cpu.data, cpu_to_cache.addr);

        cpu_to_cache.addr = 20'b00000000000000000001;
        cpu_to_cache.rw = '0;
        cpu_to_cache.valid = '1;

        @ (posedge cache_to_cpu.ready)
        #1
        $display("Leyendo %h de la posicion %h", cache_to_cpu.data, cpu_to_cache.addr);

        cpu_to_cache.addr = 20'b10000000000000000000;
        cpu_to_cache.rw = '0;
        cpu_to_cache.valid = '1;
        @ (posedge cache_to_cpu.ready)
        #1
        $display("Leyendo %h de la posicion %h", cache_to_cpu.data, cpu_to_cache.addr);

        cpu_to_cache.addr = 20'b10000000000000000001;
        cpu_to_cache.rw = '0;
        cpu_to_cache.valid = '1;
        @ (posedge cache_to_cpu.ready)
        #1
        $display("Leyendo %h de la posicion %h", cache_to_cpu.data, cpu_to_cache.addr);

        cpu_to_cache.addr = 20'b11000000000000000000;
        cpu_to_cache.rw = '0;
        cpu_to_cache.valid = '1;
        @ (posedge cache_to_cpu.ready)
        #1
        $display("Leyendo %h de la posicion %h", cache_to_cpu.data, cpu_to_cache.addr);

        cpu_to_cache.addr = 20'b11000000000000000001;
        cpu_to_cache.rw = '0;
        cpu_to_cache.valid = '1;
        @ (posedge cache_to_cpu.ready)
        #1
        $display("Leyendo %h de la posicion %h", cache_to_cpu.data, cpu_to_cache.addr);
        
    end

    top_memory_hierarchy top_memory_hierarchy_inst (
        .clk (clk),
        .rst (rst),
        .cpu_to_cache (cpu_to_cache),
        .cache_to_cpu (cache_to_cpu),
        .CE_N (CE_N),
        .OE_N (OE_N),
        .WE_N (WE_N),
        .LB_N (LB_N),
        .UB_N (UB_N),
        .mem_addr (mem_addr),
        .mem_data (mem_data)
    );

    sram sram_inst1 (
        .addr (mem_addr),
        .CE_N (CE_N),
        .OE_N (OE_N),
        .WE_N (WE_N),
        .LB_N (LB_N),
        .UB_N (UB_N),
        .data (mem_data[15:0])
    );

    sram sram_inst2 (
        .addr (mem_addr),
        .CE_N (CE_N),
        .OE_N (OE_N),
        .WE_N (WE_N),
        .LB_N (LB_N),
        .UB_N (UB_N),
        .data (mem_data[31:16])
    );

    sram sram_inst3 (
        .addr (mem_addr),
        .CE_N (CE_N),
        .OE_N (OE_N),
        .WE_N (WE_N),
        .LB_N (LB_N),
        .UB_N (UB_N),
        .data (mem_data[47:32])
    );

    sram sram_inst4 (
        .addr (mem_addr),
        .CE_N (CE_N),
        .OE_N (OE_N),
        .WE_N (WE_N),
        .LB_N (LB_N),
        .UB_N (UB_N),
        .data (mem_data[63:48])
    );

endmodule