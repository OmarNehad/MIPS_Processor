`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  ETH Zurich
// Engineer: Frank K. Gurkaynak
// 
// Create Date:    12:51:05 03/17/2011 
// Design Name:    MIPS processor
// Module Name:    ALU 
// Project Name:   Digital Circuits Lab Exercuse
// Target Devices: 
// Tool versions: 
// Description:    This is one possible solution to the
//                 ALU description from Lab5a
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module ALU( 
  input CLK,            // Clock signal
  input RESET,          // Reset Active low will set back the lo

  input  [31:0] a,
  input  [31:0] b,
  input  [5:0] aluop,
  input [4:0] ShAmt,
  output [31:0] result,
  output zero
 );
  
  wire [31:0] logicout;   // output of the logic block
  wire [31:0] addout;     // adder subtractor out
  wire [31:0] arithout;   // output after alt
  wire [31:0] n_b;        // inverted b
  wire [31:0] sel_b;      // select b or n_b;
  wire [31:0] slt;        // output of the slt extension
  
  wire [1:0] logicsel;    // lower two bits of aluop;
  
  wire[31:0] finalout;
  
  // logic select 
  assign logicsel = aluop[1:0];
  assign logicout = (logicsel == 2'b00) ? a & b :
                    (logicsel == 2'b01) ? a | b :
                    (logicsel == 2'b10) ? a ^ b :
                                        ~(a | b);
  
  // adder subtractor
  assign n_b = ~b ;  // invert b
  assign sel_b = (aluop[1])? n_b : b ;
  // if the operation is sub or slt: 1 (aluop[1]) is added to realize the 2-complement format
  assign addout = a + sel_b + aluop[1];
  
  // set less than operator: extend the MSB bit (sign bit) of addout
  assign slt = { 32{addout[31]}};
  
  // arith out
  assign arithout = (aluop[3]) ? slt : addout;
  
  // final out
  //assign result = (aluop[2]) ? logicout : arithout;
  assign finalout = (aluop[2]) ? logicout : arithout;
  
// ME: Added code to realize srl, multu and mflo and register Lo
  reg [31:0] lo; // LO register that will hold the output of mutlu
  //srl: shift B by ShAmt
  // mflo (move from lo): propagates Lo into output
  always @ ( posedge CLK, posedge RESET ) 
    if (RESET == 1'b1) lo = 32'b0; // reset lo register
    else if(aluop == 6'b011001) lo = a*b;  // perform mutlu and store in lo
  
  assign result = (aluop == 6'b000010) ? b >> ShAmt: //srl
                  (aluop == 6'b010010) ? lo : finalout; //mflo
  
  // the zero
  assign zero = result ? 0: 1;
  
endmodule
