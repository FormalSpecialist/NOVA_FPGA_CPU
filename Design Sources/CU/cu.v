`timescale 1ns / 1ps
`include "novaDefinitions.vh"
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: Control Unit
// Module Name: cu
// Project Name: NOVA
// Description:
//   Multicycle finite-state-machine controller for the NOVA CPU. It sequences
//   instruction fetch, decode, execution, writeback, and halt behavior.
//////////////////////////////////////////////////////////////////////////////////

module cu (
    input            clk,
    input            reset,
    input      [3:0] instructionOpcode,
    input            zeroFlag,
    input            carryFlag,

    output reg       pcIncrementEnable,
    output reg       pcLoadEnable,
    output reg       instructionLoadEnable,
    output reg       registerWriteEnable,
    output reg       dataMemoryWriteEnable,
    output reg       flagWriteEnable,
    output reg [2:0] aluOperation,
    output reg [1:0] writeBackSelect,
    output reg       halted,
    output     [2:0] currentStateDebug
);

    reg [2:0] currentState;
    reg [2:0] nextState;

    assign currentStateDebug = currentState;

    // The state register is the controller's stored state.
    always @(posedge clk) begin
        if (reset)
            currentState <= `NOVA_STATE_FETCH;
        else
            currentState <= nextState;
    end

    // Decode the current state and instruction into datapath control signals.
    always @(*) begin
        // Safe defaults prevent unintended writes and inferred latches.
        nextState = currentState;
        pcIncrementEnable = 1'b0;
        pcLoadEnable = 1'b0;
        instructionLoadEnable = 1'b0;
        registerWriteEnable = 1'b0;
        dataMemoryWriteEnable = 1'b0;
        flagWriteEnable = 1'b0;
        aluOperation = `NOVA_ALU_ADD;
        writeBackSelect = `NOVA_WB_ALU;
        halted = 1'b0;

        case (currentState)
            `NOVA_STATE_FETCH: begin
                // Capture ROM[PC] while advancing PC to the next address.
                instructionLoadEnable = 1'b1;
                pcIncrementEnable = 1'b1;
                nextState = `NOVA_STATE_DECODE;
            end

            `NOVA_STATE_DECODE: begin
                // NOP has nothing to execute; HALT enters a terminal state.
                case (instructionOpcode)
                    `NOVA_OPCODE_NOP:
                        nextState = `NOVA_STATE_FETCH;

                    `NOVA_OPCODE_HALT:
                        nextState = `NOVA_STATE_HALT;

                    default:
                        nextState = `NOVA_STATE_EXECUTE;
                endcase
            end

            `NOVA_STATE_EXECUTE: begin
                // Most instructions finish execution by returning to FETCH.
                nextState = `NOVA_STATE_FETCH;

                case (instructionOpcode)
                    `NOVA_OPCODE_LDI,
                    `NOVA_OPCODE_MOV,
                    `NOVA_OPCODE_LD:
                        nextState = `NOVA_STATE_WRITEBACK;

                    `NOVA_OPCODE_ADD: begin
                        aluOperation = `NOVA_ALU_ADD;
                        flagWriteEnable = 1'b1;
                        nextState = `NOVA_STATE_WRITEBACK;
                    end

                    `NOVA_OPCODE_SUB: begin
                        aluOperation = `NOVA_ALU_SUB;
                        flagWriteEnable = 1'b1;
                        nextState = `NOVA_STATE_WRITEBACK;
                    end

                    `NOVA_OPCODE_AND: begin
                        aluOperation = `NOVA_ALU_AND;
                        flagWriteEnable = 1'b1;
                        nextState = `NOVA_STATE_WRITEBACK;
                    end

                    `NOVA_OPCODE_OR: begin
                        aluOperation = `NOVA_ALU_OR;
                        flagWriteEnable = 1'b1;
                        nextState = `NOVA_STATE_WRITEBACK;
                    end

                    `NOVA_OPCODE_XOR: begin
                        aluOperation = `NOVA_ALU_XOR;
                        flagWriteEnable = 1'b1;
                        nextState = `NOVA_STATE_WRITEBACK;
                    end

                    `NOVA_OPCODE_SHL: begin
                        aluOperation = `NOVA_ALU_SHL;
                        flagWriteEnable = 1'b1;
                        nextState = `NOVA_STATE_WRITEBACK;
                    end

                    `NOVA_OPCODE_SHR: begin
                        aluOperation = `NOVA_ALU_SHR;
                        flagWriteEnable = 1'b1;
                        nextState = `NOVA_STATE_WRITEBACK;
                    end

                    `NOVA_OPCODE_ST:
                        dataMemoryWriteEnable = 1'b1;

                    `NOVA_OPCODE_JMP:
                        pcLoadEnable = 1'b1;

                    `NOVA_OPCODE_JZ: begin
                        if (zeroFlag)
                            pcLoadEnable = 1'b1;
                    end

                    `NOVA_OPCODE_JC: begin
                        if (carryFlag)
                            pcLoadEnable = 1'b1;
                    end

                    default: begin
                        nextState = `NOVA_STATE_FETCH;
                    end
                endcase
            end

            `NOVA_STATE_WRITEBACK: begin
                nextState = `NOVA_STATE_FETCH;

                case (instructionOpcode)
                    `NOVA_OPCODE_LDI: begin
                        registerWriteEnable = 1'b1;
                        writeBackSelect = `NOVA_WB_IMMEDIATE;
                    end

                    `NOVA_OPCODE_MOV: begin
                        registerWriteEnable = 1'b1;
                        writeBackSelect = `NOVA_WB_REGISTER;
                    end

                    `NOVA_OPCODE_ADD,
                    `NOVA_OPCODE_SUB,
                    `NOVA_OPCODE_AND,
                    `NOVA_OPCODE_OR,
                    `NOVA_OPCODE_XOR,
                    `NOVA_OPCODE_SHL,
                    `NOVA_OPCODE_SHR: begin
                        registerWriteEnable = 1'b1;
                        writeBackSelect = `NOVA_WB_ALU;
                    end

                    `NOVA_OPCODE_LD: begin
                        registerWriteEnable = 1'b1;
                        writeBackSelect = `NOVA_WB_MEMORY;
                    end

                    default: begin
                        registerWriteEnable = 1'b0;
                    end
                endcase
            end

            `NOVA_STATE_HALT: begin
                halted = 1'b1;
                nextState = `NOVA_STATE_HALT;
            end

            default: begin
                // Recover from an invalid state by restarting instruction fetch.
                nextState = `NOVA_STATE_FETCH;
            end
        endcase
    end

endmodule
