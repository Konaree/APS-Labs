`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.11.2024 02:02:31
// Design Name: 
// Module Name: instr_mem
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


module instr_mem
import memory_pkg::INSTR_MEM_SIZE_BYTES;
import memory_pkg::INSTR_MEM_SIZE_WORDS;
(
  input  logic [31:0] read_addr_i,
  output logic [31:0] read_data_o
);

  logic [31:0] ROM [INSTR_MEM_SIZE_WORDS];  // ������� ������ �
                                            // <INSTR_MEM_SIZE_WORDS>
                                            // 32-������ �����

  initial begin
    $readmemh("program.mem", ROM);          // ��������� � ������ ROM ����������
  end                                       // ����� program.mem

  // ���������� ������������ ����� �� ������, ��� �� ����� ��� ������ ������
  // ����������, ������������� �� ������ read_addr_i, � ������� �������� ���
  // ������� ����, � ����� ����, �������� ��� ������� ��������� ������ ������
  // ������ � ������.
  // ��� ������� ���� ��������, ����� ���������� ����������� ������ � ������,
  // � �� ����� ��� ������� ���� ��������, ����� �� ���� ���������� � ������
  // �� ������� �������������� ����� (������ ����� ����� ������ ������ �����,
  // ������������� �� ������� �������).
  assign read_data_o = ROM[read_addr_i[$clog2(INSTR_MEM_SIZE_BYTES)-1:2]];

endmodule
