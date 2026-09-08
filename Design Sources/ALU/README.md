# ALU

The ALU is combinational: it calculates a result and candidate flags but stores no architectural state.

| File | Role |
|---|---|
| `alu.v` | Selects one of eight operations and produces the 8-bit result |
| `arithmeticFlags.v` | Derives zero, unsigned carry, subtraction borrow, and shift carry-out |

Both files include `novaDefinitions.vh` from `../CU/`. The matching self-checking testbench is `../../Simulation Sources/ALU/alu_tb.v`.

| Selection | Operation | Flag behavior |
|---:|---|---|
| `000` | `A + B` | Carry is the ninth sum bit |
| `001` | `A - B` | Borrow is set when `A < B` |
| `010` | `A AND B` | Carry and borrow clear |
| `011` | `A OR B` | Carry and borrow clear |
| `100` | `A XOR B` | Carry and borrow clear |
| `101` | `A << 1` | Carry receives original `A[7]` |
| `110` | `A >> 1` | Carry receives original `A[0]` |
| `111` | Pass `B` | Carry and borrow clear |

The zero flag is asserted whenever the result is `0x00`. `statusRegister.v` captures these candidate flags during ALU instructions when the control unit asserts `flagWriteEnable`.

Expected `alu_tb` result:

```text
PASS: all 15 ALU tests completed successfully.
```
