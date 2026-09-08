`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: Status Register
// Module Name: statusRegister
// Project Name: NOVA
// Description:
//   Stores the ALU's zero, carry, and borrow flags. The candidate flags are
//   captured only when flagWriteEnable is asserted by the control unit.
//////////////////////////////////////////////////////////////////////////////////

module statusRegister (
    input      clk,
    input      reset,
    input      flagWriteEnable,
    input      zeroIn,
    input      carryIn,
    input      borrowIn,

    output reg zeroFlag,
    output reg carryFlag,
    output reg borrowFlag
);

    always @(posedge clk) begin
        if (reset) begin
            zeroFlag <= 1'b0;
            carryFlag <= 1'b0;
            borrowFlag <= 1'b0;
        end else if (flagWriteEnable) begin
            zeroFlag <= zeroIn;
            carryFlag <= carryIn;
            borrowFlag <= borrowIn;
        end
    end

endmodule
