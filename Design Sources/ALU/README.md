# ALU (Arithmatic Logic Unit)

The purpose of the ALU is to perform calculations for the CPU

The ALU will recieve and disperse the following:
- Inputs A, B, and OpCode
- Outputs Zero Flag, Result


## Main Calculations to Perform:
- ADD    -->     5 + 3 = 8
- SUB    -->     5 - 2 = 3
- AND    -->     1100 & 1000 = 1000     Compare individual bits to determine whether they're both 1's, otherwise result is a 0.
- OR     -->     1100 | 1010 = 1110     Compare individual bits, if at least one of them is a 1 the resut is 1, otherwise the result is 0.

## Additional Calculations:
- MULT
- DIV
- XOR
- Shifts 
- Comparisons

## Operational Codes (OpCodes)
- ADD   -->     000
- SUB   -->     001
- AND   -->     010
- OR    -->     011
