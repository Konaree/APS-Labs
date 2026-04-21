## Module Description

| Module | Description |
|--------|-------------|
| [processor_system](src/processor_system.sv) | Top-level module integrating all components |
| [processor_core](src/processor_core.sv) | Main processor core with PC, decoder, and control logic |
| [decoder](src/decoder.sv) | Instruction decoder generating all control signals |
| [alu](src/alu.sv) | Arithmetic Logic Unit with 16 operations |
| [register_file](src/register_file.sv) | 32x32-bit register file (x0 hardwired to zero) |
| [lsu](src/lsu.sv) | Load-Store Unit handling memory access alignment |
| [instr_mem](src/instr_mem.sv) | Instruction memory (ROM, initialized from `program.mem`) |
| [data_mem](src/data_mem.sv) | Data memory (RAM) with byte-enable write support |

## Supported Instructions

### Arithmetic & Logical
| Instruction | Operation |
|-------------|-----------|
| ADD, SUB | Addition, Subtraction |
| XOR, OR, AND | Bitwise operations |
| SLL, SRL, SRA | Shift left/right logical/arithmetic |

### Set-if-Less-Than
| Instruction | Operation |
|-------------|-----------|
| SLT, SLTU | Set on less than (signed/unsigned) |

### Branches
| Instruction | Condition |
|-------------|-----------|
| BEQ, BNE | Equal / Not equal |
| BLT, BGE | Less than / Greater or equal (signed) |
| BLTU, BGEU | Less than / Greater or equal (unsigned) |

### Jumps
| Instruction | Description |
|-------------|-------------|
| JAL | Jump and link |
| JALR | Jump and link register |

### Load/Store
| Instruction | Size | Extension |
|-------------|------|-----------|
| LB, LBU | Byte | Signed / Zero |
| LH, LHU | Half-word | Signed / Zero |
| LW | Word | Full word |
| SB, SH, SW | Store byte/half/word | - |

### Upper Immediate
| Instruction | Operation |
|-------------|-----------|
| LUI | Load upper immediate |
| AUIPC | Add upper immediate to PC |

### program.mem format
One 32-bit hex word per line
75C00093    # addi x1, x0, 0x75C
8A700113    # addi x2, x0, 0x8A7
002081B3    # add  x3, x1, x2
