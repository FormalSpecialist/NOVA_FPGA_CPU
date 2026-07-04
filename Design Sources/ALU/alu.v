`timescale 1ns / 1ps

module alu(

    input [7:0] operandA,
    input [7:0] operandB,
    input [2:0] opCode,
    
    output reg [7:0] result,
    output reg zeroFlag,
    output reg overflowFlag,
    output reg underflowFlag

);

    parameter opADD = 3'b000;
    parameter opSUB = 3'b001;
    parameter opAND = 3'b010;
    parameter opOR = 3'b011;


    always @ (opCode) begin

        // Determines which action to perfom based on Operational Code
        case (opCode)

            opADD: result = 8'b0;
            opSUB: result = 8'b0;
            opAND: result = 8'b0;
            opOR: result = 8'b0;
            default: result = 8'b0;

        endcase

        // Testing to see if result is zero
        if (result == 8'b0) begin

            zeroFlag = 1'b1;

        end else begin

            zeroFlag = 1'b0;

        end

        // Tests to see if Overflow occurs | a + b = result
        if ( opCode == opADD ) begin
            overflowFlag = ( operandA > result || operandB > result );
        end 

        // Tests to see if Underflow occurs | a - b = result
        if (opCode == opSUB ) begin
            underflowFlag = ( result > operandA);
        end

    end


endmodule