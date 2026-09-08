# Simulation Sources

Every Verilog file in this directory is a self-checking behavioral testbench. Add testbenches under Vivado **Simulation Sources**, select one top at a time, and run until `$finish` (`run all` is safest).

## Current regression set

These tests match the current RTL and summation ROM:

| Folder | Testbench | Coverage | Expected checks/result |
|---|---|---|---|
| `ALU` | `alu_tb` | Eight ALU operations and flags | 15 checks |
| `BOARD` | `sevenSegmentDisplay_tb` | Hex glyphs, digit order, anodes, and decimal points | 40 checks |
| `BOARD` | `sumProgram_tb` | Current summation program on `cpuCore` | 14 checks, 162 CPU cycles |
| `BOARD` | `sumBoard_tb` | Current summation program through the board top and display | 6 checks |
| `CU` | `cu_tb` | Controller state and control-signal sequences | 18 checks |
| `CU` | `cpuIsa_tb` | All 16 opcodes, memory, flags, jumps, and branches | 18 checks, 102 CPU cycles |
| `MEMORY` | `programCounter_tb` | Reset, hold, increment, load, priority, and wraparound | 10 checks |
| `MEMORY` | `registers_tb` | Two-port reads, all registers, writes, disable, and reset | 14 checks |
| `MEMORY` | `dataMemory_tb` | Reads, rising-edge writes, write protection, and addresses | 10 checks |
| `MEMORY` | `statusRegister_tb` | Flag capture, hold, and reset | 6 checks |

`cpuIsa_tb` replaces the ROM contents through simulation hierarchy, so it remains independent of the default `.mem` program.

## Legacy `5 + 3` tests

The following testbenches are retained because they document the earlier four-instruction integration milestone:

| Testbench | Original expected program |
|---|---|
| `CU/cpuCore_tb.v` | `LDI R1,5`; `LDI R2,3`; `ADD R3,R1,R2`; `HALT` |
| `BOARD/novaNexysA7_tb.v` | Same program, with manual/automatic stepping and LED views |
| `BOARD/novaNexysA7_display_tb.v` | Same program, ending at `04.F000.08` |
| `MEMORY/instructionFetch_tb.v` | Same four ROM words plus unused-address checks |

They do not match the current default `sum_1_to_10.mem` and are not part of the current regression run unless the original ROM image is restored or the testbench is changed to install its own program.

## Recommended run order

1. Unit tests: `alu_tb`, the four storage testbenches, and `sevenSegmentDisplay_tb`
2. Controller: `cu_tb`
3. Processor ISA: `cpuIsa_tb`
4. Current program: `sumProgram_tb`
5. Full board integration: `sumBoard_tb`

The supplied Vivado project currently selects `sumBoard_tb`. Its saved `2000 ns` runtime is too short for the divided board-level CPU clock, so use `run all` or set at least `10000 ns`. The completed run should report:

```text
PASS: all 6 NOVA summation board tests completed successfully.
```
