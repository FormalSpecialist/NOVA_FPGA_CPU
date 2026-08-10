`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Noah Arnold
// 
// Create Date: 06/24/2026 04:26:52 PM
// Design Name: Arithmatic Logice Unit
// Module Name: alu
// Project Name: NOVA
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: arithmeticFlags.v
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

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

    parameter opADD = 4'b0000;
    parameter opSUB = 4'b0001;
    parameter opAND = 4'b0010;
    parameter opOR = 4'b0011;

    // Enable for Flags
    reg flags_en;
    
    // Initialize Values at Program Start
    initial begin
        result = 8'b0000_0000;
        flags_en = 1'b0;
    end
    

always @ (*) begin

    if (reset) begin
        result = 8'b0000_0000;
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
        default: result = 8'b0000_0000;

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
