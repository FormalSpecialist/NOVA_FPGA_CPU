`timescale 1ns / 1ps
`include "novaDefinitions.vh"

module cpuIsa_tb;

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
    integer i;

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

    // Register-format instruction:
    // opcode | destination | source A | source B | reserved
    function [15:0] encodeRegister;
        input [3:0] opcode;
        input [2:0] destination;
        input [2:0] sourceA;
        input [2:0] sourceB;
        begin
            encodeRegister = {opcode, destination, sourceA, sourceB, 3'b000};
        end
    endfunction

    // Immediate/direct-memory instruction:
    // opcode | register | reserved | immediate/address
    function [15:0] encodeImmediate;
        input [3:0] opcode;
        input [2:0] registerAddress;
        input [7:0] immediate;
        begin
            encodeImmediate = {opcode, registerAddress, 1'b0, immediate};
        end
    endfunction

    // Control-flow instruction: opcode | reserved | target address
    function [15:0] encodeJump;
        input [3:0] opcode;
        input [7:0] targetAddress;
        begin
            encodeJump = {opcode, 4'b0000, targetAddress};
        end
    endfunction

    task checkRegister;
        input [2:0] registerAddress;
        input [7:0] expectedValue;
        begin
            testsRun = testsRun + 1;
            if (uut.registerFile.registers[registerAddress] !== expectedValue) begin
                errors = errors + 1;
                $display("FAIL: R%0d=%h; expected %h.", registerAddress,
                         uut.registerFile.registers[registerAddress], expectedValue);
            end
        end
    endtask

    task checkMemory;
        input [7:0] memoryAddress;
        input [7:0] expectedValue;
        begin
            testsRun = testsRun + 1;
            if (uut.dataRam.memory[memoryAddress] !== expectedValue) begin
                errors = errors + 1;
                $display("FAIL: memory[%h]=%h; expected %h.", memoryAddress,
                         uut.dataRam.memory[memoryAddress], expectedValue);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        cycles = 0;
        testsRun = 0;
        errors = 0;

        // Replace the ROM's demonstration program after its time-zero
        // initialization. This affects simulation only, not cpuCore.v.
        #1;
        for (i = 0; i < 256; i = i + 1)
            uut.programRom.memory[i] = 16'h0000;

        uut.programRom.memory[8'h00] = encodeJump(`NOVA_OPCODE_NOP, 8'h00);
        uut.programRom.memory[8'h01] = encodeImmediate(`NOVA_OPCODE_LDI, 3'd1, 8'd12);
        uut.programRom.memory[8'h02] = encodeImmediate(`NOVA_OPCODE_LDI, 3'd2, 8'd5);
        uut.programRom.memory[8'h03] = encodeRegister(`NOVA_OPCODE_ADD, 3'd3, 3'd1, 3'd2);
        uut.programRom.memory[8'h04] = encodeRegister(`NOVA_OPCODE_SUB, 3'd4, 3'd1, 3'd2);
        uut.programRom.memory[8'h05] = encodeRegister(`NOVA_OPCODE_AND, 3'd5, 3'd1, 3'd2);
        uut.programRom.memory[8'h06] = encodeRegister(`NOVA_OPCODE_OR,  3'd6, 3'd1, 3'd2);
        uut.programRom.memory[8'h07] = encodeRegister(`NOVA_OPCODE_XOR, 3'd7, 3'd1, 3'd2);

        uut.programRom.memory[8'h08] = encodeImmediate(`NOVA_OPCODE_ST, 3'd3, 8'h20);
        uut.programRom.memory[8'h09] = encodeImmediate(`NOVA_OPCODE_LD, 3'd0, 8'h20);
        uut.programRom.memory[8'h0A] = encodeRegister(`NOVA_OPCODE_MOV, 3'd2, 3'd4, 3'd0);
        uut.programRom.memory[8'h0B] = encodeRegister(`NOVA_OPCODE_SHL, 3'd5, 3'd2, 3'd0);
        uut.programRom.memory[8'h0C] = encodeRegister(`NOVA_OPCODE_SHR, 3'd6, 3'd5, 3'd0);

        // Preserve the XOR and loaded-memory results for final verification.
        uut.programRom.memory[8'h0D] = encodeImmediate(`NOVA_OPCODE_ST, 3'd7, 8'h22);
        uut.programRom.memory[8'h0E] = encodeRegister(`NOVA_OPCODE_MOV, 3'd7, 3'd0, 3'd0);

        // Produce zero, then verify that JZ skips the sentinel store at 0x11.
        uut.programRom.memory[8'h0F] = encodeRegister(`NOVA_OPCODE_SUB, 3'd2, 3'd2, 3'd2);
        uut.programRom.memory[8'h10] = encodeJump(`NOVA_OPCODE_JZ, 8'h13);
        uut.programRom.memory[8'h11] = encodeImmediate(`NOVA_OPCODE_ST, 3'd3, 8'h30);
        uut.programRom.memory[8'h12] = encodeJump(`NOVA_OPCODE_JMP, 8'h14);
        uut.programRom.memory[8'h13] = encodeImmediate(`NOVA_OPCODE_LDI, 3'd0, 8'h55);

        // Shift 0x80 left to produce zero and carry, then test JC.
        uut.programRom.memory[8'h14] = encodeImmediate(`NOVA_OPCODE_LDI, 3'd1, 8'h80);
        uut.programRom.memory[8'h15] = encodeRegister(`NOVA_OPCODE_SHL, 3'd1, 3'd1, 3'd0);
        uut.programRom.memory[8'h16] = encodeJump(`NOVA_OPCODE_JC, 8'h19);
        uut.programRom.memory[8'h17] = encodeImmediate(`NOVA_OPCODE_ST, 3'd3, 8'h31);
        uut.programRom.memory[8'h18] = encodeJump(`NOVA_OPCODE_JMP, 8'h1A);
        uut.programRom.memory[8'h19] = encodeImmediate(`NOVA_OPCODE_LDI, 3'd0, 8'h66);

        // Produce zero again and verify a second taken JZ.
        uut.programRom.memory[8'h1A] = encodeImmediate(`NOVA_OPCODE_LDI, 3'd2, 8'h01);
        uut.programRom.memory[8'h1B] = encodeRegister(`NOVA_OPCODE_SUB, 3'd2, 3'd2, 3'd2);
        uut.programRom.memory[8'h1C] = encodeJump(`NOVA_OPCODE_JZ, 8'h1F);
        uut.programRom.memory[8'h1D] = encodeImmediate(`NOVA_OPCODE_ST, 3'd3, 8'h32);
        uut.programRom.memory[8'h1E] = encodeJump(`NOVA_OPCODE_NOP, 8'h00);

        // Verify unconditional JMP by skipping the 0xCC overwrite.
        uut.programRom.memory[8'h1F] = encodeImmediate(`NOVA_OPCODE_LDI, 3'd3, 8'h33);
        uut.programRom.memory[8'h20] = encodeJump(`NOVA_OPCODE_JMP, 8'h22);
        uut.programRom.memory[8'h21] = encodeImmediate(`NOVA_OPCODE_LDI, 3'd3, 8'hCC);
        uut.programRom.memory[8'h22] = encodeJump(`NOVA_OPCODE_HALT, 8'h00);

        // Apply synchronous reset after the program has been installed.
        @(posedge clk);
        #1;
        reset = 1'b0;

        while ((halted !== 1'b1) && (cycles < 150)) begin
            @(posedge clk);
            #1;
            cycles = cycles + 1;
        end

        testsRun = testsRun + 1;
        if (halted !== 1'b1) begin
            errors = errors + 1;
            $display("FAIL: CPU did not halt within 150 cycles.");
        end

        testsRun = testsRun + 1;
        if (cycles !== 102) begin
            errors = errors + 1;
            $display("FAIL: execution took %0d cycles; expected 102.", cycles);
        end

        checkRegister(3'd0, 8'h66);
        checkRegister(3'd1, 8'h00);
        checkRegister(3'd2, 8'h00);
        checkRegister(3'd3, 8'h33);
        checkRegister(3'd4, 8'h07);
        checkRegister(3'd5, 8'h0E);
        checkRegister(3'd6, 8'h07);
        checkRegister(3'd7, 8'h11);

        checkMemory(8'h20, 8'h11);
        checkMemory(8'h22, 8'h09);
        checkMemory(8'h30, 8'h00);
        checkMemory(8'h31, 8'h00);
        checkMemory(8'h32, 8'h00);

        testsRun = testsRun + 1;
        if ({zeroFlag, carryFlag, borrowFlag} !== 3'b100) begin
            errors = errors + 1;
            $display("FAIL: final flags ZCB=%b%b%b; expected 100.",
                     zeroFlag, carryFlag, borrowFlag);
        end

        testsRun = testsRun + 1;
        if (debugProgramAddress !== 8'h23) begin
            errors = errors + 1;
            $display("FAIL: PC=%h; expected 23 after fetching HALT.",
                     debugProgramAddress);
        end

        testsRun = testsRun + 1;
        if ((debugInstruction !== 16'hF000) ||
            (debugState !== `NOVA_STATE_HALT)) begin
            errors = errors + 1;
            $display("FAIL: final IR=%h state=%0d; expected F000 and HALT.",
                     debugInstruction, debugState);
        end

        if (errors == 0)
            $display("PASS: all %0d NOVA ISA tests passed in %0d cycles.",
                     testsRun, cycles);
        else
            $display("FAIL: %0d of %0d NOVA ISA tests failed.", errors, testsRun);

        $finish;
    end

endmodule
