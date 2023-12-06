`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:50:42 03/23/2023 
// Design Name: 
// Module Name:    tracer 
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
module tracer(
	clk_sample,
	tdc_start,
	lbus_rstn,
	mem_we,
	mem_addr,
	wave_data,
	clk_delay
    );

	input 			clk_sample;
	input  			tdc_start;
	input 			lbus_rstn;
	output 			mem_we;
	output 	[12:0] mem_addr;
	output 	[7:0] wave_data;
	input 			clk_delay;

	// variables
	wire	[7:0] 	processed_data_wire;
	reg 	[7:0]		processed_data_reg;
	wire	[127:0]	tdc_data_wire;
	reg	[127:0]	tdc_data_reg;
	reg 	[12:0]   addr;
	reg				mem_enable;
	reg [9:0]	STATE;
	
	// adder sensor
	wire 	[127:0]	A, B;
	reg 	[127:0]	out;
	wire delay_clk;
	// module
	
	tdc_top tp 		(clk_sample, clk_delay, tdc_data_wire);
	tdc_decode  td0 (.clk(clk_sample), .rst(1'b1), .chainvalue_i(tdc_data_reg), .coded_o(processed_data_wire)); 
	//delay 	d0	(.clk(clk_sample), .delay_out(delay_clk));
	
//	module delay #( parameter delsize=120)
//(input clk,
//output  delay_out
	
	// assign
	assign 	mem_addr 	= 	addr;
	assign	wave_data	=	processed_data_reg;
	assign	mem_we		=	mem_enable;
	
	assign	A				= {16{8'hFF}};
	assign	B				= {{15{8'h00}},7'b0000000,delay_clk};
	
	// always
	
	always @(posedge clk_sample) begin
		
		tdc_data_reg			<= 	tdc_data_wire;
		out						<=  	A + B;
		//processed_data_reg	<= 	addr<<1;
		
		
		if(STATE	== 0) begin
			mem_enable 	<=	0;
			addr			<=	0;
			
			if(tdc_start	== 1'b1) begin
				STATE	<=	1;
			end
		end 
		else if (STATE	== 1) begin
			addr	<= addr + 1;
			mem_enable 	<=	1;
			processed_data_reg	<= 	255;
			STATE	<= 2;
		end
		else if (STATE	== 2) begin
			addr	<= addr + 1;
			mem_enable 	<=	1;
			processed_data_reg	<= 	processed_data_wire;
			if(addr	== 1023) begin
				mem_enable 	<=	0;
				STATE	<= 3;
			end
		end
		else if (STATE	== 3) begin
			STATE	<= 0;
		end
//		else if (STATE	== 0) begin
//		
//		end
//		else if (STATE	== 0) begin
//		
//		end
		
	
	end
	
	




endmodule
