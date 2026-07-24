
module alu(

    input [7:0] operandA,
    input [7:0] operandB,
    input [2:0] opCode,
    input reset,
    
    output reg [7:0] result,
    output zeroFlag,
    output overflowFlag,
    output underflowFlag

);

    parameter opADD = 3'b000;
    parameter opSUB = 3'b001;
    parameter opAND = 3'b010;
    parameter opOR = 3'b011;
    // opCode = 3'b111   -->   only assigned when reset

    // Enable for Flags
    reg flags_en;

always @ (*) begin

    if (reset) begin
        result = 8'b00000000;
        flags_en = 1'b0;
    end else begin
       flags_en = 1'b1;
    end


    // Determines which action to perfom based on Operational Code
    case (opCode)

        opADD: result = operandA + operandB;
        opSUB: result = operandA - operandB;
        opAND: result = operandA & operandB;
        opOR: result = operandA | operandB;
        default: result = 8'b00000000;

    endcase

end


    // Initializations of Modules
    arithmeticFlags flags (
        .operandA(operandA),
        .operandB(operandB),
        .opCode(opCode),
        .result(result),
        .flags_en(flags_en),

        .zeroFlag(zeroFlag),
        .overflowFlag(overflowFlag),
        .underflowFlag(underflowFlag)
    );
    


endmodule
