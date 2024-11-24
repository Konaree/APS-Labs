`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2024 06:37:40
// Design Name: 
// Module Name: adder
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// 1-bit full adder
module fulladder(
  input  logic a_i,
  input  logic b_i,
  input  logic carry_i,
  
  output logic sum_o,
  output logic carry_o
);
    
    assign   sum_o = (a_i ^ b_i) ^ carry_i;
    assign carry_o = ((a_i & b_i) | (a_i & carry_i)) | (b_i & carry_i);
    
endmodule : fulladder

// full adder with parameter (QUANT - bit)
module fulladder_parameter #(
  parameter QUANT = 4
  ) (
  input     logic [QUANT-1:0] a_i,
  input     logic [QUANT-1:0] b_i,
  input     logic             carry_i,
 
  output    logic [QUANT-1:0] sum_o,
  output    logic             carry_o
);

    // local declarations
    logic [QUANT:0] c;
    
    // assignements
    assign c[0] = carry_i;
    assign carry_o = c[QUANT];
    
    // instantination
    genvar i;
    generate
      for (i = 0; i < QUANT; i++) begin
        fulladder adder(a_i[i], b_i[i], c[i], sum_o[i], c[i+1]);
      end
    endgenerate
    
////    working principle of instantination. Working zaebis
//    fulladder  adder0 (a_i[0], b_i[0], carry_i, sum_o[0], c[0]);
//    fulladder  adder1 (a_i[1], b_i[1],    c[0], sum_o[1], c[1]);
//    fulladder  adder2 (a_i[2], b_i[2],    c[1], sum_o[2], c[2]);
//    fulladder  adder3 (a_i[3], b_i[3],    c[2], sum_o[3], carry_o);

endmodule : fulladder_parameter