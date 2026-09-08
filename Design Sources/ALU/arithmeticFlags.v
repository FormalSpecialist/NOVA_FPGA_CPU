`timescale 1ns / 1ps
`include "novaDefinitions.vh"

module arithmeticFlags (
    input      [7:0] operandA,
    input      [7:0] operandB,
    input      [2:0] aluOperation,
    input      [7:0] result,

    output           zeroFlag,
    output reg       carryFlag,
    output reg       borrowFlag
);

    wire [8:0] extendedSum;

    // The ninth bit is the carry out of unsigned eight-bit addition.
    assign extendedSum = {1'b0, operandA} + {1'b0, operandB};
    assign zeroFlag = (result == 8'h00);

    always @(*) begin
        carryFlag = 1'b0;
        borrowFlag = 1'b0;

        case (aluOperation)
            `NOVA_ALU_ADD:
                carryFlag = extendedSum[8];

            `NOVA_ALU_SUB:
                borrowFlag = (operandA < operandB);

            // For shifts, carry stores the bit shifted out of the result.
            `NOVA_ALU_SHL:
                carryFlag = operandA[7];

            `NOVA_ALU_SHR:
                carryFlag = operandA[0];

            default: begin
                carryFlag = 1'b0;
                borrowFlag = 1'b0;
            end
        endcase
    end

endmodule
