// Cache data memory

import cache_definition::cache_index_type;
import cache_definition::cache_data_type;

module dm_cache_mem (
	input bit clk,
	input cache_index_type data_index,	//data request information: index and we
	input cache_data_type data_write,	//write port
	output cache_data_type data_read);	//read port
	
	cache_data_type mem [0:512];	//1024 entries

	assign data_read = mem [data_index.index];
	
	always_ff @(posedge clk) begin
	
		if (data_index.we)
			mem [data_index.index] <= data_write;		
	end
			
endmodule