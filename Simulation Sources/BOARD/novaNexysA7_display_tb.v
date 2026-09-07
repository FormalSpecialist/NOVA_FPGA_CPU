`timescale 1ns / 1ps

module novaNexysA7_display_tb;

    reg         CLK100MHZ;
    reg         CPU_RESETN;
    reg         BTNC;
    reg  [2:0]  SW;
    wire [15:0] LED;
    wire        CA;
    wire        CB;
    wire        CC;
    wire        CD;
    wire        CE;
    wire        CF;
    wire        CG;
    wire        DP;
    wire [7:0]  AN;

    integer testsRun;
    integer errors;
    integer timeoutCycles;
    integer i;

    novaNexysA7 #(
        .AUTO_COUNT_MAX(3),
        .AUTO_COUNTER_WIDTH(3),
        .DEBOUNCE_COUNTER_WIDTH(2),
        .DISPLAY_REFRESH_COUNTER_WIDTH(3),
        .USE_XILINX_CLOCK_BUFFER(0)
    ) uut (
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .BTNC(BTNC),
        .SW(SW),
        .LED(LED),
        .CA(CA),
        .CB(CB),
        .CC(CC),
        .CD(CD),
        .CE(CE),
        .CF(CF),
        .CG(CG),
        .DP(DP),
        .AN(AN)
    );

    always #5 CLK100MHZ = ~CLK100MHZ;

    function [6:0] expectedSegments;
        input [3:0] value;
        begin
            case (value)
                4'h0: expectedSegments = 7'b0000001;
                4'h1: expectedSegments = 7'b1001111;
                4'h2: expectedSegments = 7'b0010010;
                4'h3: expectedSegments = 7'b0000110;
                4'h4: expectedSegments = 7'b1001100;
                4'h5: expectedSegments = 7'b0100100;
                4'h6: expectedSegments = 7'b0100000;
                4'h7: expectedSegments = 7'b0001111;
                4'h8: expectedSegments = 7'b0000000;
                4'h9: expectedSegments = 7'b0000100;
                4'hA: expectedSegments = 7'b0001000;
                4'hB: expectedSegments = 7'b1100000;
                4'hC: expectedSegments = 7'b0110001;
                4'hD: expectedSegments = 7'b1000010;
                4'hE: expectedSegments = 7'b0110000;
                4'hF: expectedSegments = 7'b0111000;
                default: expectedSegments = 7'b1111111;
            endcase
        end
    endfunction

    task check;
        input condition;
        input [8*96-1:0] message;
        begin
            testsRun = testsRun + 1;
            if (condition !== 1'b1) begin
                errors = errors + 1;
                $display("FAIL: %0s", message);
            end
        end
    endtask

    task waitForDigit;
        input [2:0] digit;
        begin
            @(negedge CLK100MHZ);
            while (uut.displayDriver.digitSelect !== digit)
                @(negedge CLK100MHZ);
            #1;
        end
    endtask

    initial begin
        CLK100MHZ = 1'b0;
        CPU_RESETN = 1'b0;
        BTNC = 1'b0;
        SW = 3'b001; // Automatic mode; LED view does not affect hex display.
        testsRun = 0;
        errors = 0;
        timeoutCycles = 0;

        repeat (6) @(posedge CLK100MHZ);
        CPU_RESETN = 1'b1;

        while ((uut.halted !== 1'b1) && (timeoutCycles < 200)) begin
            @(posedge CLK100MHZ);
            timeoutCycles = timeoutCycles + 1;
        end
        #1;

        check(uut.halted === 1'b1,
              "automatic CPU execution did not reach HALT");
        check(uut.debugProgramAddress === 8'h04,
              "display integration test ended with the wrong PC");
        check(uut.debugInstruction === 16'hF000,
              "display integration test ended with the wrong instruction");
        check(uut.debugExecutionResult === 8'h08,
              "display integration test ended with the wrong result");
        check(uut.sevenSegmentValue === 32'h04F0_0008,
              "wrapper did not assemble PC/instruction/result correctly");
        check(uut.decimalPointEnable === 8'b0100_0100,
              "wrapper decimal-point separators are incorrect");

        // Verify every physical digit of the final 04.F000.08 display.
        for (i = 0; i < 8; i = i + 1) begin
            waitForDigit(i);

            testsRun = testsRun + 1;
            if (AN !== ~(8'b0000_0001 << i)) begin
                errors = errors + 1;
                $display("FAIL: integrated digit %0d selected AN=%b.", i, AN);
            end

            testsRun = testsRun + 1;
            if ({CA, CB, CC, CD, CE, CF, CG} !==
                expectedSegments(32'h04F0_0008 >> (i * 4))) begin
                errors = errors + 1;
                $display("FAIL: integrated digit %0d has the wrong segments.", i);
            end

            testsRun = testsRun + 1;
            if (DP !== ~uut.decimalPointEnable[i]) begin
                errors = errors + 1;
                $display("FAIL: integrated digit %0d has the wrong decimal point.", i);
            end
        end

        if (errors == 0)
            $display("PASS: all %0d NOVA display-integration tests completed successfully.",
                     testsRun);
        else
            $display("FAIL: %0d of %0d NOVA display-integration tests failed.",
                     errors, testsRun);

        $finish;
    end

endmodule
