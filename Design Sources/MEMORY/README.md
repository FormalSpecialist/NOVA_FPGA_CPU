# Storage and Program Files

This folder holds the CPU state blocks, the file-initialized ROM, and the current summation demonstration.

| File | Role |
|---|---|
| `programCounter.v` | 8-bit instruction address with reset, load, increment, and hold behavior |
| `instructionMemory.v` | 256 × 16-bit combinational-read ROM initialized with `$readmemh` |
| `instructionRegister.v` | Captures the fetched 16-bit instruction |
| `registers.v` | Eight 8-bit registers with two combinational read ports and one clocked write port |
| `dataMemory.v` | 256 × 8-bit RAM with combinational read and clocked write |
| `statusRegister.v` | Clocked zero, carry, and borrow flags |
| `novaSumDemoTop.v` | Current board synthesis top; wraps `novaNexysA7` at 10 CPU cycles per second |
| `sum_1_to_10.asm` | Human-readable demonstration source |
| `sum_1_to_10.lst` | Address, machine word, source, and resolved-label listing |
| `sum_1_to_10.mem` | 256-word hexadecimal ROM image used by simulation and synthesis |

The register file and status register clear on CPU reset. Data memory is initialized to zero at FPGA configuration/time zero, but CPU reset deliberately does not erase all 256 bytes.

## Current program

| Address | Word | Assembly | Effect |
|---:|---:|---|---|
| `00` | `120A` | `LDI R1, 10` | Initialize loop counter |
| `01` | `1400` | `LDI R2, 0` | Clear accumulator |
| `02` | `1601` | `LDI R3, 1` | Set decrement constant |
| `03` | `3488` | `ADD R2, R2, R1` | Add counter to sum |
| `04` | `4258` | `SUB R1, R1, R3` | Decrement counter |
| `05` | `B007` | `JZ 0x07` | Exit loop when counter is zero |
| `06` | `A003` | `JMP 0x03` | Repeat loop |
| `07` | `9410` | `ST R2, 0x10` | Store `0x37` in RAM |
| `08` | `8810` | `LD R4, 0x10` | Load the stored result |
| `09` | `3B00` | `ADD R5, R4, R0` | Copy result through the ALU for display |
| `0A` | `F000` | `HALT` | Stop architectural state changes |

After 162 CPU cycles, `R2`, `R4`, `R5`, `RAM[0x10]`, and the saved execution result contain `0x37` (decimal 55). The PC contains `0x0B` because fetching `HALT` increments it once.

## ROM file handling

`instructionMemory.v` defaults to `PROGRAM_FILE = "sum_1_to_10.mem"`. Add the `.mem` file to Vivado as a memory initialization source used in both synthesis and simulation. If XSim reports that it cannot open the file, confirm that Vivado copied it into the simulation run directory and that the filename matches exactly.

Rebuild the `.mem` and `.lst` files with the commands in `../PYTHON/README.md`.
