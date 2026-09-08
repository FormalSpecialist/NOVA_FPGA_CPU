`timescale 1ns / 1ps

module sumBoard_tb;

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

    novaSumDemoTop #(
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

    initial begin
        CLK100MHZ = 1'b0;
        CPU_RESETN = 1'b0;
        BTNC = 1'b0;
        SW = 3'b001; // Automatic mode
        testsRun = 0;
        errors = 0;
        timeoutCycles = 0;

        repeat (6) @(posedge CLK100MHZ);
        CPU_RESETN = 1'b1;

        while ((uut.boardInterface.halted !== 1'b1) &&
               (timeoutCycles < 1000)) begin
            @(posedge CLK100MHZ);
            timeoutCycles = timeoutCycles + 1;
        end
        #1;

        check(uut.boardInterface.halted === 1'b1,
              "summation board demo did not reach HALT");
        check(uut.boardInterface.debugProgramAddress === 8'h0B,
              "summation board demo ended with the wrong PC");
        check(uut.boardInterface.debugInstruction === 16'hF000,
              "summation board demo ended with the wrong instruction");
        check(uut.boardInterface.debugExecutionResult === 8'h37,
              "summation board demo ended with the wrong result");
        check(uut.boardInterface.sevenSegmentValue === 32'h0BF0_0037,
              "seven-segment value is not 0B.F000.37");
        check(uut.boardInterface.processor.dataRam.memory[8'h10] === 8'h37,
              "board-level program did not store 37 in RAM address 10");

        if (errors == 0)
            $display("PASS: all %0d NOVA summation board tests completed successfully.",
                     testsRun);
        else
            $display("FAIL: %0d of %0d NOVA summation board tests failed.",
                     errors, testsRun);

        $finish;
    end

endmodule
