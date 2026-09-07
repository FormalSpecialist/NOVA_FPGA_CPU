`timescale 1ns / 1ps
`include "novaDefinitions.vh"

module cu_tb;

    reg        clk;
    reg        reset;
    reg  [3:0] instructionOpcode;
    reg        zeroFlag;
    reg        carryFlag;

    wire       pcIncrementEnable;
    wire       pcLoadEnable;
    wire       instructionLoadEnable;
    wire       registerWriteEnable;
    wire       dataMemoryWriteEnable;
    wire       flagWriteEnable;
    wire [2:0] aluOperation;
    wire [1:0] writeBackSelect;
    wire       halted;
    wire [2:0] currentStateDebug;

    integer testsRun;
    integer errors;

    cu uut (
        .clk(clk),
        .reset(reset),
        .instructionOpcode(instructionOpcode),
        .zeroFlag(zeroFlag),
        .carryFlag(carryFlag),
        .pcIncrementEnable(pcIncrementEnable),
        .pcLoadEnable(pcLoadEnable),
        .instructionLoadEnable(instructionLoadEnable),
        .registerWriteEnable(registerWriteEnable),
        .dataMemoryWriteEnable(dataMemoryWriteEnable),
        .flagWriteEnable(flagWriteEnable),
        .aluOperation(aluOperation),
        .writeBackSelect(writeBackSelect),
        .halted(halted),
        .currentStateDebug(currentStateDebug)
    );

    always #5 clk = ~clk;

    task advanceClock;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    task checkControls;
        input [2:0] expectedState;
        input       expectedPcIncrement;
        input       expectedPcLoad;
        input       expectedInstructionLoad;
        input       expectedRegisterWrite;
        input       expectedMemoryWrite;
        input       expectedFlagWrite;
        input [2:0] expectedAluOperation;
        input [1:0] expectedWriteBack;
        input       expectedHalted;
        begin
            #1;
            testsRun = testsRun + 1;

            if ((currentStateDebug !== expectedState) ||
                (pcIncrementEnable !== expectedPcIncrement) ||
                (pcLoadEnable !== expectedPcLoad) ||
                (instructionLoadEnable !== expectedInstructionLoad) ||
                (registerWriteEnable !== expectedRegisterWrite) ||
                (dataMemoryWriteEnable !== expectedMemoryWrite) ||
                (flagWriteEnable !== expectedFlagWrite) ||
                (aluOperation !== expectedAluOperation) ||
                (writeBackSelect !== expectedWriteBack) ||
                (halted !== expectedHalted)) begin
                errors = errors + 1;
                $display("FAIL test %0d: state=%0d opcode=%h PCinc=%b PCload=%b IRload=%b RegW=%b MemW=%b FlagW=%b ALU=%b WB=%b halt=%b",
                         testsRun, currentStateDebug, instructionOpcode,
                         pcIncrementEnable, pcLoadEnable, instructionLoadEnable,
                         registerWriteEnable, dataMemoryWriteEnable,
                         flagWriteEnable, aluOperation, writeBackSelect, halted);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        instructionOpcode = `NOVA_OPCODE_NOP;
        zeroFlag = 1'b0;
        carryFlag = 1'b0;
        testsRun = 0;
        errors = 0;

        advanceClock;
        reset = 1'b0;
        checkControls(`NOVA_STATE_FETCH, 1'b1, 1'b0, 1'b1, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);

        // LDI: FETCH -> DECODE -> EXECUTE -> WRITEBACK -> FETCH.
        instructionOpcode = `NOVA_OPCODE_LDI;
        advanceClock;
        checkControls(`NOVA_STATE_DECODE, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_EXECUTE, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_WRITEBACK, 1'b0, 1'b0, 1'b0, 1'b1,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_IMMEDIATE, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_FETCH, 1'b1, 1'b0, 1'b1, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);

        // ADD selects the ALU, saves flags, and writes back its result.
        instructionOpcode = `NOVA_OPCODE_ADD;
        advanceClock;
        checkControls(`NOVA_STATE_DECODE, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_EXECUTE, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b1, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_WRITEBACK, 1'b0, 1'b0, 1'b0, 1'b1,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_FETCH, 1'b1, 1'b0, 1'b1, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);

        // A conditional jump must not load the PC when zero is clear.
        instructionOpcode = `NOVA_OPCODE_JZ;
        zeroFlag = 1'b0;
        advanceClock;
        checkControls(`NOVA_STATE_DECODE, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_EXECUTE, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_FETCH, 1'b1, 1'b0, 1'b1, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);

        // The same instruction must load the PC when zero is set.
        zeroFlag = 1'b1;
        advanceClock;
        checkControls(`NOVA_STATE_DECODE, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_EXECUTE, 1'b0, 1'b1, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_FETCH, 1'b1, 1'b0, 1'b1, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);

        // HALT enters and remains in the terminal state.
        instructionOpcode = `NOVA_OPCODE_HALT;
        advanceClock;
        checkControls(`NOVA_STATE_DECODE, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b0);
        advanceClock;
        checkControls(`NOVA_STATE_HALT, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b1);
        advanceClock;
        checkControls(`NOVA_STATE_HALT, 1'b0, 1'b0, 1'b0, 1'b0,
                      1'b0, 1'b0, `NOVA_ALU_ADD, `NOVA_WB_ALU, 1'b1);

        if (errors == 0)
            $display("PASS: all %0d control-unit tests completed successfully.", testsRun);
        else
            $display("FAIL: %0d of %0d control-unit tests failed.", errors, testsRun);

        $finish;
    end

endmodule
