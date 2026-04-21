`timescale 1ns / 1ps

module processor_core (
  input  logic        clk_i,
  input  logic        rst_i,

  input  logic        stall_i,
  input  logic [31:0] instr_i,
  input  logic [31:0] mem_rd_i,

  output logic [31:0] instr_addr_o,
  output logic [31:0] mem_addr_o,
  output logic [ 2:0] mem_size_o,
  output logic        mem_req_o,
  output logic        mem_we_o,
  output logic [31:0] mem_wd_o
);

  logic [ 1:0] wb_sel;
  logic [ 1:0] a_sel;
  logic [ 2:0] b_sel;
  logic [31:0] wb_data;
  logic        alu_flag;

  // for memory
  logic [ 3:0] mem_size;
  logic        mem_req;
  logic        mem_we;

  // jumps and branches
  logic        jal;
  logic        jalr;
  logic        b;

  // general purpose registers
  logic [ 4:0] write_addr;
  logic [ 4:0] read_addr1;
  logic [ 4:0] read_addr2;
  logic [31:0] read_data1;
  logic [31:0] read_data2;
  logic        gpr_we;
  logic        reg_file_we;

  // immediates
  logic [31:0] imm_I;
  logic [31:0] imm_U;
  logic [31:0] imm_S;
  logic [31:0] imm_B;
  logic [31:0] imm_J;

  // Program Counter
  logic [31:0] pc_ff;
  logic [31:0] pc_next;
  logic [31:0] pc_sum;

  logic [31:0] jalr_destination;
  logic [31:0] b_mux_o;
  logic        pc_or;
  logic        pc_and;

  // alu
  logic [ 4:0] alu_op;
  logic [31:0] alu_a;
  logic [31:0] alu_b;
  logic [31:0] alu_result;

  // -----------------------------------------
  // ------------   MEM OUTPUTS   ------------
  // -----------------------------------------
  assign mem_size_o = mem_size;
  assign mem_req_o  = mem_req;
  assign mem_we_o   = mem_we;

  // -----------------------------------------
  // ----   General Purpose Registers   ------
  // -----------------------------------------
  assign mem_wd_o    = read_data2;
  assign write_addr  = instr_i[11: 7];
  assign read_addr1  = instr_i[19:15];
  assign read_addr2  = instr_i[24:20];
  assign reg_file_we = gpr_we && !stall_i;

  // -----------------------------------------
  // ---------   IMM assignements   ----------
  // -----------------------------------------
  assign imm_I = { {20{instr_i[31]}}, {instr_i[31:20]} };
  assign imm_U = { {instr_i[31:12]}, 12'h0 };
  assign imm_S = { {20{instr_i[31]}}, {instr_i[31:25]}, {instr_i[11:7]} };
  assign imm_B = { {20{instr_i[31]}}, {instr_i[7]}, {instr_i[30:25]}, instr_i[11:8], 1'b0 };
  assign imm_J = { {12{instr_i[31]}}, {instr_i[19:12]}, {instr_i[20]}, {instr_i[30:21]}, 1'b0 };

  // Instruction Addres output from Prog Counter
  assign instr_addr_o = pc_ff;

  // Memory Address
  assign mem_addr_o = alu_result;

  // -----------------------------------------
  // ----   Program Counter Realisation   ----
  // -----------------------------------------
  assign jalr_destination = read_data1 + imm_I;

  assign pc_and  = alu_flag && b;
  assign pc_or   = jal || pc_and;
  assign b_mux_o = (b) ? imm_B : imm_J;

  assign pc_sum  = (pc_or) ? b_mux_o : 32'd4;
  assign pc_next = (jalr) ? {jalr_destination[31:1], 1'b0} : pc_ff + pc_sum;
//  assign pc_next = pc_ff + pc_sum;

  always_ff @(posedge clk_i) begin
    if(rst_i)
      pc_ff <= '0;
    else
      pc_ff <= (stall_i) ? pc_ff : pc_next; // if stall_i = 0 processor is stalled
  end

  // -----------------------------------------
  // ---------   ALU realisation   -----------
  // -----------------------------------------
  always_comb begin
    case(a_sel)
      2'b00:   alu_a = read_data1;
      2'b01:   alu_a = pc_ff;
      2'b10:   alu_a = 1'b0;
      default: alu_a = '0;
    endcase
  end

  always_comb begin
    case (b_sel)
      3'd0:    alu_b = read_data2;
      3'd1:    alu_b = imm_I;
      3'd2:    alu_b = imm_U;
      3'd3:    alu_b = imm_S;
      3'd4:    alu_b = 32'd4; 
      default: alu_b = '0;
    endcase
  end

  // -----------------------------------------
  // --------   WB Data Selection   ----------
  // -----------------------------------------
  always_comb begin
    case (wb_sel)
      2'd0:    wb_data = alu_result;
      2'd1:    wb_data = mem_rd_i;
      default: wb_data = '0;
    endcase
  end

  register_file reg_file (
    .clk_i(clk_i), .write_enable_i(reg_file_we), .write_addr_i(write_addr), .read_addr1_i(read_addr1), .read_addr2_i(read_addr2), .write_data_i(wb_data), .read_data1_o(read_data1), .read_data2_o(read_data2)
  );

  decoder decoder (
    .fetched_instr_i(instr_i), .a_sel_o(a_sel), .b_sel_o(b_sel), .wb_sel_o(wb_sel),
    .alu_op_o(alu_op), .mem_req_o(mem_req), .mem_we_o(mem_we), .gpr_we_o(gpr_we), .mem_size_o(mem_size),
    .jalr_o(jalr), .jal_o(jal), .branch_o(b)
  );

  alu alu (
    .a_i(alu_a), .b_i(alu_b), .alu_op_i(alu_op), .flag_o(alu_flag), .result_o(alu_result)
  );

endmodule
