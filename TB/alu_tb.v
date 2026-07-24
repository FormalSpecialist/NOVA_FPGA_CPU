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
    alu uut (

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
        opCode = 3'b000;
        operandA = 8'b00000010;
        operandB = 8'b00000001;

        // Expected Result: 00000011 | 3
        
        #10
        reset = 0;
        #10

        // SUB
        reset = 0;
        opCode = 3'b001;
        operandA = 8'b00000101;
        operandB = 8'b00000011;

        // Expected Result: 00000010 | 2
        
        #10
        reset = 1;
        #10

        // AND
        reset = 0;
        opCode = 3'b010;
        operandA = 8'b00101110;
        operandB = 8'b10101101;

        // Expected Result: 00101100 | 2C
        
        #10
        reset = 1;
        #10

        // OR
        reset = 0;
        opCode = 3'b011;
        operandA = 8'b01000010;
        operandB = 8'b00011011;

        // Expected Result: 01011011 | 5B
        
        #10
        reset = 1;
        #10

        // zeroFlag
        reset = 0;
        opCode = 3'b001;
        operandA = 8'b00000010;
        operandB = 8'b00000010;

        // Expected Result: 0
        
        #10
        reset = 1;
        #10

        // overflowFlag
        reset = 0;
        opCode = 3'b000;
        operandA = 8'b00000011;
        operandB = 8'b11111111;

        // Expected Result: Flag up and calc broken?
        
        #10
        reset = 1;
        #10

        // underflowFlag
        reset = 0;
        opCode = 3'b001;
        operandA = 8'b00000001;
        operandB = 8'b00000010;

        // Expected Result: Flag up and calc broken?
        
        #40

        $finish;

    end
    



endmodule








