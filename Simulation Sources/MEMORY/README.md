# Storage and Fetch Testbenches

| Testbench | Status | Device(s) under test | Expected result |
|---|---|---|---|
| `programCounter_tb.v` | Current | `programCounter` | 10 checks |
| `registers_tb.v` | Current | `registers` | 14 checks |
| `dataMemory_tb.v` | Current | `dataMemory` | 10 checks |
| `statusRegister_tb.v` | Current | `statusRegister` | 6 checks |
| `instructionFetch_tb.v` | Legacy ROM expectation | `programCounter`, `instructionMemory`, and `instructionRegister` | 11 checks with the original `5 + 3` image |

The four current unit tests are independent of the demonstration program and can be run directly.

`instructionFetch_tb.v` expects these historical ROM words:

| Address | Word | Meaning |
|---:|---:|---|
| `00` | `1205` | `LDI R1, 5` |
| `01` | `1403` | `LDI R2, 3` |
| `02` | `3650` | `ADD R3, R1, R2` |
| `03` | `F000` | `HALT` |

Because `instructionMemory.v` now defaults to `sum_1_to_10.mem`, this fetch test is retained as a historical integration test and is not part of the current regression set.
