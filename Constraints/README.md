# Constraints

These XDC files cover different build stages. They are alternatives, not files to enable together.

| File | Intended top | Purpose | Use for the current board build? |
|---|---|---|---|
| `novaNexysA7_v3.xdc` | `novaNexysA7` or `novaSumDemoTop` | Current Nexys A7 clock, controls, 16 LEDs, all eight seven-segment digits, and configuration voltage | Yes |
| `novaNexysA7_v2.xdc` | `novaNexysA7` | Earlier LED-only board constraint, before the seven-segment interface was added | No; retained for history |
| `cpuCore_synthesis_v1.xdc` | `cpuCore` | 100 MHz timing constraint for core-only synthesis; intentionally has no physical pins | Only for a core-only synthesis review |
| `Nexys-A7-100T-Master.xdc` | Any matching board top | Digilent reference pin map with entries commented out | Reference only |

## Current setup

For the hardware-verified summation demo:

1. Select part `xc7a100tcsg324-1`.
2. Set `novaSumDemoTop` as the synthesis top.
3. Enable only `novaNexysA7_v3.xdc` in the active constraint set.
4. Run synthesis, implementation, timing analysis, and DRC before generating the bitstream.

The current XDC constrains the 100 MHz oscillator, `SW[2:0]`, `BTNC`, `CPU_RESETN`, `LED[15:0]`, the seven cathodes `CA`-`CG`, decimal point `DP`, and anodes `AN[7:0]`. It also supplies the Nexys A7 configuration-bank voltage properties.

## Why the versions must not be combined

Both board XDC files assign the same package pins. Enabling `v2` and `v3` together creates duplicate constraints, while the core-only XDC targets a port named `clk` that does not exist on the board top. The master XDC remains commented and is useful only when adding a new peripheral.

When extending the board, copy only the required lines from the master file, rename each `get_ports` target to match the top-level Verilog port exactly, and keep the final pin assignment in the single active board XDC.
