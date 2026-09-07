`timescale 1ns / 1ps

module instructionFetch_tb;

    reg         clk;
    reg         reset;
    reg         pcIncrementEnable;
    reg         pcLoadEnable;
    reg  [7:0]  pcLoadAddress;
    reg         instructionLoadEnable;

    wire [7:0]  programAddress;
    wire [15:0] instructionFromMemory;
    wire [15:0] currentInstruction;

    integer testsRun;
    integer errors;

    programCounter pc (
        .clk(clk),
        .reset(reset),
        .incrementEnable(pcIncrementEnable),
        .loadEnable(pcLoadEnable),
        .loadAddress(pcLoadAddress),
        .programAddress(programAddress)
    );

    instructionMemory rom (
        .programAddress(programAddress),
        .instruction(instructionFromMemory)
    );

    instructionRegister ir (
        .clk(clk),
        .reset(reset),
        .loadEnable(instructionLoadEnable),
        .instructionIn(instructionFromMemory),
        .instructionOut(currentInstruction)
    );

    always #5 clk = ~clk;

    task clockAndCheck;
        input [7:0]  expectedAddress;
        input [15:0] expectedInstruction;
        begin
            @(posedge clk);
            #1;
            testsRun = testsRun + 1;

            if ((programAddress !== expectedAddress) ||
                (currentInstruction !== expectedInstruction)) begin
                errors = errors + 1;
                $display("FAIL test %0d: PC=%h expected=%h | IR=%h expected=%h",
                         testsRun, programAddress, expectedAddress,
                         currentInstruction, expectedInstruction);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        pcIncrementEnable = 1'b0;
        pcLoadEnable = 1'b0;
        pcLoadAddress = 8'h00;
        instructionLoadEnable = 1'b0;
        testsRun = 0;
        errors = 0;

        // Reset clears both state-holding registers.
        clockAndCheck(8'h00, 16'h0000);

        // During each fetch edge, the instruction register captures the word
        // at the old PC while the program counter advances to the next address.
        reset = 1'b0;
        pcIncrementEnable = 1'b1;
        instructionLoadEnable = 1'b1;
        clockAndCheck(8'h01, 16'h1205);
        clockAndCheck(8'h02, 16'h1403);
        clockAndCheck(8'h03, 16'h3650);
        clockAndCheck(8'h04, 16'hF000);

        // Turning off both enables must hold the fetch state.
        pcIncrementEnable = 1'b0;
        instructionLoadEnable = 1'b0;
        clockAndCheck(8'h04, 16'hF000);

        // A branch changes the PC without overwriting the current instruction.
        pcLoadEnable = 1'b1;
        pcIncrementEnable = 1'b1;
        pcLoadAddress = 8'h01;
        clockAndCheck(8'h01, 16'hF000);

        // The next fetch captures the instruction at the branch target.
        pcLoadEnable = 1'b0;
        instructionLoadEnable = 1'b1;
        clockAndCheck(8'h02, 16'h1403);

        // Unused ROM addresses contain NOP instructions.
        instructionLoadEnable = 1'b0;
        pcLoadEnable = 1'b1;
        pcIncrementEnable = 1'b0;
        pcLoadAddress = 8'h80;
        clockAndCheck(8'h80, 16'h1403);

        pcLoadEnable = 1'b0;
        pcIncrementEnable = 1'b1;
        instructionLoadEnable = 1'b1;
        clockAndCheck(8'h81, 16'h0000);

        // Reset has priority and returns the fetch path to its initial state.
        reset = 1'b1;
        pcLoadEnable = 1'b1;
        pcIncrementEnable = 1'b1;
        pcLoadAddress = 8'hEE;
        clockAndCheck(8'h00, 16'h0000);

        if (errors == 0)
            $display("PASS: all %0d instruction-fetch tests completed successfully.", testsRun);
        else
            $display("FAIL: %0d of %0d instruction-fetch tests failed.", errors, testsRun);

        $finish;
    end

endmodule
