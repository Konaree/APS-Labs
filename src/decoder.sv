`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Islamov Amir
// 
// Create Date: 01.02.2025 04:43:33
// Design Name: 
// Module Name: decoder
// Project Name: RISC-V Decoder
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


module decoder (
  input  logic [31:0]  fetched_instr_i,
  output logic [1:0]   a_sel_o,
  output logic [2:0]   b_sel_o,
  output logic [4:0]   alu_op_o,
  output logic [2:0]   csr_op_o,
  output logic         csr_we_o,
  output logic         mem_req_o,
  output logic         mem_we_o,
  output logic [2:0]   mem_size_o,
  output logic         gpr_we_o,
  output logic [1:0]   wb_sel_o,
  output logic         illegal_instr_o,
  output logic         branch_o,
  output logic         jal_o,
  output logic         jalr_o,
  output logic         mret_o
);

  import decoderd_pkg::*;

//  local declarations
  logic [ 2:0] funct3;
  logic [ 6:0] funct7;
  logic [ 6:0] opcode;
  logic [24:0] syst;

//  assignations
  assign opcode = fetched_instr_i[ 6:0];
  assign funct3 = fetched_instr_i[14:12];
  assign funct7 = fetched_instr_i[31:25];
  assign syst   = fetched_instr_i[31: 7];

  always_comb begin
    illegal_instr_o = '0;
    gpr_we_o        = '0;
    csr_op_o        = '0;
    csr_we_o        = '0;
    mem_req_o       = '0;
    mem_we_o        = '0;
    mem_size_o      = '0;
    branch_o        = '0;
    jal_o           = '0;
    jalr_o          = '0;
    mret_o          = '0;

    case(opcode) // OPCODE check
      OP_OPCODE: begin // Two Reg_Sources are fed to the ALU
        a_sel_o  = OP_A_RS1;     
        b_sel_o  = OP_B_RS2;              
        wb_sel_o = WB_EX_RESULT; 

        case(funct3) // funct3 check
          3'h0: begin
            case(funct7) // funct 7 check
              7'h00: begin 
                alu_op_o = ALU_ADD;
                gpr_we_o = 1'b1;
              end
              7'h20: begin
                gpr_we_o = 1'b1;
                alu_op_o = ALU_SUB;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end

          3'h4: begin
            case(funct7)
              7'h00: begin
                gpr_we_o = 1'b1;
                alu_op_o = ALU_XOR;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end

          3'h6: begin
            case(funct7)
              7'h00: begin
                gpr_we_o = 1'b1;
                alu_op_o = ALU_OR;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end
          
          3'h7: begin
            case(funct7)
              7'h00: begin
                gpr_we_o = 1'b1;
                alu_op_o = ALU_AND;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end
          
          3'h1: begin
            case(funct7)
              7'h00: begin
                gpr_we_o = 1'b1;
                alu_op_o = ALU_SLL;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end

          3'h5: begin
            case(funct7)
              7'h00: begin
                alu_op_o = ALU_SRL;
                gpr_we_o = 1'b1;
              end
              7'h20: begin
                alu_op_o = ALU_SRA;
                gpr_we_o = 1'b1;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end

          3'h2: begin
            case(funct7)
              7'h00: begin
                gpr_we_o = 1'b1;
                alu_op_o = ALU_SLTS;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end

          3'h3: begin
            case(funct7)
              7'h00: begin
                gpr_we_o = 1'b1;
                alu_op_o = ALU_SLTU;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end
          
          default: illegal_instr_o = 1'b1;
        endcase
      end

      OP_IMM_OPCODE: begin // One Reg_Source and one Imm are fed to the ALU
        a_sel_o  = OP_A_RS1;     // a_signal     - from reg_file
        b_sel_o  = OP_B_IMM_I;   // b_signal     - constant
        wb_sel_o = WB_EX_RESULT; // Write_Back   - from ALU

        case(funct3)
          3'h0: begin
            alu_op_o = ALU_ADD;
            gpr_we_o = 1'b1;
          end
          3'h4: begin
            alu_op_o = ALU_XOR;
            gpr_we_o = 1'b1;
          end
          3'h6: begin
            alu_op_o = ALU_OR;
            gpr_we_o = 1'b1;
          end
          3'h7: begin
            alu_op_o = ALU_AND;
            gpr_we_o = 1'b1;
          end
          3'h2: begin
            alu_op_o = ALU_SLTS;
            gpr_we_o = 1'b1;
          end
          3'h3: begin
            alu_op_o = ALU_SLTU;
            gpr_we_o = 1'b1;
          end

          3'h1: begin
            case(funct7)
              7'h00: begin
                alu_op_o = ALU_SLL;
                gpr_we_o = 1'b1;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end

          3'h5: begin
            case(funct7)
              7'h00: begin
                alu_op_o = ALU_SRL;
                gpr_we_o = 1'b1;
              end
              7'h20: begin
                alu_op_o = ALU_SRA;
                gpr_we_o = 1'b1;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end

          default: illegal_instr_o = 1'b1;
        endcase
      end

      LOAD_OPCODE: begin // Load from the memory
        a_sel_o   = OP_A_RS1;     // a_signal    - from reg_file
        b_sel_o   = OP_B_IMM_I;   // b_signal    - constant
        wb_sel_o  = WB_LSU_DATA;  // Write_Back  - from the memory
        alu_op_o  = ALU_ADD;
        case(funct3)
          3'h0: begin
            gpr_we_o  = 1'b1;
            mem_req_o = 1'b1;
            mem_size_o= LDST_B;
          end
          3'h1: begin
            gpr_we_o  = 1'b1;
            mem_req_o = 1'b1;
            mem_size_o= LDST_H;
          end
          3'h2: begin
            gpr_we_o  = 1'b1;
            mem_req_o = 1'b1;
            alu_op_o  = ALU_ADD;
            mem_size_o= LDST_W;
          end
          3'h4: begin
            gpr_we_o  = 1'b1;
            mem_req_o = 1'b1;
            mem_size_o= LDST_BU;
          end
          3'h5: begin
            gpr_we_o  = 1'b1;
            mem_req_o = 1'b1;
            mem_size_o= LDST_HU;
          end
          default: illegal_instr_o = 1'b1;
        endcase
      end

      STORE_OPCODE: begin // Store to the memory
        a_sel_o   = OP_A_RS1;     // a_signal      - from reg_file
        b_sel_o   = OP_B_IMM_S;   // b_signal      - constant
        wb_sel_o  = WB_EX_RESULT; // Write_Back    - doesn't matter
        alu_op_o  = ALU_ADD;      // ALU_operation - ADD

        case(funct3)
          3'h0: begin
            mem_size_o = LDST_B;
            mem_req_o  = 1'b1;
            mem_we_o   = 1'b1;
          end
          3'h1: begin
            mem_size_o = LDST_H;
            mem_req_o  = 1'b1;
            mem_we_o   = 1'b1;
          end
          3'h2: begin
            mem_size_o = LDST_W;
            mem_req_o  = 1'b1;
            mem_we_o   = 1'b1;
          end
          default: illegal_instr_o = 1'b1;
        endcase
      end

      BRANCH_OPCODE: begin
        a_sel_o  = OP_A_RS1;
        b_sel_o  = OP_B_RS2;
        wb_sel_o = WB_EX_RESULT;

        case(funct3)
          3'h0: begin
            alu_op_o = ALU_EQ;
            branch_o = 1'b1;
            end
          3'h1: begin
            alu_op_o = ALU_NE;
            branch_o = 1'b1;
            end
          3'h4: begin
            alu_op_o = ALU_LTS;
            branch_o = 1'b1;
            end
          3'h5: begin
            alu_op_o = ALU_GES;
            branch_o = 1'b1;
            end
          3'h6: begin
            alu_op_o = ALU_LTU;
            branch_o = 1'b1;
            end
          3'h7: begin
            alu_op_o = ALU_GEU;
            branch_o = 1'b1;
            end
          default: illegal_instr_o = 1'b1;
        endcase
      end

      JAL_OPCODE: begin
        a_sel_o  = OP_A_CURR_PC;
        b_sel_o  = OP_B_INCR;
        gpr_we_o = 1'b1;
        wb_sel_o = WB_EX_RESULT;
        alu_op_o = ALU_ADD;
        jal_o    = 1'b1;
      end

      JALR_OPCODE: begin
        a_sel_o  = OP_A_CURR_PC;
        b_sel_o  = OP_B_INCR;
        wb_sel_o = WB_EX_RESULT;
        alu_op_o = ALU_ADD;

        case(funct3)
          3'h0: begin
            gpr_we_o = 1'b1;
            jalr_o   = 1'b1;
          end
          default: illegal_instr_o = 1'b1;
        endcase
      end

      LUI_OPCODE: begin
        a_sel_o         = OP_A_ZERO;
        b_sel_o         = OP_B_IMM_U;
        gpr_we_o        = 1'b1;
        wb_sel_o        = WB_EX_RESULT;
        alu_op_o        = ALU_ADD;
        illegal_instr_o = 1'b0;
      end

      AUIPC_OPCODE: begin
        a_sel_o         = OP_A_CURR_PC;
        b_sel_o         = OP_B_IMM_U;
        gpr_we_o        = 1'b1;
        wb_sel_o        = WB_EX_RESULT;
        alu_op_o        = ALU_ADD;
        illegal_instr_o = 1'b0;
      end

      MISC_MEM_OPCODE: begin
        case(funct3)
          3'h0: begin
            a_sel_o  = OP_A_RS1;
            b_sel_o  = OP_B_RS2;
            gpr_we_o = 1'b0;
            wb_sel_o = WB_EX_RESULT;
            alu_op_o = ALU_ADD;
          end
          default: illegal_instr_o = 1'b1;
        endcase
      end

      SYSTEM_OPCODE: begin
        case(funct3)
          3'h0: begin
            case(syst) // !!!!
              25'h0000: illegal_instr_o = 1'b1;
              25'h2000: illegal_instr_o = 1'b1;
              25'h604000: begin
                gpr_we_o = 1'b0;
                mret_o   = 1'b1;
              end
              default: illegal_instr_o = 1'b1;
            endcase
          end
          3'h1: begin
            gpr_we_o = 1'b1;
            csr_we_o = 1'b1;
            csr_op_o = CSR_RW;
            wb_sel_o = WB_CSR_DATA;
          end
          3'h2: begin
            gpr_we_o = 1'b1;
            csr_we_o = 1'b1;
            csr_op_o = CSR_RS;
            wb_sel_o = WB_CSR_DATA;
          end
          3'h3: begin
            gpr_we_o = 1'b1;
            csr_we_o = 1'b1;
            csr_op_o = CSR_RC;
            wb_sel_o = WB_CSR_DATA;
          end
          3'h5: begin
            gpr_we_o = 1'b1;
            csr_we_o = 1'b1;
            csr_op_o = CSR_RWI;
            wb_sel_o = WB_CSR_DATA;
          end
          3'h6: begin
            gpr_we_o = 1'b1;
            csr_we_o = 1'b1;
            csr_op_o = CSR_RSI;
            wb_sel_o = WB_CSR_DATA;
          end
          3'h7: begin
            gpr_we_o = 1'b1;
            csr_we_o = 1'b1;
            csr_op_o = CSR_RCI;
            wb_sel_o = WB_CSR_DATA;
          end
          default: illegal_instr_o = 1'b1;
        endcase
      end
      default: illegal_instr_o = 1'b1;
    endcase
      end

endmodule
