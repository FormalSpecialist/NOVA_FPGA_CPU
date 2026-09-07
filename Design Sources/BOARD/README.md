# NOVA Nexys A7-100T Integration

This bundle adds a board-level wrapper around the already verified `cpuCore`.
It does not modify any CPU module.

## New files

- `novaNexysA7.v` — synthesis top for the FPGA
- `buttonConditioner.v` — button synchronizer, debouncer, and one-shot pulse
- `novaNexysA7_tb.v` — self-checking wrapper simulation
- `novaNexysA7.xdc` — physical pins and the 100 MHz timing constraint

## Board controls

| Control | Function |
|---|---|
| `CPU_RESETN` | Hold to reset the processor (active low) |
| `SW[0] = 0` | Manual single-step mode |
| `SW[0] = 1` | Automatic mode at two CPU cycles per second |
| `BTNC` | Advance one controller cycle in manual mode |
| `SW[2:1]` | Select the LED debug view |

One press of `BTNC` advances one **multicycle-controller state**, not one whole
instruction. The demonstration program needs fourteen presses to reach HALT.

## LED views

| `SW[2:1]` | `LED[15:8]` | `LED[7:0]` |
|---|---|---|
| `00` | Instruction bits `[15:8]` | Instruction bits `[7:0]` |
| `01` | Last execution result | Program counter |
| `10` | HALT, flags, controller state | Program counter |
| `11` | Register writeback data | Destination, write-enable, and flags |

After the bundled program halts, view `01` should show `16'h0804`: result `08`
in the upper eight LEDs and final program counter `04` in the lower eight LEDs.
View `00` should show the final HALT instruction, `16'hF000`.

## Vivado behavioral simulation

1. Add `novaNexysA7.v` and `buttonConditioner.v` under **Design Sources**.
2. Add `novaNexysA7_tb.v` under **Simulation Sources**.
3. Keep every previously verified CPU design source in the project.
4. Set `novaNexysA7_tb` as the simulation top.
5. Run behavioral simulation with `run all`.

Expected console message:

```text
PASS: all 20 NOVA Nexys A7 wrapper tests completed successfully.
```

The testbench shortens the clock-divider and debounce parameters and selects the
behavioral clock-buffer branch. Hardware synthesis retains the default `BUFGCE`
global clock buffer.

## Synthesis and implementation

1. Disable or remove the earlier core-only `cpuCore_synthesis_v1.xdc`. Its clock
   port name belongs to `cpuCore`, not the new board top.
2. Add `novaNexysA7.xdc` under **Constraints**.
3. Set `novaNexysA7` as the **Design Sources** top.
4. Reset previous synthesis and implementation runs.
5. Run synthesis, implementation, and **Generate Bitstream**.
6. Confirm that implementation reports nonnegative setup and hold slack before
   programming the board.

After programming, hold and release `CPU_RESETN`. Leave `SW[0]` down and press
`BTNC` to watch individual controller cycles, or raise `SW[0]` to run the CPU
automatically. The automatic demonstration takes approximately seven seconds.
