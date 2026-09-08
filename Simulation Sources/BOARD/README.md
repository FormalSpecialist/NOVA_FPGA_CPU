# Board and Display Testbenches

| Testbench | Status | Purpose | Expected result |
|---|---|---|---|
| `sevenSegmentDisplay_tb.v` | Current | Tests every hex glyph plus active-low digit and decimal-point multiplexing | 40 checks |
| `sumProgram_tb.v` | Current | Runs `sum_1_to_10.mem` directly on `cpuCore` | 14 checks in 162 CPU cycles |
| `sumBoard_tb.v` | Current | Runs the summation program through `novaSumDemoTop` and verifies `0B.F000.37` | 6 checks |
| `novaNexysA7_tb.v` | Legacy | Tests manual/automatic stepping and LED views for the original `5 + 3` ROM | 20 checks with the legacy ROM |
| `novaNexysA7_display_tb.v` | Legacy | Tests final display `04.F000.08` for the original `5 + 3` ROM | 30 checks with the legacy ROM |

The current full-system simulation top is `sumBoard_tb`. It overrides counter widths and sets `USE_XILINX_CLOCK_BUFFER = 0` so a 162-cycle program finishes quickly in behavioral simulation without requiring the hardware-only `BUFGCE` primitive.

Expected current end-to-end message:

```text
PASS: all 6 NOVA summation board tests completed successfully.
```

`sumProgram_tb.v` is stored here because it validates the program used by the board demo, even though its device under test is `cpuCore` rather than the physical board wrapper.
