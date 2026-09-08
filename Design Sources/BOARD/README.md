# Board Interface

These modules connect the CPU to the Nexys A7-100T without changing the processor datapath.

| File | Role |
|---|---|
| `buttonConditioner.v` | Synchronizes and debounces `BTNC`, then emits one clock-wide pulse per press |
| `sevenSegmentDisplay.v` | Multiplexes eight hexadecimal digits onto the active-low common-anode display |
| `novaNexysA7.v` | Synchronizes reset/switches, creates manual or automatic CPU steps, instantiates `cpuCore`, and drives LEDs/display |

The current synthesis top, `novaSumDemoTop`, is stored in `../MEMORY/novaSumDemoTop.v`. It wraps `novaNexysA7` with a faster default automatic rate of 10 CPU cycles per second; `novaNexysA7` itself defaults to 2 cycles per second.

## Controls

| Input | Behavior |
|---|---|
| `CPU_RESETN` | Active-low reset with asynchronous assertion and synchronized release |
| `BTNC` | Single CPU step in manual mode |
| `SW[0]` | `0` manual, `1` automatic |
| `SW[2:1]` | Selects the LED debug view |

All switches may begin low. The CPU then waits in manual mode until `BTNC` is pressed. Set `SW[0]` high after reset to run automatically.

## Displays

The eight hexadecimal digits always show `PP.IIII.RR`:

- `PP`: next program-counter address
- `IIII`: current instruction register
- `RR`: most recently saved ALU execution result

At the end of the summation demo, the display is `0B.F000.37`. The program counter is `0B` because `HALT` was fetched from address `0A` while the fetch cycle incremented the PC.

`SW[2:1]` does not change the seven-segment display; it changes only `LED[15:0]`. See the root README for the four LED layouts.

## Simulation note

`USE_XILINX_CLOCK_BUFFER` must remain `1` in hardware so the CPU clock is driven through `BUFGCE`. Board testbenches override it to `0` because the behavioral clock model does not provide the Xilinx primitive.
