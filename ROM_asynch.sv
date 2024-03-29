// ROM asincrona de 1K x 64

module ROM_asynch (address, dout);

	parameter INIT_FILE;

	input [9:0] address;
	output reg [64:0] dout;

	reg [64:0] mem [0:1024];

	initial	
		$readmemh(INIT_FILE, mem, 0);
		
	assign dout = mem [address];

endmodule