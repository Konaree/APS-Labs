# APS-Labs

# RISC-V RV32I Processor

[Verilog]
[RISC-V]
[FPGA]

A 32-bit in-order RISC-V processor implementing the RV32I base integer instruction set. Designed for FPGA implementation (Nexys A7-100T) with separate instruction and data memories.

| Folder name | Description |
| ----------- | ----------- |
| [src](src/) | RTL source files |
| [tb](tb/) | Testbench files |


## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/konaree/APS-Labs
```

### 2. Prepare Machine Code

Place your program in `program.mem` (hex format, one 32-bit instruction per line):

```
75C00093    # addi x1, x0, 0x75C
8A700113    # addi x2, x0, 0x8A7
002081B3    # add  x3, x1, x2
...
```

### 3. FPGA Synthesis (Nexys A7-100T)

1. Open **Xilinx Vivado** (2019.2 or newer)
2. Tools -> Run Tcl Script
3. Select RISC_V_processor.tcl
4. Generate bitstream and program FPGA
