`timescale 1ns / 1ps
`include "novaDefinitions.vh"

module alu (
    input      [7:0] operandA,
    input      [7:0] operandB,
    input      [2:0] aluOperation,

    output reg [7:0] result,
    output           zeroFlag,
    output           carryFlag,
    output           borrowFlag
);

    // The ALU is combinational: it calculates values but stores no state.
    always @(*) begin
        case (aluOperation)
            `NOVA_ALU_ADD:    result = operandA + operandB;
            `NOVA_ALU_SUB:    result = operandA - operandB;
            `NOVA_ALU_AND:    result = operandA & operandB;
            `NOVA_ALU_OR:     result = operandA | operandB;
            `NOVA_ALU_XOR:    result = operandA ^ operandB;
            `NOVA_ALU_SHL:    result = operandA << 1;
            `NOVA_ALU_SHR:    result = operandA >> 1;
            `NOVA_ALU_PASS_B: result = operandB;
            default:          result = 8'h00;
        endcase
    end

    arithmeticFlags flags (
        .operandA(operandA),
        .operandB(operandB),
        .aluOperation(aluOperation),
        .result(result),
        .zeroFlag(zeroFlag),
        .carryFlag(carryFlag),
        .borrowFlag(borrowFlag)
    );

endmodule
