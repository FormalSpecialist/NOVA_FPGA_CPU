`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: Program Counter
// Module Name: programCounter
// Project Name: NOVA
// Description:
//   Stores the eight-bit address of the next instruction to fetch. The control
//   unit can hold the current address, increment it for sequential execution,
//   or load a new address for a jump or taken branch.
//////////////////////////////////////////////////////////////////////////////////

module programCounter (
    input            clk,
    input            reset,
    input            incrementEnable,
    input            loadEnable,
    input      [7:0] loadAddress,

    output reg [7:0] programAddress
);

    // Priority: reset, explicit load, increment, then hold.
    always @(posedge clk) begin
        if (reset)
            programAddress <= 8'h00;
        else if (loadEnable)
            programAddress <= loadAddress;
        else if (incrementEnable)
            programAddress <= programAddress + 8'h01;
    end

endmodule
