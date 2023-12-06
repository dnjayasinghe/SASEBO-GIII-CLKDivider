`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:03:47 12/04/2023 
// Design Name: 
// Module Name:    clk_div 
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
module clk_div(
	input clk_in,
	output clk_out
);

wire c1, c2;

assign clk_out  = c1;

	LUT1 #(
	.INIT(2'b01) // Specify LUT Contents
	) LUT1_inst (
		.O(c2), // LUT general output
		.I0(c1) // LUT input
	);
	
	FDCE #(
	.INIT(1'b0) // Initial value of register (1'b0 or 1'b1)
	) FDCE_inst (
		.Q(c1), // 1-bit Data output
		.C(clk_in), // 1-bit Clock input
		.CE(1'b1), // 1-bit Clock enable input
		.CLR(1'b0), // 1-bit Asynchronous clear input
		.D(c2) // 1-bit Data input
	);



endmodule