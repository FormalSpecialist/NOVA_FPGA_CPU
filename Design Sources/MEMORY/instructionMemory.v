`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: Instruction Memory
// Module Name: instructionMemory
// Project Name: NOVA
// Description:
//   A 256-word by 16-bit read-only program memory. The program counter selects
//   one instruction, and the instruction appears combinationally at the output.
//
//   The initial program computes 5 + 3 and stores the result in register R3:
//     0x00: LDI  R1, 5
//     0x01: LDI  R2, 3
//     0x02: ADD  R3, R1, R2
//     0x03: HALT
//////////////////////////////////////////////////////////////////////////////////

module instructionMemory (
    input      [7:0]  programAddress,
    output     [15:0] instruction
);

    reg [15:0] memory [0:255];
    integer i;

    initial begin
        // Unused locations contain NOP (0x0000).
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 16'h0000;

        // Instruction format for LDI:
        // [15:12] opcode, [11:9] destination, [8] reserved, [7:0] immediate
        memory[8'h00] = 16'h1205; // LDI R1, 5 | 0001 001 0 00000101
        memory[8'h01] = 16'h1403; // LDI R2, 3

        // Register-operation format:
        // [15:12] opcode, [11:9] destination, [8:6] source A,
        // [5:3] source B, [2:0] reserved
        memory[8'h02] = 16'h3650; // ADD R3, R1, R2 | 0011 011 001 010 000
        memory[8'h03] = 16'hF000; // HALT
    end

    assign instruction = memory[programAddress];

endmodule
