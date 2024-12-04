`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.12.2024 11:06:53
// Design Name: 
// Module Name: cybercobra
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


module CYBERcobra (
  input  logic         clk_i,
  input  logic         rst_i,
  input  logic [15:0]  sw_i,
  output logic [31:0]  out_o
);

  logic [31:0] prog_counter;
  logic [31:0] instr;
  logic [31:0] reg_data2;
  logic [31:0] constant;
  logic [ 1:0] write_src;
  logic [31:0] write_data;
  logic [31:0] alu_result;
  logic [31:0] offset_const;
  logic [31:0] prog_counter_sum;
  logic        write_enable;

  logic        branch;
  logic        alu_flag;
  logic        jump;
  logic        cervelat;
  
  assign branch       = instr[30];
  assign jump         = instr[31];
  assign constant     = { {9{instr[27]}}, instr[27:5] };
  assign write_src    = instr[29:28];
  assign offset_const = { {12{instr[12]}}, instr[12:5], 2'b0 };
  assign cervelat     = (alu_flag & branch) | jump;
  assign write_enable = ~(jump | branch);

  assign prog_counter_sum = (cervelat) ? offset_const : 32'd4;

  always_ff @(posedge(clk_i)) begin
    if (rst_i)
      prog_counter <= 32'd0;
    else 
      prog_counter <= prog_counter + prog_counter_sum;
  end;
  
  always_comb begin
    case (write_src)
      2'd0:    write_data = constant;
      2'd1:    write_data = alu_result;
      2'd2:    write_data = {{16{sw_i[15]}}, {sw_i[15:0]}};
      default: write_data = 32'd0;
    endcase;
  end;
  
  instr_mem imem
  (
    .read_addr_i(prog_counter),
    .read_data_o(instr)
  );

  register_file register_file
  (
    .clk_i          (clk_i),
    .read_addr1_i   (instr[22:18]),
    .read_addr2_i   (instr[17:13]),
    .write_addr_i   (instr[ 4: 0]),
    .read_data1_o   (out_o),
    .read_data2_o   (reg_data2),
    .write_data_i   (write_data),
    .write_enable_i (write_enable)
  );  
  
  alu alu
  (
    .alu_op_i (instr[27:23]),
    .a_i      (out_o),
    .b_i      (reg_data2),
    .flag_o   (alu_flag),
    .result_o (alu_result)
  );
  

endmodule
