`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: NOVA Summation Demonstration Top
// Module Name: novaSumDemoTop
// Project Name: NOVA
// Description:
//   Reuses the verified Nexys A7 display wrapper while increasing automatic
//   execution from two to ten CPU cycles per second. The 162-cycle summation
//   demonstration therefore completes in approximately 16.2 seconds.
//////////////////////////////////////////////////////////////////////////////////

module novaSumDemoTop #(
    parameter integer AUTO_COUNT_MAX = 9_999_999,
    parameter integer AUTO_COUNTER_WIDTH = 26,
    parameter integer DEBOUNCE_COUNTER_WIDTH = 20,
    parameter integer DISPLAY_REFRESH_COUNTER_WIDTH = 17,
    parameter integer USE_XILINX_CLOCK_BUFFER = 1
) (
    input             CLK100MHZ,
    input             CPU_RESETN,
    input             BTNC,
    input      [2:0]  SW,
    output     [15:0] LED,
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

    novaNexysA7 #(
        .AUTO_COUNT_MAX(AUTO_COUNT_MAX),
        .AUTO_COUNTER_WIDTH(AUTO_COUNTER_WIDTH),
        .DEBOUNCE_COUNTER_WIDTH(DEBOUNCE_COUNTER_WIDTH),
        .DISPLAY_REFRESH_COUNTER_WIDTH(DISPLAY_REFRESH_COUNTER_WIDTH),
        .USE_XILINX_CLOCK_BUFFER(USE_XILINX_CLOCK_BUFFER)
    ) boardInterface (
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

endmodule
