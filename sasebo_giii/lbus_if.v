/*-------------------------------------------------------------------------
 AIST-LSI compatible local bus I/F for AES_Comp on FPGA
 *** NOTE *** 
 This circuit works only with AES_Comp.
 Compatibility for another cipher module may be provided in future release.
 
 File name   : lbus_if.v
 Version     : 1.3
 Created     : APR/02/2012
 Last update : APR/11/2012
 Desgined by : Toshihiro Katashita
 
 
 Copyright (C) 2012 AIST
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by AIST ("us").
 
 Permission is hereby granted to copy, reproduce, redistribute or
 otherwise use this code as long as: there is no monetary profit gained
 specifically from the use or reproduction of this code, it is not sold,
 rented, traded or otherwise marketed, and this copyright notice is
 included prominently in any copy made.
 
 We shall not be liable for any damages, including without limitation
 direct, indirect, incidental, special or consequential damages arising
 from the use of this code.
 
 When you publish any results arising from the use of this code, we will
 appreciate it if you can cite our webpage.
(http://www.risec.aist.go.jp/project/sasebo/)
 -------------------------------------------------------------------------*/ 


//================================================ LBUS_IF
module LBUS_IF
  (lbus_a, lbus_di, lbus_do, lbus_wr, lbus_rd, // Local bus
   blk_kin, blk_din, blk_dout, blk_krdy, blk_drdy, blk_kvld, blk_dvld,
   blk_encdec, blk_en, blk_rstn,
   clk, rst, clk_sample, mem_addr, wr_en, wave_data, dyn_delay);                                  // Clock and reset
   
   //------------------------------------------------
   // Local bus
   input [15:0]   lbus_a;  // Address
   input [15:0]   lbus_di; // Input data  (Controller -> Cryptographic module)
   input          lbus_wr; // Assert input data
   input          lbus_rd; // Assert output data
   output [15:0]  lbus_do; // Output data (Cryptographic module -> Controller)

   // Block cipher
   output [127:0] blk_kin;
   output [127:0] blk_din;
   input [127:0]  blk_dout;
   output         blk_krdy, blk_drdy;
   input          blk_kvld, blk_dvld;
   output         blk_encdec, blk_en;
   output         blk_rstn;

   // Clock and reset
   input         clk, rst;
	
	// memory
	input 			clk_sample;
	input [12:0]	mem_addr;
	input 			wr_en;
	input [7:0] 	wave_data;
   //------------------------------------------------
	
	output [15:0]	dyn_delay;
	//------------------------------------------------
	
   reg [15:0]    lbus_do;

   reg [127:0]   blk_kin,  blk_din;
   reg           blk_krdy;
   reg [127:0] 	 blk_dout_reg;
   wire          blk_drdy;
   reg           blk_encdec;
   wire          blk_en = 1;
   reg           blk_rstn;
   
   reg [1:0]     wr;
   reg           trig_wr;
   wire          ctrl_wr;
   reg [2:0]     ctrl;
   reg [3:0]     blk_trig;
	reg [15:0]	  delay;

	//  memory
	 reg [7:0]  mem [1023:0];
	//reg [7:0]  mem0 [511:0];
	//reg [7:0]  mem1 [511:0];
	
	reg [12:0] addr;
	//reg [12:0] addr0;
	//reg [12:0] addr1;
	reg flip;
	reg [15:0] r_data;
	wire [15:0] wire_r_data;
	
	
	
	
	assign wire_r_data = r_data;
	assign dyn_delay	 = delay;
	

   //------------------------------------------------
   always @(posedge clk or posedge rst)
     if (rst) wr <= 2'b00;
     else     wr <= {wr[0],lbus_wr};
   
   always @(posedge clk or posedge rst)
     if (rst)            trig_wr <= 0;
     else if (wr==2'b01) trig_wr <= 1;
     else                trig_wr <= 0;
   
   assign ctrl_wr = (trig_wr & (lbus_a==16'h0002));
   
   always @(posedge clk or posedge rst) 
     if (rst) ctrl <= 3'b000;
     else begin
        if (blk_drdy)       ctrl[0] <= 1;
        else if (|blk_trig) ctrl[0] <= 1;
        else if (blk_dvld)  ctrl[0] <= 0;

        if (blk_krdy)      ctrl[1] <= 1;
        else if (blk_kvld) ctrl[1] <= 0;
        
        ctrl[2] <= ~blk_rstn;
     end

   always @(posedge clk or posedge rst) 
     if (rst)           blk_dout_reg <= 128'h0;
     else if (blk_dvld) blk_dout_reg <= blk_dout;
   
   always @(posedge clk or posedge rst) 
     if (rst)          blk_trig <= 4'h0;
     else if (ctrl_wr) blk_trig <= {lbus_di[0],3'h0};
     else              blk_trig <= {1'h0,blk_trig[3:1]};
   assign blk_drdy = blk_trig[0];

   always @(posedge clk or posedge rst) 
     if (rst)          blk_krdy <= 0;
     else if (ctrl_wr) blk_krdy <= lbus_di[1];
     else              blk_krdy <= 0;

   always @(posedge clk or posedge rst) 
     if (rst)          blk_rstn <= 1;
     else if (ctrl_wr) blk_rstn <= ~lbus_di[2];
     else              blk_rstn <= 1;
   
   //------------------------------------------------
   always @(posedge clk or posedge rst) begin
      if (rst) begin
         blk_encdec <= 0;
         blk_kin <= 128'h0;
         blk_din <= 128'h0;
      end else if (trig_wr) begin
         if (lbus_a==16'h000C) blk_encdec <= lbus_di[0];
         
         if (lbus_a==16'h0100) blk_kin[127:112] <= lbus_di;
         if (lbus_a==16'h0102) blk_kin[111: 96] <= lbus_di;
         if (lbus_a==16'h0104) blk_kin[ 95: 80] <= lbus_di;
         if (lbus_a==16'h0106) blk_kin[ 79: 64] <= lbus_di;
         if (lbus_a==16'h0108) blk_kin[ 63: 48] <= lbus_di;
         if (lbus_a==16'h010A) blk_kin[ 47: 32] <= lbus_di;
         if (lbus_a==16'h010C) blk_kin[ 31: 16] <= lbus_di;
         if (lbus_a==16'h010E) blk_kin[ 15:  0] <= lbus_di;

         if (lbus_a==16'h0140) blk_din[127:112] <= lbus_di;
         if (lbus_a==16'h0142) blk_din[111: 96] <= lbus_di;
         if (lbus_a==16'h0144) blk_din[ 95: 80] <= lbus_di;
         if (lbus_a==16'h0146) blk_din[ 79: 64] <= lbus_di;
         if (lbus_a==16'h0148) blk_din[ 63: 48] <= lbus_di;
         if (lbus_a==16'h014A) blk_din[ 47: 32] <= lbus_di;
         if (lbus_a==16'h014C) blk_din[ 31: 16] <= lbus_di;
         if (lbus_a==16'h014E) blk_din[ 15:  0] <= lbus_di;
			// delay
			if (lbus_a==16'h0150) delay			   <= lbus_di;

      end
		
   end
                
   //------------------------------------------------
   always @(posedge clk or posedge rst)
     if (rst) 
       lbus_do <= 16'h0;
     else if (~lbus_rd)
       lbus_do <= mux_lbus_do(lbus_a, ctrl, blk_encdec, blk_dout);
   
   function  [15:0] mux_lbus_do;
      input [15:0]   lbus_a;
      input [2:0]    ctrl;
      input          blk_encdec;
      input [127:0]  blk_dout;
      
      case(lbus_a)
        16'h0002: mux_lbus_do = ctrl;
        16'h000C: mux_lbus_do = blk_encdec;
        16'h0180: mux_lbus_do = blk_dout_reg[127:112];
        16'h0182: mux_lbus_do = blk_dout_reg[111:96];
        16'h0184: mux_lbus_do = blk_dout_reg[95:80];
        16'h0186: mux_lbus_do = blk_dout_reg[79:64];
        16'h0188: mux_lbus_do = blk_dout_reg[63:48];
        16'h018A: mux_lbus_do = blk_dout_reg[47:32];
        16'h018C: mux_lbus_do = blk_dout_reg[31:16];
        16'h018E: mux_lbus_do = blk_dout_reg[15:0];
		  
		  
		 // 16'h0200, 16'h0202, 16'h0204, 16'h0206, 16'h0208, 16'h020a, 16'h020c, 16'h020e, 16'h0210, 16'h0212, 16'h0214, 16'h0216, 16'h0218, 16'h021a, 16'h021c, 16'h021e, 16'h0220, 16'h0222, 16'h0224, 16'h0226, 16'h0228, 16'h022a, 16'h022c, 16'h022e, 16'h0230, 16'h0232, 16'h0234, 16'h0236, 16'h0238, 16'h023a, 16'h023c, 16'h023e, 16'h0240, 16'h0242, 16'h0244, 16'h0246, 16'h0248, 16'h024a, 16'h024c, 16'h024e, 16'h0250, 16'h0252, 16'h0254, 16'h0256, 16'h0258, 16'h025a, 16'h025c, 16'h025e, 16'h0260, 16'h0262, 16'h0264, 16'h0266, 16'h0268, 16'h026a, 16'h026c, 16'h026e, 16'h0270, 16'h0272, 16'h0274, 16'h0276, 16'h0278, 16'h027a, 16'h027c, 16'h027e, 16'h0280, 16'h0282, 16'h0284, 16'h0286, 16'h0288, 16'h028a, 16'h028c, 16'h028e, 16'h0290, 16'h0292, 16'h0294, 16'h0296, 16'h0298, 16'h029a, 16'h029c, 16'h029e, 16'h02a0, 16'h02a2, 16'h02a4, 16'h02a6, 16'h02a8, 16'h02aa, 16'h02ac, 16'h02ae, 16'h02b0, 16'h02b2, 16'h02b4, 16'h02b6, 16'h02b8, 16'h02ba, 16'h02bc, 16'h02be, 16'h02c0, 16'h02c2, 16'h02c4, 16'h02c6, 16'h02c8, 16'h02ca, 16'h02cc, 16'h02ce, 16'h02d0, 16'h02d2, 16'h02d4, 16'h02d6, 16'h02d8, 16'h02da, 16'h02dc, 16'h02de, 16'h02e0, 16'h02e2, 16'h02e4, 16'h02e6, 16'h02e8, 16'h02ea, 16'h02ec, 16'h02ee, 16'h02f0, 16'h02f2, 16'h02f4, 16'h02f6, 16'h02f8, 16'h02fa, 16'h02fc, 16'h02fe, 16'h0300, 16'h0302, 16'h0304, 16'h0306, 16'h0308, 16'h030a, 16'h030c, 16'h030e, 16'h0310, 16'h0312, 16'h0314, 16'h0316, 16'h0318, 16'h031a, 16'h031c, 16'h031e, 16'h0320, 16'h0322, 16'h0324, 16'h0326, 16'h0328, 16'h032a, 16'h032c, 16'h032e, 16'h0330, 16'h0332, 16'h0334, 16'h0336, 16'h0338, 16'h033a, 16'h033c, 16'h033e, 16'h0340, 16'h0342, 16'h0344, 16'h0346, 16'h0348, 16'h034a, 16'h034c, 16'h034e, 16'h0350, 16'h0352, 16'h0354, 16'h0356, 16'h0358, 16'h035a, 16'h035c, 16'h035e, 16'h0360, 16'h0362, 16'h0364, 16'h0366, 16'h0368, 16'h036a, 16'h036c, 16'h036e, 16'h0370, 16'h0372, 16'h0374, 16'h0376, 16'h0378, 16'h037a, 16'h037c, 16'h037e, 16'h0380, 16'h0382, 16'h0384, 16'h0386, 16'h0388, 16'h038a, 16'h038c, 16'h038e, 16'h0390, 16'h0392, 16'h0394, 16'h0396, 16'h0398, 16'h039a, 16'h039c, 16'h039e, 16'h03a0, 16'h03a2, 16'h03a4, 16'h03a6, 16'h03a8, 16'h03aa, 16'h03ac, 16'h03ae, 16'h03b0, 16'h03b2, 16'h03b4, 16'h03b6, 16'h03b8, 16'h03ba, 16'h03bc, 16'h03be, 16'h03c0, 16'h03c2, 16'h03c4, 16'h03c6, 16'h03c8, 16'h03ca, 16'h03cc, 16'h03ce, 16'h03d0, 16'h03d2, 16'h03d4, 16'h03d6, 16'h03d8, 16'h03da, 16'h03dc, 16'h03de, 16'h03e0, 16'h03e2, 16'h03e4, 16'h03e6, 16'h03e8, 16'h03ea, 16'h03ec, 16'h03ee, 16'h03f0, 16'h03f2, 16'h03f4, 16'h03f6, 16'h03f8, 16'h03fa, 16'h03fc, 16'h03fe: mux_lbus_do = wire_r_data; 
		  16'h0200, 16'h0202, 16'h0204, 16'h0206, 16'h0208, 16'h020a, 16'h020c, 16'h020e, 16'h0210, 16'h0212, 16'h0214, 16'h0216, 16'h0218, 16'h021a, 16'h021c, 16'h021e, 16'h0220, 16'h0222, 16'h0224, 16'h0226, 16'h0228, 16'h022a, 16'h022c, 16'h022e, 16'h0230, 16'h0232, 16'h0234, 16'h0236, 16'h0238, 16'h023a, 16'h023c, 16'h023e, 16'h0240, 16'h0242, 16'h0244, 16'h0246, 16'h0248, 16'h024a, 16'h024c, 16'h024e, 16'h0250, 16'h0252, 16'h0254, 16'h0256, 16'h0258, 16'h025a, 16'h025c, 16'h025e, 16'h0260, 16'h0262, 16'h0264, 16'h0266, 16'h0268, 16'h026a, 16'h026c, 16'h026e, 16'h0270, 16'h0272, 16'h0274, 16'h0276, 16'h0278, 16'h027a, 16'h027c, 16'h027e, 16'h0280, 16'h0282, 16'h0284, 16'h0286, 16'h0288, 16'h028a, 16'h028c, 16'h028e, 16'h0290, 16'h0292, 16'h0294, 16'h0296, 16'h0298, 16'h029a, 16'h029c, 16'h029e, 16'h02a0, 16'h02a2, 16'h02a4, 16'h02a6, 16'h02a8, 16'h02aa, 16'h02ac, 16'h02ae, 16'h02b0, 16'h02b2, 16'h02b4, 16'h02b6, 16'h02b8, 16'h02ba, 16'h02bc, 16'h02be, 16'h02c0, 16'h02c2, 16'h02c4, 16'h02c6, 16'h02c8, 16'h02ca, 16'h02cc, 16'h02ce, 16'h02d0, 16'h02d2, 16'h02d4, 16'h02d6, 16'h02d8, 16'h02da, 16'h02dc, 16'h02de, 16'h02e0, 16'h02e2, 16'h02e4, 16'h02e6, 16'h02e8, 16'h02ea, 16'h02ec, 16'h02ee, 16'h02f0, 16'h02f2, 16'h02f4, 16'h02f6, 16'h02f8, 16'h02fa, 16'h02fc, 16'h02fe, 16'h0300, 16'h0302, 16'h0304, 16'h0306, 16'h0308, 16'h030a, 16'h030c, 16'h030e, 16'h0310, 16'h0312, 16'h0314, 16'h0316, 16'h0318, 16'h031a, 16'h031c, 16'h031e, 16'h0320, 16'h0322, 16'h0324, 16'h0326, 16'h0328, 16'h032a, 16'h032c, 16'h032e, 16'h0330, 16'h0332, 16'h0334, 16'h0336, 16'h0338, 16'h033a, 16'h033c, 16'h033e, 16'h0340, 16'h0342, 16'h0344, 16'h0346, 16'h0348, 16'h034a, 16'h034c, 16'h034e, 16'h0350, 16'h0352, 16'h0354, 16'h0356, 16'h0358, 16'h035a, 16'h035c, 16'h035e, 16'h0360, 16'h0362, 16'h0364, 16'h0366, 16'h0368, 16'h036a, 16'h036c, 16'h036e, 16'h0370, 16'h0372, 16'h0374, 16'h0376, 16'h0378, 16'h037a, 16'h037c, 16'h037e, 16'h0380, 16'h0382, 16'h0384, 16'h0386, 16'h0388, 16'h038a, 16'h038c, 16'h038e, 16'h0390, 16'h0392, 16'h0394, 16'h0396, 16'h0398, 16'h039a, 16'h039c, 16'h039e, 16'h03a0, 16'h03a2, 16'h03a4, 16'h03a6, 16'h03a8, 16'h03aa, 16'h03ac, 16'h03ae, 16'h03b0, 16'h03b2, 16'h03b4, 16'h03b6, 16'h03b8, 16'h03ba, 16'h03bc, 16'h03be, 16'h03c0, 16'h03c2, 16'h03c4, 16'h03c6, 16'h03c8, 16'h03ca, 16'h03cc, 16'h03ce, 16'h03d0, 16'h03d2, 16'h03d4, 16'h03d6, 16'h03d8, 16'h03da, 16'h03dc, 16'h03de, 16'h03e0, 16'h03e2, 16'h03e4, 16'h03e6, 16'h03e8, 16'h03ea, 16'h03ec, 16'h03ee, 16'h03f0, 16'h03f2, 16'h03f4, 16'h03f6, 16'h03f8, 16'h03fa, 16'h03fc, 16'h03fe, 16'h0400, 16'h0402, 16'h0404, 16'h0406, 16'h0408, 16'h040a, 16'h040c, 16'h040e, 16'h0410, 16'h0412, 16'h0414, 16'h0416, 16'h0418, 16'h041a, 16'h041c, 16'h041e, 16'h0420, 16'h0422, 16'h0424, 16'h0426, 16'h0428, 16'h042a, 16'h042c, 16'h042e, 16'h0430, 16'h0432, 16'h0434, 16'h0436, 16'h0438, 16'h043a, 16'h043c, 16'h043e, 16'h0440, 16'h0442, 16'h0444, 16'h0446, 16'h0448, 16'h044a, 16'h044c, 16'h044e, 16'h0450, 16'h0452, 16'h0454, 16'h0456, 16'h0458, 16'h045a, 16'h045c, 16'h045e, 16'h0460, 16'h0462, 16'h0464, 16'h0466, 16'h0468, 16'h046a, 16'h046c, 16'h046e, 16'h0470, 16'h0472, 16'h0474, 16'h0476, 16'h0478, 16'h047a, 16'h047c, 16'h047e, 16'h0480, 16'h0482, 16'h0484, 16'h0486, 16'h0488, 16'h048a, 16'h048c, 16'h048e, 16'h0490, 16'h0492, 16'h0494, 16'h0496, 16'h0498, 16'h049a, 16'h049c, 16'h049e, 16'h04a0, 16'h04a2, 16'h04a4, 16'h04a6, 16'h04a8, 16'h04aa, 16'h04ac, 16'h04ae, 16'h04b0, 16'h04b2, 16'h04b4, 16'h04b6, 16'h04b8, 16'h04ba, 16'h04bc, 16'h04be, 16'h04c0, 16'h04c2, 16'h04c4, 16'h04c6, 16'h04c8, 16'h04ca, 16'h04cc, 16'h04ce, 16'h04d0, 16'h04d2, 16'h04d4, 16'h04d6, 16'h04d8, 16'h04da, 16'h04dc, 16'h04de, 16'h04e0, 16'h04e2, 16'h04e4, 16'h04e6, 16'h04e8, 16'h04ea, 16'h04ec, 16'h04ee, 16'h04f0, 16'h04f2, 16'h04f4, 16'h04f6, 16'h04f8, 16'h04fa, 16'h04fc, 16'h04fe, 16'h0500, 16'h0502, 16'h0504, 16'h0506, 16'h0508, 16'h050a, 16'h050c, 16'h050e, 16'h0510, 16'h0512, 16'h0514, 16'h0516, 16'h0518, 16'h051a, 16'h051c, 16'h051e, 16'h0520, 16'h0522, 16'h0524, 16'h0526, 16'h0528, 16'h052a, 16'h052c, 16'h052e, 16'h0530, 16'h0532, 16'h0534, 16'h0536, 16'h0538, 16'h053a, 16'h053c, 16'h053e, 16'h0540, 16'h0542, 16'h0544, 16'h0546, 16'h0548, 16'h054a, 16'h054c, 16'h054e, 16'h0550, 16'h0552, 16'h0554, 16'h0556, 16'h0558, 16'h055a, 16'h055c, 16'h055e, 16'h0560, 16'h0562, 16'h0564, 16'h0566, 16'h0568, 16'h056a, 16'h056c, 16'h056e, 16'h0570, 16'h0572, 16'h0574, 16'h0576, 16'h0578, 16'h057a, 16'h057c, 16'h057e, 16'h0580, 16'h0582, 16'h0584, 16'h0586, 16'h0588, 16'h058a, 16'h058c, 16'h058e, 16'h0590, 16'h0592, 16'h0594, 16'h0596, 16'h0598, 16'h059a, 16'h059c, 16'h059e, 16'h05a0, 16'h05a2, 16'h05a4, 16'h05a6, 16'h05a8, 16'h05aa, 16'h05ac, 16'h05ae, 16'h05b0, 16'h05b2, 16'h05b4, 16'h05b6, 16'h05b8, 16'h05ba, 16'h05bc, 16'h05be, 16'h05c0, 16'h05c2, 16'h05c4, 16'h05c6, 16'h05c8, 16'h05ca, 16'h05cc, 16'h05ce, 16'h05d0, 16'h05d2, 16'h05d4, 16'h05d6, 16'h05d8, 16'h05da, 16'h05dc, 16'h05de, 16'h05e0, 16'h05e2, 16'h05e4, 16'h05e6, 16'h05e8, 16'h05ea, 16'h05ec, 16'h05ee, 16'h05f0, 16'h05f2, 16'h05f4, 16'h05f6, 16'h05f8, 16'h05fa, 16'h05fc, 16'h05fe: mux_lbus_do = wire_r_data; 
		  
        16'hFFFC: mux_lbus_do = 16'h4702;
        default:  mux_lbus_do = 16'h0000;
      endcase
   endfunction
	
	
	// sample
	
//	always @(posedge clk_sample) begin
//			
//			if(wr_en==1'b1)
//				mem[mem_addr]  <= wave_data;
//			
//	end
//	
	always @(posedge  clk_sample) begin
			
			//addr <= addr +1;
			//flip <= ~flip;
			
			if(wr_en==1'b1) begin
					mem[mem_addr] <= wave_data;
			end
			r_data <= {mem[lbus_a-16'h200],mem[lbus_a-16'h1ff]};
			
			
			
	end
	
   
endmodule // LBUS_IF
