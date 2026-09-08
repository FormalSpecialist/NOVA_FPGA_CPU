`timescale 1ns / 1ps
`include "novaDefinitions.vh"

module sumProgram_tb;

    reg clk;
    reg reset;

    wire        halted;
    wire        zeroFlag;
    wire        carryFlag;
    wire        borrowFlag;
    wire [7:0]  debugProgramAddress;
    wire [15:0] debugInstruction;
    wire [2:0]  debugState;
    wire [7:0]  debugExecutionResult;
    wire        debugRegisterWriteEnable;
    wire [2:0]  debugRegisterWriteAddress;
    wire [7:0]  debugRegisterWriteData;

    integer cycles;
    integer testsRun;
    integer errors;

    cpuCore uut (
        .clk(clk),
        .reset(reset),
        .halted(halted),
        .zeroFlag(zeroFlag),
        .carryFlag(carryFlag),
        .borrowFlag(borrowFlag),
        .debugProgramAddress(debugProgramAddress),
        .debugInstruction(debugInstruction),
        .debugState(debugState),
        .debugExecutionResult(debugExecutionResult),
        .debugRegisterWriteEnable(debugRegisterWriteEnable),
        .debugRegisterWriteAddress(debugRegisterWriteAddress),
        .debugRegisterWriteData(debugRegisterWriteData)
    );

    always #5 clk = ~clk;

    task check;
        input condition;
        input [8*96-1:0] message;
        begin
            testsRun = testsRun + 1;
            if (condition !== 1'b1) begin
                errors = errors + 1;
                $display("FAIL: %0s", message);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        cycles = 0;
        testsRun = 0;
        errors = 0;

        @(posedge clk);
        #1;
        reset = 1'b0;

        while ((halted !== 1'b1) && (cycles < 220)) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end

        check(halted === 1'b1,
              "summation program did not reach HALT");
        check(cycles == 162,
              "summation program did not execute in 162 CPU cycles");
        check(uut.registerFile.registers[0] === 8'h00,
              "R0 zero constant was unexpectedly modified");
        check(uut.registerFile.registers[1] === 8'h00,
              "loop counter R1 did not finish at zero");
        check(uut.registerFile.registers[2] === 8'h37,
              "accumulator R2 does not contain decimal 55");
        check(uut.registerFile.registers[3] === 8'h01,
              "constant register R3 does not contain one");
        check(uut.registerFile.registers[4] === 8'h37,
              "LD did not read decimal 55 into R4");
        check(uut.registerFile.registers[5] === 8'h37,
              "final ADD did not write decimal 55 into R5");
        check(uut.dataRam.memory[8'h10] === 8'h37,
              "ST did not write decimal 55 to RAM address 10");
        check(debugExecutionResult === 8'h37,
              "final execution-result register does not contain 37");
        check(debugProgramAddress === 8'h0B,
              "final PC is not 0B after fetching HALT");
        check(debugInstruction === 16'hF000,
              "instruction register does not contain HALT");
        check(debugState === `NOVA_STATE_HALT,
              "controller is not in the HALT state");
        check({zeroFlag, carryFlag, borrowFlag} === 3'b000,
              "final ADD produced unexpected status flags");

        if (errors == 0)
            $display("PASS: all %0d NOVA summation-program tests passed in %0d cycles.",
                     testsRun, cycles);
        else
            $display("FAIL: %0d of %0d NOVA summation-program tests failed.",
                     errors, testsRun);

        $finish;
    end

endmodule
