`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: Instruction Register
// Module Name: instructionRegister
// Project Name: NOVA
// Description:
//   Captures one 16-bit instruction during the fetch cycle and holds it stable
//   while the control unit decodes and executes that instruction.
//////////////////////////////////////////////////////////////////////////////////

module instructionRegister (
    input             clk,
    input             reset,
    input             loadEnable,
    input      [15:0] instructionIn,

    output reg [15:0] instructionOut
);

    always @(posedge clk) begin
        if (reset)
            instructionOut <= 16'h0000;
        else if (loadEnable)
            instructionOut <= instructionIn;
    end

endmodule
