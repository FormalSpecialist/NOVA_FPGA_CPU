`timescale 1ns / 1ps

module programCounter_tb;

    reg        clk;
    reg        reset;
    reg        incrementEnable;
    reg        loadEnable;
    reg  [7:0] loadAddress;

    wire [7:0] programAddress;

    integer testsRun;
    integer errors;

    programCounter uut (
        .clk(clk),
        .reset(reset),
        .incrementEnable(incrementEnable),
        .loadEnable(loadEnable),
        .loadAddress(loadAddress),
        .programAddress(programAddress)
    );

    always #5 clk = ~clk;

    task clockAndCheck;
        input [7:0] expectedAddress;
        begin
            @(posedge clk);
            #1;
            testsRun = testsRun + 1;

            if (programAddress !== expectedAddress) begin
                errors = errors + 1;
                $display("FAIL test %0d: address=%h expected=%h | reset=%b load=%b increment=%b loadAddress=%h",
                         testsRun, programAddress, expectedAddress, reset,
                         loadEnable, incrementEnable, loadAddress);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        incrementEnable = 1'b0;
        loadEnable = 1'b0;
        loadAddress = 8'h00;
        testsRun = 0;
        errors = 0;

        // Reset always returns execution to instruction address 0x00.
        clockAndCheck(8'h00);

        // With both enables low, the program counter must hold its value.
        reset = 1'b0;
        clockAndCheck(8'h00);

        // Sequential instruction fetches increment the address once per clock.
        incrementEnable = 1'b1;
        clockAndCheck(8'h01);
        clockAndCheck(8'h02);

        // Disabling increment must preserve the current address.
        incrementEnable = 1'b0;
        clockAndCheck(8'h02);

        // A jump or taken branch loads an explicit target address.
        loadEnable = 1'b1;
        loadAddress = 8'hA5;
        clockAndCheck(8'hA5);

        // Load has priority if load and increment are accidentally asserted
        // during the same cycle.
        incrementEnable = 1'b1;
        loadAddress = 8'h3C;
        clockAndCheck(8'h3C);

        // Verify eight-bit wraparound from 0xFF to 0x00.
        incrementEnable = 1'b0;
        loadAddress = 8'hFF;
        clockAndCheck(8'hFF);

        loadEnable = 1'b0;
        incrementEnable = 1'b1;
        clockAndCheck(8'h00);

        // Reset has priority over both loading and incrementing.
        reset = 1'b1;
        loadEnable = 1'b1;
        incrementEnable = 1'b1;
        loadAddress = 8'hEE;
        clockAndCheck(8'h00);

        if (errors == 0)
            $display("PASS: all %0d program-counter tests completed successfully.", testsRun);
        else
            $display("FAIL: %0d of %0d program-counter tests failed.", errors, testsRun);

        $finish;
    end

endmodule
