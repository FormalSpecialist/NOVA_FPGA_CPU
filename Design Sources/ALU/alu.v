`timescale 1ns / 1ps

module alu(

    input [7:0] operandA,
    input [7:0] operandB,
    input [2:0] opCode,
    
    output reg [7:0] result,
    output reg zeroFlag,
    output reg overflowFlag

);

    parameter opADD = 3'b000;
    parameter opSUB = 3'b001;
    parameter opAND = 3'b010;
    parameter opOR = 3'b011;


    always @ (opCode) begin

        // Determines which action to perfom based on Operational Code
        case (opCode)

            opADD:

        endcase

        // Testing to see if result is zero
        if (result == 8'b0) begin

            zeroFlag = 1'b1;

        end else begin

            zeroFlag = 1'b0;

        end

        // Tests to see if Overflow occurs
        if (opCode == opADD && (  ) ) begin
            
        end

        // Tests to see if Underflow occurs
        if (opCode == opSUB && ( ) ) begin
            
        end

    end


endmodule