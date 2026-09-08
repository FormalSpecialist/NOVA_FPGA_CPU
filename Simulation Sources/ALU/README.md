# ALU Testbench

`alu_tb.v` is a self-checking testbench for `Design Sources/ALU/alu.v` and `arithmeticFlags.v`. It also requires `Design Sources/CU/novaDefinitions.vh`.

Coverage includes addition with and without carry, subtraction with and without borrow, zero detection, `AND`, `OR`, `XOR`, left/right shifts with shifted-out carry, and pass-through of operand B.

Set `alu_tb` as the simulation top and run until `$finish`.

```text
PASS: all 15 ALU tests completed successfully.
```
