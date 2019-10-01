//--------------------------------------------------------------------------------------------

// Direct mapped cache controller 

//--------------------------------------------------------------------------------------------


import cache_definition::*;

module dm_cache_controller (
	input bit clk,
	input bit rst,
	input cpu_to_cache_type cpu_to_cache,
	input mem_to_cache_type mem_to_cache,
	output cache_to_mem_type cache_to_mem,
	output cache_to_cpu_type cache_to_cpu);
	
	//posible states
	typedef enum { compare_tag, allocate, write_back } cache_state_type;
	
	//state register
	cache_state_type current_state, next_state;
	
	//signals to "look up table"
	cache_table_type table_read;		//read port
	cache_table_type table_write;		//write port
	cache_index_type table_index; 	//table request information: index and we
	
	//signals to cache memory
	cache_data_type data_read;		//read port
	cache_data_type data_write;		//write port
	cache_index_type data_index;	//cache memory request information: index and we
	
	//temporary variable for cache result (cache -> cpu)
	cache_to_cpu_type next_cache_to_cpu;
	
	//temporary variables for memory request (cache -> memory)
	cache_to_mem_type next_cache_to_mem;

	//variables for register (cpu -> cache)
	cpu_to_cache_type next_cpu_to_cache;
	
	//connect to output ports
	assign cache_to_mem = next_cache_to_mem;
	assign cache_to_cpu = next_cache_to_cpu;
	
	always_comb begin
		
		//-------------------------------------------------------------------------------
		//-------------------	default values for all signals	------------------------
		
		//no state change by default
		next_state = current_state;
		
		next_cache_to_cpu = '{0,0,0};
		table_write = '{0,0,0};
		
		//table index by default
		table_index.we = '0;
		table_index.index = next_cpu_to_cache.addr [13:4];
		
		//cache memory index by default
		data_index.we = '0;
		data_index.index = next_cpu_to_cache.addr [13:4];

		//Modify word		
		data_write = data_read;
		case (next_cpu_to_cache.addr [3:2])
			2'b00: data_write[31:0] = next_cpu_to_cache.data;
			2'b01: data_write[63:32] = next_cpu_to_cache.data;
			2'b10: data_write[95:64] = next_cpu_to_cache.data;
			2'b11: data_write[127:96] = next_cpu_to_cache.data;
		endcase	
		
		//Read word
		case (next_cpu_to_cache.addr [3:2])
			2'b00: next_cache_to_cpu.data = data_read[31:0];
			2'b01: next_cache_to_cpu.data = data_read[63:32];
			2'b10: next_cache_to_cpu.data = data_read[95:64];
			2'b11: next_cache_to_cpu.data = data_read[127:96];
		endcase
	
		//memory request address
		next_cache_to_mem.addr = next_cpu_to_cache.addr;
		
		//memory request data
		next_cache_to_mem.data = data_read;
		
		next_cache_to_mem.rw = '0;
		next_cache_to_mem.valid = '0;
		
		//-------------------------------------------------------------------------------------
		
		//-------------------------------------------------------------------------------------
		//---------------------------------	Cache FSM	---------------------------------------
		
		case (current_state)
			
			compare_tag: begin
				//If valid bit is set to 1, then there is a cpu opperation
				if (next_cpu_to_cache.valid && rst) begin
				
					//Cache hit
					if ((next_cpu_to_cache.addr[19:14] == table_read.tag) && table_read.valid) begin
						
						if (!next_cpu_to_cache.rw)
                            next_cache_to_cpu.ready = '1;
						
						//write hit
						if (next_cpu_to_cache.rw) begin
							table_index.we = '1;
							data_index.we = '1;
							
							//No changes in cache table
							table_write.tag = table_read.tag;
							table_write.valid = '1;
							
							table_write.dirty = '1;	//We are changing the data value
						end
						
						//next_state = idle;
					end
					
					//Cache miss
					else begin
						next_cache_to_cpu.stopped = '1;

						//Change "look up table"
						table_index.we = '1;
						table_write.valid = '1;
						table_write.tag = next_cpu_to_cache.addr [19:14];
						table_write.dirty = next_cpu_to_cache.rw;	//Is dirty if it is a write
						
						next_cache_to_mem.valid = '1;	//Generate a request to memory
						
						if (table_read.valid == '0 || table_read.dirty == '0)
							next_state = allocate;
						
						else begin
						//Miss with dirty bit
							//Write-back address
							next_cache_to_mem.addr = {table_read.tag, next_cpu_to_cache.addr [13:0]};
							next_cache_to_mem.rw = '1;
							
							next_state = write_back;
						end
					end
				end
			end
			
			allocate: begin
				next_cache_to_cpu.stopped = '1;
				next_cache_to_mem.valid = '1;

				//Memory is ready
				if(mem_to_cache.ready) begin
					next_state = compare_tag;

					data_index.we = '1;	
					next_cache_to_mem.valid = '0;					
					data_write = mem_to_cache.data;
				end
			end
			
			write_back: begin
				next_cache_to_cpu.stopped = '1;
				
				//Write-back is completed
				if(mem_to_cache.ready) begin
					next_cache_to_mem.valid = '1;
					next_cache_to_mem.rw = '0;
					
					next_state = allocate;
				end
			end
		
		endcase
	end
	
	always_ff @(posedge clk) begin
		if(!rst) 
			current_state <= compare_tag;
		else
			current_state <= next_state;
	end

	always_ff @(posedge clk) begin
		if (cache_to_cpu.stopped)
			next_cpu_to_cache <= next_cpu_to_cache;
		else
			next_cpu_to_cache <= cpu_to_cache;
	end

	//Instanciate dm_cache_mem and dm_cache_table
	
	dm_cache_mem dm_cache_mem_inst (
		.clk (clk),
		.data_index (data_index),
		.data_write (data_write),
		.data_read (data_read)
	);

	dm_cache_table dm_cache_table_inst (
		.clk (clk),
		.table_index (table_index),
		.table_write (table_write),
		.table_read (table_read)
	);
	
endmodule