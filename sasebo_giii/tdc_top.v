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
module tdc_top #(parameter size =32, parameter delsize=120)
(input clk,
input clk_delay,
output[(size*4)-1:0] out1
    );
    
  (* s = "true" *)   wire [size*4-1:0] co1;
  (* s = "true" *)   wire [size*4-1:0] do1;
  //(* s = "true" *)   wire [size*4-1:0] out1;
  (* s = "true" *)   reg [size*4-1:0] regOut;
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
	



			 (* s = "true" *)           LUT1 #(
            .INIT(2'b10) // Specify LUT Contents
                ) LUT1_inst0 (
                .O(delLUT[0]), // LUT general output
                .I0(clk_delay) // LUT input
                );
 
 
				 (* s = "true" *)   LDCE #(
            .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
            ) LDCE_Delay0 (
            .Q(delLATCH[0]), // Data output
            .CLR(1'b0), // Asynchronous clear/reset input
            .D(delLUT[0]), // Data input
            .G(1'b1), // Gate input
            .GE(1'b1) // Gate enable input
            );

			 (* s = "true" *)           LUT1 #(
            .INIT(2'b10) // Specify LUT Contents
                ) LUT1_inst1 (
                .O(delLUT[1]), // LUT general output
                .I0(delLATCH[0]) // LUT input
                );
 
 
				 (* s = "true" *)   LDCE #(
            .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
            ) LDCE_Delay1 (
            .Q(delLATCH[1]), // Data output
            .CLR(1'b0), // Asynchronous clear/reset input
            .D(delLUT[1]), // Data input
            .G(1'b1), // Gate input
            .GE(1'b1) // Gate enable input
            );

			
			
			
			(* s = "true" *)           LUT1 #(
            .INIT(2'b10) // Specify LUT Contents
                ) LUT1_inst2 (
                .O(delLUT[2]), // LUT general output
                .I0(delLATCH[1]) // LUT input
                );
 
 
				 (* s = "true" *)   LDCE #(
            .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
            ) LDCE_Delay2 (
            .Q(delLATCH[2]), // Data output
            .CLR(1'b0), // Asynchronous clear/reset input
            .D(delLUT[2]), // Data input
            .G(1'b1), // Gate input
            .GE(1'b1) // Gate enable input
            );

 
 genvar i;
    generate
        for(i = 0; i < size; i = i+1) 
		  begin:gen_code_label1  
            
				
				if (i==0) begin
				(* s = "true" *)   CARRY4 CARRY4_insti (
            .CO(co1[(((i+1)*4)-1):(i*4)]), // 4-bit carry out
            .O(), // 4-bit carry chain XOR data out
            .CI(), // 1-bit carry cascade input
            .CYINIT(clk_delay), // 1-bit carry initialization
            //.CYINIT(delLATCH[delsize-1]), // 1-bit carry initialization
            .DI(4'h0), // 4-bit carry-MUX data in
            .S(4'hf) // 4-bit carry-MUX select input
            );
				end
				else begin
				
				 (* s = "true" *)    CARRY4 CARRY4_insti (
            .CO(co1[(((i+1)*4)-1):(i*4)]), // 4-bit carry out
            .O(), // 4-bit carry chain XOR data out
            .CI(co1[(i*4)-1]), // 1-bit carry cascade input
            .CYINIT(), // 1-bit carry initialization
            .DI(4'h0), // 4-bit carry-MUX data in
            .S(4'hf) // 4-bit carry-MUX select input
            );
				end
       end  
    endgenerate 



  generate
        for(i = 0; i < size*4; i = i+1) 
		  begin:gen_code_label2
			 (* s = "true" *)   LDPE #(
            .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
            ) LDPE_insti (
            .Q(out1[i]), // Data output
            .PRE(1'b0), // Asynchronous clear/reset input
            .D(co1[i]), // Data input
            .G(clk), // Gate input
            .GE(1'b1) // Gate enable input
            );
        end
    endgenerate

//INST "tp/gen_code_label2[124].LDPE_insti" AREA_GROUP = "pblock_1";
//LDCE LDCE_inst (
//.Q(Q), // Data output
//.CLR(CLR), // Asynchronous clear/reset input
//.D(D), // Data input
//.G(G), // Gate input
//.GE(GE) // Gate enable input
//);


//	 always @(posedge clk)
//	 begin
//	(* keep = "true" *) (* s = "true" *) Cout<=out1;
	 
//	 end
//	 
//////////////////////////// delay with LATCH
//generate
//        for(i = 0; i < delsize; i = i+1) 
//		  begin:gen_code_label3
//   
//			if(i==0) begin
//	
//			 (* s = "true" *)           LUT1 #(
//            .INIT(2'b10) // Specify LUT Contents
//                ) LUT1_insti (
//                .O(delLUT[i]), // LUT general output
//                .I0(clk_delay) // LUT input
//                );
// 
// 
//				 (* s = "true" *)   LDCE #(
//            .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
//            ) LDCE_Delayi (
//            .Q(delLATCH[i]), // Data output
//            .CLR(1'b0), // Asynchronous clear/reset input
//            .D(delLUT[i]), // Data input
//            .G(1'b1), // Gate input
//            .GE(1'b1) // Gate enable input
//            );
//	
//			end
//			else begin
//	
//				(* s = "true" *) LUT1 #(
//            .INIT(2'b10) // Specify LUT Contents
//                ) LUT1_insti (
//                .O(delLUT[i]), // LUT general output
//                .I0(delLATCH[i-1]) // LUT input
//                );
//				(* s = "true" *)   LDCE #(
//            .INIT(1'b0) // Initial value of latch (1'b0 or 1'b1)
//            ) LDCE_Delayi (
//            .Q(delLATCH[i]), // Data output
//            .CLR(1'b0), // Asynchronous clear/reset input
//            .D(delLUT[i]), // Data input
//            .G(1'b1), // Gate input
//            .GE(1'b1) // Gate enable input
//            );	 
//			end			 
//        end
//    endgenerate




    
endmodule
