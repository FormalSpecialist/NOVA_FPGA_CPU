`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: NOVA File-Initialized Instruction Memory
// Module Name: instructionMemory
// Project Name: NOVA
// Description:
//   A 256-word by 16-bit read-only program memory. The assembler produces the
//   memory initialization file loaded here for simulation and FPGA synthesis.
//////////////////////////////////////////////////////////////////////////////////

module instructionMemory #(
    parameter PROGRAM_FILE = "sum_1_to_10.mem"
) (
    input      [7:0]  programAddress,
    output     [15:0] instruction
);

    reg [15:0] memory [0:255];

    initial begin
        $readmemh(PROGRAM_FILE, memory);
    end

    assign instruction = memory[programAddress];

endmodule
