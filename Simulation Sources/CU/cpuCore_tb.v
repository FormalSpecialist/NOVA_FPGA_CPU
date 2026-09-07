`timescale 1ns / 1ps
`include "novaDefinitions.vh"

module cpuCore_tb;

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

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        cycles = 0;
        testsRun = 0;
        errors = 0;

        // Apply the synchronous reset for one rising edge.
        @(posedge clk);
        #1;
        reset = 1'b0;

        // Run until HALT or fail safely if the CPU never stops.
        while ((halted !== 1'b1) && (cycles < 40)) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end

        testsRun = testsRun + 1;
        if (halted !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL: CPU did not halt within 40 cycles.");
        end

        testsRun = testsRun + 1;
        if (cycles !== 14) begin
            errors = errors + 1;
            $display("FAIL: execution took %0d cycles; expected 14.", cycles);
        end

        testsRun = testsRun + 1;
        if (uut.registerFile.registers[1] !== 8'd5) begin
            errors = errors + 1;
            $display("FAIL: R1=%h; expected 05.", uut.registerFile.registers[1]);
        end

        testsRun = testsRun + 1;
        if (uut.registerFile.registers[2] !== 8'd3) begin
            errors = errors + 1;
            $display("FAIL: R2=%h; expected 03.", uut.registerFile.registers[2]);
        end

        testsRun = testsRun + 1;
        if (uut.registerFile.registers[3] !== 8'd8) begin
            errors = errors + 1;
            $display("FAIL: R3=%h; expected 08.", uut.registerFile.registers[3]);
        end

        testsRun = testsRun + 1;
        if (debugProgramAddress !== 8'h04) begin
            errors = errors + 1;
            $display("FAIL: PC=%h; expected 04 after fetching HALT.",
                     debugProgramAddress);
        end

        testsRun = testsRun + 1;
        if (debugInstruction !== 16'hF000) begin
            errors = errors + 1;
            $display("FAIL: IR=%h; expected F000 (HALT).", debugInstruction);
        end

        testsRun = testsRun + 1;
        if (debugState !== `NOVA_STATE_HALT) begin
            errors = errors + 1;
            $display("FAIL: state=%0d; expected HALT state.", debugState);
        end

        testsRun = testsRun + 1;
        if ({zeroFlag, carryFlag, borrowFlag} !== 3'b000) begin
            errors = errors + 1;
            $display("FAIL: final flags ZCB=%b%b%b; expected 000.",
                     zeroFlag, carryFlag, borrowFlag);
        end

        testsRun = testsRun + 1;
        if (debugExecutionResult !== 8'd8) begin
            errors = errors + 1;
            $display("FAIL: execution result=%h; expected 08.",
                     debugExecutionResult);
        end

        if (errors == 0)
            $display("PASS: NOVA executed 5 + 3 correctly; all %0d CPU-core tests passed in %0d cycles.",
                     testsRun, cycles);
        else
            $display("FAIL: %0d of %0d CPU-core tests failed.", errors, testsRun);

        $finish;
    end

endmodule
