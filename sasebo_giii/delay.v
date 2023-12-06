`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:39:33 03/23/2023 
// Design Name: 
// Module Name:    delay 
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
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:18:03 03/23/2023 
// Design Name: 
// Module Name:    tdc_top 
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
module delay #( parameter delsize=120)
(input clk,
output  delay_out
    );
    
  (* s = "true" *)   wire [delsize-1:0] delLATCH, delLUT;     


//assign out2 = regOut;
//
//always @(negedge clk) 
//	begin
//
//	regOut<= out1;	
//
//
//	end
	

assign delay_out 	= 	delLATCH[delsize-1];
 
 genvar i;
    
	 
////////////////////////// delay with LATCH
generate
        for(i = 0; i < delsize; i = i+1) 
		  begin:gen_code_label3
   
			if(i==0) begin
	
			 (* s = "true" *)           LUT1 #(
            .INIT(2'b10) // Specify LUT Contents
                ) LUT1_insti (
                .O(delLUT[i]), // LUT general output
                .I0(clk) // LUT input
                );
 
 
				 (* s = "true" *)   LDCE #(
            .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
            ) LDCE_Delayi (
            .Q(delLATCH[i]), // Data output
            .CLR(1'b0), // Asynchronous clear/reset input
            .D(delLUT[i]), // Data input
            .G(1'b1), // Gate input
            .GE(1'b1) // Gate enable input
            );
	
			end
			else begin
	
				(* s = "true" *) LUT1 #(
            .INIT(2'b10) // Specify LUT Contents
                ) LUT1_insti (
                .O(delLUT[i]), // LUT general output
                .I0(delLATCH[i-1]) // LUT input
                );
				(* s = "true" *)   LDCE #(
            .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
            ) LDCE_Delayi (
            .Q(delLATCH[i]), // Data output
            .CLR(1'b0), // Asynchronous clear/reset input
            .D(delLUT[i]), // Data input
            .G(1'b1), // Gate input
            .GE(1'b1) // Gate enable input
            );	 
			end			 
        end
    endgenerate




    
endmodule
