`timescale 1ns / 1ps

module statusRegister_tb;

    reg clk;
    reg reset;
    reg flagWriteEnable;
    reg zeroIn;
    reg carryIn;
    reg borrowIn;

    wire zeroFlag;
    wire carryFlag;
    wire borrowFlag;

    integer testsRun;
    integer errors;

    statusRegister uut (
        .clk(clk),
        .reset(reset),
        .flagWriteEnable(flagWriteEnable),
        .zeroIn(zeroIn),
        .carryIn(carryIn),
        .borrowIn(borrowIn),
        .zeroFlag(zeroFlag),
        .carryFlag(carryFlag),
        .borrowFlag(borrowFlag)
    );

    always #5 clk = ~clk;

    task clockAndCheck;
        input expectedZero;
        input expectedCarry;
        input expectedBorrow;
        begin
            @(posedge clk);
            #1;
            testsRun = testsRun + 1;

            if ((zeroFlag !== expectedZero) ||
                (carryFlag !== expectedCarry) ||
                (borrowFlag !== expectedBorrow)) begin
                errors = errors + 1;
                $display("FAIL test %0d: flags Z=%b C=%b B=%b expected=%b %b %b",
                         testsRun, zeroFlag, carryFlag, borrowFlag,
                         expectedZero, expectedCarry, expectedBorrow);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        flagWriteEnable = 1'b0;
        zeroIn = 1'b0;
        carryIn = 1'b0;
        borrowIn = 1'b0;
        testsRun = 0;
        errors = 0;

        // Synchronous reset clears all stored flags.
        clockAndCheck(1'b0, 1'b0, 1'b0);

        // An enabled write captures the candidate ALU flags.
        reset = 1'b0;
        flagWriteEnable = 1'b1;
        zeroIn = 1'b1;
        carryIn = 1'b0;
        borrowIn = 1'b1;
        clockAndCheck(1'b1, 1'b0, 1'b1);

        // With writes disabled, input changes must not change stored flags.
        flagWriteEnable = 1'b0;
        zeroIn = 1'b0;
        carryIn = 1'b1;
        borrowIn = 1'b0;
        clockAndCheck(1'b1, 1'b0, 1'b1);

        // Capture a second flag pattern.
        flagWriteEnable = 1'b1;
        clockAndCheck(1'b0, 1'b1, 1'b0);

        // Reset has priority over an attempted flag write.
        reset = 1'b1;
        zeroIn = 1'b1;
        carryIn = 1'b1;
        borrowIn = 1'b1;
        clockAndCheck(1'b0, 1'b0, 1'b0);

        // After reset, disabled writes continue to hold the cleared state.
        reset = 1'b0;
        flagWriteEnable = 1'b0;
        clockAndCheck(1'b0, 1'b0, 1'b0);

        if (errors == 0)
            $display("PASS: all %0d status-register tests completed successfully.", testsRun);
        else
            $display("FAIL: %0d of %0d status-register tests failed.", errors, testsRun);

        $finish;
    end

endmodule
