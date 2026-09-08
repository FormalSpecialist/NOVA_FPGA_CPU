`timescale 1ns / 1ps

module novaNexysA7_tb;

    reg         CLK100MHZ;
    reg         CPU_RESETN;
    reg         BTNC;
    reg  [2:0]  SW;
    wire [15:0] LED;

    integer testsRun;
    integer errors;
    integer coreEdges;
    integer timeoutCycles;
    reg [7:0] savedProgramAddress;

    novaNexysA7 #(
        .AUTO_COUNT_MAX(3),
        .AUTO_COUNTER_WIDTH(3),
        .DEBOUNCE_COUNTER_WIDTH(2),
        .USE_XILINX_CLOCK_BUFFER(0)
    ) uut (
        .CLK100MHZ(CLK100MHZ),
        .CPU_RESETN(CPU_RESETN),
        .BTNC(BTNC),
        .SW(SW),
        .LED(LED)
    );

    always #5 CLK100MHZ = ~CLK100MHZ;

    // Count non-reset clock edges delivered to the CPU core.
    always @(posedge uut.coreClock) begin
        if (!uut.coreReset)
            coreEdges = coreEdges + 1;
    end

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

    task pressStep;
        begin
            // The shortened testbench debounce interval still requires the
            // button to remain stable for several 100 MHz cycles.
            BTNC = 1'b1;
            repeat (10) @(posedge CLK100MHZ);
            BTNC = 1'b0;
            repeat (10) @(posedge CLK100MHZ);
            #1;
        end
    endtask

    task selectDisplay;
        input [1:0] selection;
        begin
            SW[2:1] = selection;
            repeat (4) @(posedge CLK100MHZ);
            #1;
        end
    endtask

    initial begin
        CLK100MHZ = 1'b0;
        CPU_RESETN = 1'b0;
        BTNC = 1'b0;
        SW = 3'b000;
        testsRun = 0;
        errors = 0;
        coreEdges = 0;
        timeoutCycles = 0;

        // Hold the active-low reset long enough to reset every core register.
        repeat (6) @(posedge CLK100MHZ);
        CPU_RESETN = 1'b1;
        repeat (6) @(posedge CLK100MHZ);
        #1;

        check(uut.debugProgramAddress === 8'h00,
              "manual mode changed the PC without a button press");
        check(uut.debugState === 3'd0,
              "CPU did not wait in FETCH after reset");

        // One button press advances one controller cycle: FETCH to DECODE.
        pressStep;
        check(uut.debugProgramAddress === 8'h01,
              "first manual step did not increment PC to 01");
        check(uut.debugInstruction === 16'h1205,
              "first manual step did not fetch LDI R1,5");
        check(uut.debugState === 3'd1,
              "first manual step did not enter DECODE");

        // Thirteen additional controller cycles complete the four-instruction
        // demonstration program.
        repeat (13)
            pressStep;

        check(uut.halted === 1'b1,
              "manual stepping did not reach HALT");
        check(coreEdges == 14,
              "manual stepping did not deliver exactly fourteen CPU clocks");
        check(uut.processor.registerFile.registers[1] === 8'h05,
              "manual mode did not write 05 to R1");
        check(uut.processor.registerFile.registers[2] === 8'h03,
              "manual mode did not write 03 to R2");
        check(uut.processor.registerFile.registers[3] === 8'h08,
              "manual mode did not write 08 to R3");
        check(uut.debugExecutionResult === 8'h08,
              "manual mode did not preserve execution result 08");
        check(uut.debugProgramAddress === 8'h04,
              "manual mode did not stop with PC at 04");

        // HALT must prevent architectural state changes even if more clock
        // pulses are requested.
        savedProgramAddress = uut.debugProgramAddress;
        pressStep;
        check(uut.debugProgramAddress === savedProgramAddress,
              "PC changed after HALT");

        // Verify all four selectable LED views.
        selectDisplay(2'b00);
        check(LED === 16'hF000,
              "instruction LED view did not show HALT (F000)");

        selectDisplay(2'b01);
        check(LED === 16'h0804,
              "result/PC LED view did not show result 08 and PC 04");

        selectDisplay(2'b10);
        check(LED === {uut.halted, uut.zeroFlag, uut.carryFlag,
                       uut.borrowFlag, 1'b0, uut.debugState,
                       uut.debugProgramAddress},
              "status/PC LED view mapping is incorrect");

        selectDisplay(2'b11);
        check(LED === {uut.debugRegisterWriteData, 1'b0,
                       uut.debugRegisterWriteAddress,
                       uut.debugRegisterWriteEnable, uut.borrowFlag,
                       uut.carryFlag, uut.zeroFlag},
              "writeback/flags LED view mapping is incorrect");

        // Reset and prove that automatic mode also completes the program.
        CPU_RESETN = 1'b0;
        BTNC = 1'b0;
        SW = 3'b001;
        repeat (6) @(posedge CLK100MHZ);
        coreEdges = 0;
        CPU_RESETN = 1'b1;

        timeoutCycles = 0;
        while ((uut.halted !== 1'b1) && (timeoutCycles < 200)) begin
            @(posedge CLK100MHZ);
            timeoutCycles = timeoutCycles + 1;
        end
        #1;

        check(uut.halted === 1'b1,
              "automatic mode did not reach HALT before timeout");
        check(uut.debugExecutionResult === 8'h08,
              "automatic mode did not calculate 5 + 3 = 8");
        check(uut.processor.registerFile.registers[3] === 8'h08,
              "automatic mode did not write 08 to R3");

        if (errors == 0)
            $display("PASS: all %0d NOVA Nexys A7 wrapper tests completed successfully.",
                     testsRun);
        else
            $display("FAIL: %0d of %0d NOVA Nexys A7 wrapper tests failed.",
                     errors, testsRun);

        $finish;
    end

endmodule
