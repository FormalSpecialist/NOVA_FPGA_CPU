`timescale 1ns / 1ps

// The purpose of this testbench is to test the different combinatorial functions

module alu_tb();

    // Inputs
    reg [7:0] operandA;
    reg [7:0] operandB;
    reg [2:0] opCode;
    reg reset;

    // Outputs
    wire [7:0] result;
    wire zeroFlag;
    wire overflowFlag;
    wire underflowFlag;

    // Instantiate
    alu_tb uut (

        .operandA(operandA),
        .operandB(operandB),
        .opCode(opCode),
        .reset(reset),

        .result(result),
        .zeroFlag(zeroFlag),
        .overflowFlag(overflowFlag),
        .underflowFlag(underflowFlag)

    );


    // Inject
    initial begin
        
        // Initialize (Reset)
        reset = 1;
        #10     // Wait 10ns
        
        // ADD
        reset = 0;
        opCode = 000;
        operandA = 8'b00000010;
        operandB = 8'b00000001;

        // Expected Result: 00000011
        
        #10
        reset = 1;
        #10

        // SUB
        reset = 0;
        opCode = 001;
        operandA = 8'b00000101;
        operandB = 8'b00000011;

        // Expected Result: 00000010
        
        #10
        reset = 1;
        #10

        // AND
        reset = 0;
        opCode = 010;
        operandA = 8'b00101110;
        operandB = 8'b10101101;

        // Expected Result: 00101100
        
        #10
        reset = 1;
        #10

        // OR
        reset = 0;
        opCode = 011;
        operandA = 8'b01000010;
        operandB = 8'b00011011;

        // Expected Result: 01011011
        
        #10
        reset = 1;
        
        #40

        $finish;

    end
    



endmodule








