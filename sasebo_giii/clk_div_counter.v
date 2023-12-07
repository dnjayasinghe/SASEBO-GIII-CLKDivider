`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:12:40 12/07/2023 
// Design Name: 
// Module Name:    clk_div_counter 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module clk_div_counter(
   clk_in,
	clk_sample,
	counter_out
	);
		
		parameter  SIZE = 8;
		
		input 			clk_in;
		input 			clk_sample;
		output [SIZE -1:0]	counter_out;
		
		
		wire 	  [SIZE -1:0]	counter;	
		reg	  [SIZE -1:0]	counter_reg;		
		
		
		assign counter_out = counter_reg;
		
		genvar i;
		generate  
			for (i=1;i< SIZE; i=i+1)	begin
				if(i==1) begin
					clk_div cd( .clk_in(clk_in), 	.clk_out(counter[i]));
				end
				else begin
					clk_div cd( .clk_in(counter[i-1]), 	.clk_out(counter[i]));
				end
		
			end
		endgenerate
			
			
			
			always @(posedge clk_sample) begin
				
				counter_reg <= counter;
			
			end
			
			
		

endmodule
