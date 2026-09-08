# Control Unit and CPU Core

| File | Role |
|---|---|
| `novaDefinitions.vh` | Shared instruction, ALU, writeback, and FSM encodings |
| `cu.v` | Five-state multicycle control unit |
| `cpuCore.v` | Connects the controller, fetch path, registers, ALU, flags, and memories |

## Controller states

| Encoding | State | Main action |
|---:|---|---|
| `0` | `FETCH` | Capture `ROM[PC]` in the instruction register and increment PC |
| `1` | `DECODE` | Select the instruction path |
| `2` | `EXECUTE` | Perform ALU, store, or branch/jump work |
| `3` | `WRITEBACK` | Write ALU, immediate, memory, or register data to the destination register |
| `4` | `HALT` | Assert `halted` and retain the terminal state |

The core includes an `executionResult` register. It captures the ALU result during `EXECUTE` and keeps that value stable for `WRITEBACK` and the board display.

## Instruction set

The upper nibble, `instruction[15:12]`, is the opcode.

| Opcode | Mnemonic | Meaning |
|---:|---|---|
| `0` | `NOP` | No operation |
| `1` | `LDI` | Load 8-bit immediate |
| `2` | `MOV` | Copy register |
| `3` | `ADD` | Add |
| `4` | `SUB` | Subtract |
| `5` | `AND` | Bitwise AND |
| `6` | `OR` | Bitwise OR |
| `7` | `XOR` | Bitwise XOR |
| `8` | `LD` | Load from direct data-memory address |
| `9` | `ST` | Store to direct data-memory address |
| `A` | `JMP` | Unconditional jump |
| `B` | `JZ` | Jump when zero is set |
| `C` | `JC` | Jump when carry is set |
| `D` | `SHL` | Shift left by one |
| `E` | `SHR` | Shift right by one |
| `F` | `HALT` | Enter the terminal state |

## Instruction formats

| Group | 16-bit layout |
|---|---|
| Three-register ALU | `[15:12] opcode · [11:9] destination · [8:6] source A · [5:3] source B · [2:0] 000` |
| `MOV`, `SHL`, `SHR` | `[15:12] opcode · [11:9] destination · [8:6] source A · [5:0] 000000` |
| `LDI`, `LD`, `ST` | `[15:12] opcode · [11:9] register · [8] 0 · [7:0] immediate/address` |
| `JMP`, `JZ`, `JC` | `[15:12] opcode · [11:8] 0000 · [7:0] target address` |

For exact encoding, use `novaDefinitions.vh` and the assembler rather than duplicating numeric constants in RTL or tests.
