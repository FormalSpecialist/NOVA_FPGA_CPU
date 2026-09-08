# Controller and CPU Testbenches

| Testbench | Status | Purpose | Expected result |
|---|---|---|---|
| `cu_tb.v` | Current | Verifies controller state sequences and control signals for immediate, ALU, branch, and halt paths | 18 checks |
| `cpuIsa_tb.v` | Current | Installs its own ROM program and exercises all 16 opcodes, registers, memory, flags, and control flow | 18 checks in 102 cycles |
| `cpuCore_tb.v` | Legacy | Verifies the original `5 + 3` integration program | 10 checks in 14 cycles with the legacy ROM |

`cpuIsa_tb` is the preferred processor-wide regression because it overwrites the simulated ROM after time-zero initialization; therefore it does not depend on `sum_1_to_10.mem`.

Expected current messages:

```text
PASS: all 18 control-unit tests completed successfully.
PASS: all 18 NOVA ISA tests passed in 102 cycles.
```

`cpuCore_tb` remains useful as documentation of the first integration milestone, but it will fail against the current summation ROM unless the original four-word image is restored or the testbench is made self-contained.
