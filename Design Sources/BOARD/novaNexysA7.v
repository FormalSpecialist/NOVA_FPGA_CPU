`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: NOVA Nexys A7 Top Level with Hex Display
// Module Name: novaNexysA7
// Project Name: NOVA
// Target Device: xc7a100tcsg324-1 (Nexys A7-100T)
// Description:
//   Board-level wrapper for the verified NOVA CPU core. It provides synchronized
//   reset and switch inputs, debounced single-step control, automatic slow-run
//   control, selectable LEDs, and an eight-digit PC/instruction/result display.
//////////////////////////////////////////////////////////////////////////////////

module novaNexysA7 #(
    parameter integer AUTO_COUNT_MAX = 49_999_999,
    parameter integer AUTO_COUNTER_WIDTH = 26,
    parameter integer DEBOUNCE_COUNTER_WIDTH = 20,
    parameter integer DISPLAY_REFRESH_COUNTER_WIDTH = 17,

    // Set to zero only in the behavioral testbench. Hardware must use BUFGCE.
    parameter integer USE_XILINX_CLOCK_BUFFER = 1
) (
    input             CLK100MHZ,
    input             CPU_RESETN,
    input             BTNC,
    input      [2:0]  SW,
    output reg [15:0] LED,

    output            CA,
    output            CB,
    output            CC,
    output            CD,
    output            CE,
    output            CF,
    output            CG,
    output            DP,
    output     [7:0]  AN
);

    // CPU_RESETN is active low. Assertion is asynchronous so the reset request
    // is recognized immediately; deassertion is synchronized to CLK100MHZ.
    (* ASYNC_REG = "TRUE" *) reg resetSyncStage1 = 1'b1;
    (* ASYNC_REG = "TRUE" *) reg resetSyncStage2 = 1'b1;

    always @(posedge CLK100MHZ or negedge CPU_RESETN) begin
        if (!CPU_RESETN) begin
            resetSyncStage1 <= 1'b1;
            resetSyncStage2 <= 1'b1;
        end else begin
            resetSyncStage1 <= 1'b0;
            resetSyncStage2 <= resetSyncStage1;
        end
    end

    wire coreReset;
    assign coreReset = resetSyncStage2;

    // Synchronize the three slide switches before using them in logic.
    (* ASYNC_REG = "TRUE" *) reg [2:0] switchSyncStage1;
    (* ASYNC_REG = "TRUE" *) reg [2:0] switchSyncStage2;

    always @(posedge CLK100MHZ) begin
        if (coreReset) begin
            switchSyncStage1 <= 3'b000;
            switchSyncStage2 <= 3'b000;
        end else begin
            switchSyncStage1 <= SW;
            switchSyncStage2 <= switchSyncStage1;
        end
    end

    wire       automaticMode;
    wire [1:0] displaySelect;
    assign automaticMode = switchSyncStage2[0];
    assign displaySelect = switchSyncStage2[2:1];

    // Condition BTNC so one physical press generates exactly one CPU cycle.
    wire conditionedButtonLevel;
    wire manualStepPulse;

    buttonConditioner #(
        .COUNTER_WIDTH(DEBOUNCE_COUNTER_WIDTH)
    ) stepButton (
        .clk(CLK100MHZ),
        .reset(coreReset),
        .buttonIn(BTNC),
        .buttonLevel(conditionedButtonLevel),
        .buttonPressed(manualStepPulse)
    );

    // Generate one enable request at a human-visible rate in automatic mode.
    reg [AUTO_COUNTER_WIDTH-1:0] automaticCounter;
    reg                          automaticTick;

    always @(posedge CLK100MHZ) begin
        if (coreReset || !automaticMode) begin
            automaticCounter <= {AUTO_COUNTER_WIDTH{1'b0}};
            automaticTick    <= 1'b0;
        end else if (AUTO_COUNT_MAX == 0) begin
            automaticCounter <= {AUTO_COUNTER_WIDTH{1'b0}};
            automaticTick    <= 1'b1;
        end else if (automaticCounter >= AUTO_COUNT_MAX) begin
            automaticCounter <= {AUTO_COUNTER_WIDTH{1'b0}};
            automaticTick    <= 1'b1;
        end else begin
            automaticCounter <= automaticCounter + 1'b1;
            automaticTick    <= 1'b0;
        end
    end

    wire coreClockEnable;
    wire coreClock;

    assign coreClockEnable = coreReset |
                             (automaticMode ? automaticTick : manualStepPulse);

    generate
        if (USE_XILINX_CLOCK_BUFFER != 0) begin : hardwareClockBuffer
            BUFGCE coreClockBuffer (
                .I(CLK100MHZ),
                .CE(coreClockEnable),
                .O(coreClock)
            );
        end else begin : behavioralClockBuffer
            reg behavioralEnableLatch;
            always @(negedge CLK100MHZ)
                behavioralEnableLatch <= coreClockEnable;
            assign coreClock = CLK100MHZ & behavioralEnableLatch;
        end
    endgenerate

    // Signals exported by the verified CPU core.
    wire        halted;
    wire        zeroFlag;
    wire        carryFlag;
    wire        borrowFlag;
    wire [7:0]  debugProgramAddress;
    wire [15:0] debugInstruction;
    wire [2:0]  debugState;
    wire [7:0]  debugExecutionResult;
    wire        debugRegisterWriteEnable;
    wire [2:0]  debugRegisterWriteAddress;
    wire [7:0]  debugRegisterWriteData;

    cpuCore processor (
        .clk(coreClock),
        .reset(coreReset),
        .halted(halted),
        .zeroFlag(zeroFlag),
        .carryFlag(carryFlag),
        .borrowFlag(borrowFlag),
        .debugProgramAddress(debugProgramAddress),
        .debugInstruction(debugInstruction),
        .debugState(debugState),
        .debugExecutionResult(debugExecutionResult),
        .debugRegisterWriteEnable(debugRegisterWriteEnable),
        .debugRegisterWriteAddress(debugRegisterWriteAddress),
        .debugRegisterWriteData(debugRegisterWriteData)
    );

    // The eight hexadecimal digits always read from left to right as:
    //     PP.IIII.RR
    // where PP is PC, IIII is the instruction, and RR is the ALU result.
    wire [31:0] sevenSegmentValue;
    wire [7:0]  decimalPointEnable;
    wire [6:0]  segmentSignals;

    assign sevenSegmentValue = {debugProgramAddress,
                                debugInstruction,
                                debugExecutionResult};
    assign decimalPointEnable = 8'b0100_0100;
    assign {CA, CB, CC, CD, CE, CF, CG} = segmentSignals;

    sevenSegmentDisplay #(
        .REFRESH_COUNTER_WIDTH(DISPLAY_REFRESH_COUNTER_WIDTH)
    ) displayDriver (
        .clk(CLK100MHZ),
        .reset(coreReset),
        .hexValue(sevenSegmentValue),
        .decimalPointEnable(decimalPointEnable),
        .segments(segmentSignals),
        .DP(DP),
        .AN(AN)
    );

    // SW[2:1] retains the selectable binary LED debug views.
    always @(*) begin
        case (displaySelect)
            2'b00: LED = debugInstruction;

            2'b01: LED = {debugExecutionResult,
                          debugProgramAddress};

            2'b10: LED = {halted,
                          zeroFlag,
                          carryFlag,
                          borrowFlag,
                          1'b0,
                          debugState,
                          debugProgramAddress};

            2'b11: LED = {debugRegisterWriteData,
                          1'b0,
                          debugRegisterWriteAddress,
                          debugRegisterWriteEnable,
                          borrowFlag,
                          carryFlag,
                          zeroFlag};

            default: LED = 16'h0000;
        endcase
    end

endmodule
