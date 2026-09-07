`timescale 1ns / 1ps
`include "novaDefinitions.vh"

module alu_tb;

    reg  [7:0] operandA;
    reg  [7:0] operandB;
    reg  [2:0] aluOperation;

    wire [7:0] result;
    wire       zeroFlag;
    wire       carryFlag;
    wire       borrowFlag;

    integer testsRun;
    integer errors;

    alu uut (
        .operandA(operandA),
        .operandB(operandB),
        .aluOperation(aluOperation),
        .result(result),
        .zeroFlag(zeroFlag),
        .carryFlag(carryFlag),
        .borrowFlag(borrowFlag)
    );

    task checkAlu;
        input [2:0] operation;
        input [7:0] testA;
        input [7:0] testB;
        input [7:0] expectedResult;
        input       expectedZero;
        input       expectedCarry;
        input       expectedBorrow;
        begin
            aluOperation = operation;
            operandA = testA;
            operandB = testB;
            #1;
            testsRun = testsRun + 1;

            if ((result !== expectedResult) ||
                (zeroFlag !== expectedZero) ||
                (carryFlag !== expectedCarry) ||
                (borrowFlag !== expectedBorrow)) begin
                errors = errors + 1;
                $display("FAIL test %0d: op=%b A=%h B=%h | result=%h Z=%b C=%b B=%b | expected=%h %b %b %b",
                         testsRun, operation, testA, testB,
                         result, zeroFlag, carryFlag, borrowFlag,
                         expectedResult, expectedZero,
                         expectedCarry, expectedBorrow);
            end
        end
    endtask

    initial begin
        operandA = 8'h00;
        operandB = 8'h00;
        aluOperation = `NOVA_ALU_ADD;
        testsRun = 0;
        errors = 0;

        checkAlu(`NOVA_ALU_ADD, 8'd2,  8'd1,  8'd3,  1'b0, 1'b0, 1'b0);
        checkAlu(`NOVA_ALU_SUB, 8'd5,  8'd3,  8'd2,  1'b0, 1'b0, 1'b0);
        checkAlu(`NOVA_ALU_AND, 8'h2E, 8'hAD, 8'h2C, 1'b0, 1'b0, 1'b0);
        checkAlu(`NOVA_ALU_OR,  8'h42, 8'h1B, 8'h5B, 1'b0, 1'b0, 1'b0);

        checkAlu(`NOVA_ALU_SUB, 8'd2,  8'd2,  8'h00, 1'b1, 1'b0, 1'b0);
        checkAlu(`NOVA_ALU_ADD, 8'hFF, 8'h01, 8'h00, 1'b1, 1'b1, 1'b0);
        checkAlu(`NOVA_ALU_ADD, 8'hFF, 8'hFF, 8'hFE, 1'b0, 1'b1, 1'b0);
        checkAlu(`NOVA_ALU_SUB, 8'h00, 8'h01, 8'hFF, 1'b0, 1'b0, 1'b1);
        checkAlu(`NOVA_ALU_SUB, 8'h80, 8'h7F, 8'h01, 1'b0, 1'b0, 1'b0);

        checkAlu(`NOVA_ALU_XOR,    8'hAA, 8'h0F, 8'hA5, 1'b0, 1'b0, 1'b0);
        checkAlu(`NOVA_ALU_SHL,    8'h12, 8'h00, 8'h24, 1'b0, 1'b0, 1'b0);
        checkAlu(`NOVA_ALU_SHL,    8'h80, 8'h00, 8'h00, 1'b1, 1'b1, 1'b0);
        checkAlu(`NOVA_ALU_SHR,    8'h24, 8'h00, 8'h12, 1'b0, 1'b0, 1'b0);
        checkAlu(`NOVA_ALU_SHR,    8'h01, 8'h00, 8'h00, 1'b1, 1'b1, 1'b0);
        checkAlu(`NOVA_ALU_PASS_B, 8'h00, 8'h5A, 8'h5A, 1'b0, 1'b0, 1'b0);

        if (errors == 0)
            $display("PASS: all %0d ALU tests completed successfully.", testsRun);
        else
            $display("FAIL: %0d of %0d ALU tests failed.", errors, testsRun);

        $finish;
    end

endmodule
