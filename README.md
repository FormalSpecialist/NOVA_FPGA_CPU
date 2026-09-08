# NOVA FPGA CPU

NOVA is an educational 8-bit multicycle CPU implemented in Verilog for the Digilent Nexys A7-100T (`xc7a100tcsg324-1`). The current design has been simulated, synthesized, implemented, programmed, and verified on hardware.

The included demonstration program computes `10 + 9 + ... + 1 = 55`, stores the result in data memory, loads it back, and halts. The final seven-segment display reads:

```text
0B.F000.37
```

- `0B`: program counter after fetching the instruction at address `0A`
- `F000`: `HALT`
- `37`: hexadecimal `55`, the final ALU result

## Architecture

| Feature | NOVA implementation |
|---|---|
| Data width | 8 bits |
| Instruction width | 16 bits |
| Registers | Eight 8-bit general-purpose registers (`R0`-`R7`) |
| Program memory | 256 words × 16 bits |
| Data memory | 256 bytes × 8 bits |
| Status flags | Zero, carry, and borrow |
| Control | `FETCH`, `DECODE`, `EXECUTE`, `WRITEBACK`, and `HALT` states |
| ISA | 16 instructions, from `NOP` (`0x0`) through `HALT` (`0xF`) |
| Board clock | 100 MHz, reduced to manual or visible-rate CPU steps |

Most instructions use two to four CPU cycles:

| Instruction group | State sequence | Cycles |
|---|---|---:|
| `NOP`, `HALT` | Fetch → Decode | 2 |
| `ST`, `JMP`, `JZ`, `JC` | Fetch → Decode → Execute | 3 |
| `LDI`, `MOV`, `LD`, ALU instructions | Fetch → Decode → Execute → Writeback | 4 |

## Repository layout

| Path | Purpose |
|---|---|
| `Constraints/` | Core-only, board-level, historical, and reference XDC files |
| `Design Sources/ALU/` | Combinational ALU and flag-generation logic |
| `Design Sources/BOARD/` | Nexys A7 controls, clock enable, LEDs, and seven-segment driver |
| `Design Sources/CU/` | Shared definitions, multicycle controller, and integrated CPU core |
| `Design Sources/MEMORY/` | Registers, PC, ROM, RAM, status register, demo top, and program files |
| `Design Sources/PYTHON/` | Two-pass assembler and its unit tests |
| `Simulation Sources/` | Self-checking unit, integration, ISA, display, and board testbenches |
| `NOVA/NOVA.xpr` | Vivado project configured for the current summation demonstration |

Each curated folder contains its own README with file roles, dependencies, and test expectations.

## Current Vivado configuration

Open `NOVA/NOVA.xpr`. The supplied project is configured with:

- Part: `xc7a100tcsg324-1`
- Synthesis top: `novaSumDemoTop`
- Active constraints: `Constraints/novaNexysA7_v3.xdc`
- Simulation top: `sumBoard_tb`
- Saved simulation runtime: `2000 ns` (use `run all` for `sumBoard_tb`)
- ROM image: `Design Sources/MEMORY/sum_1_to_10.mem`

Do not enable `novaNexysA7_v2.xdc` or `cpuCore_synthesis_v1.xdc` at the same time as the current board constraint. See `Constraints/README.md` for the purpose of every XDC file.

## Board operation

The slide switches may all start low. That selects manual mode and the instruction LED view.

| Control | Function |
|---|---|
| `CPU_RESETN` | Active-low CPU reset |
| `BTNC` | One debounced CPU cycle per press when `SW[0] = 0` |
| `SW[0]` | `0`: manual single-step; `1`: automatic run |
| `SW[2:1]` | Selects one of four 16-bit LED debug views |

The seven-segment display always uses the format `PP.IIII.RR`, where `PP` is the program counter, `IIII` is the instruction register, and `RR` is the saved ALU execution result.

| `SW[2:1]` | LED view, from `LED[15]` to `LED[0]` |
|---|---|
| `00` | Current 16-bit instruction |
| `01` | 8-bit execution result, then 8-bit program counter |
| `10` | Halt/flags/state status, then 8-bit program counter |
| `11` | Writeback data, destination, write-enable, and flags |

To run the summation demo automatically, release reset and set `SW[0]` high. With the `novaSumDemoTop` defaults, the CPU advances at 10 cycles per second and reaches `HALT` after 162 CPU cycles, or about 16.2 seconds.

## Rebuilding the program image

From the repository root:

```text
python "Design Sources/PYTHON/test_novaAssembler.py"
python "Design Sources/PYTHON/novaAssembler.py" "Design Sources/MEMORY/sum_1_to_10.asm" -o "Design Sources/MEMORY/sum_1_to_10.mem" --listing "Design Sources/MEMORY/sum_1_to_10.lst"
```

The generated `.mem` file contains 256 four-digit hexadecimal words and is loaded by `instructionMemory.v` with `$readmemh`.

## Verification

The current end-to-end test is `sumBoard_tb`. The board-level automatic-clock divider makes this test longer than the saved `2000 ns` run setting, so enter `run all` in the XSim Tcl Console or set the runtime to at least `10000 ns`. Its expected console message is:

```text
PASS: all 6 NOVA summation board tests completed successfully.
```

The assembler has six Python unit tests, and the Verilog folders include unit and regression testbenches for the ALU, storage blocks, controller, ISA, display, and board integration. Some older testbenches intentionally describe the original `5 + 3` ROM image and are labeled as legacy in `Simulation Sources/README.md`.

## Roadmap

- Completed: CPU architecture, ISA, RTL modules, assembler, simulation regression, synthesis, implementation, board I/O, and hardware verification
- Current demonstration: file-initialized summation program with LED and seven-segment debugging
- Possible extensions: additional sensors and a wireless phone-facing interface
