`timescale 1ns / 1ps

module arithmeticFlags (
    input [7:0] operandA,
    input [7:0] operandB,
    input [2:0] opCode,
    input [7:0] result,
    input flags_en,

    output reg zeroFlag,
    output reg overflowFlag,
    output reg underflowFlag
);

    parameter opADD = 3'b000;
    parameter opSUB = 3'b001;
    parameter opAND = 3'b010;
    parameter opOR  = 3'b011;

always @ (*) begin
    
    if (flags_en) begin

        // Testing to see if result is zero
        zeroFlag = ( result == 8'b0 );

        // Tests to see if Overflow occurs | a + b = result | 1 = ON and 0 = OFF
        if ( opCode == opADD ) begin

            overflowFlag = ( operandA > result || operandB > result );

        end 

        // Tests to see if Underflow occurs | a - b = result | 1 = ON and 0 = OFF
        if (opCode == opSUB ) begin

            underflowFlag = ( result > operandA);

        end

    end

end




endmodule