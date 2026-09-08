`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: Eight-Digit Hexadecimal Display Driver
// Module Name: sevenSegmentDisplay
// Project Name: NOVA
// Description:
//   Multiplexes eight hexadecimal digits onto the active-low common-anode
//   seven-segment display used by the Nexys A7.
//////////////////////////////////////////////////////////////////////////////////

module sevenSegmentDisplay #(
    // With a 100 MHz input, 17 bits refresh the entire display at about 763 Hz.
    parameter integer REFRESH_COUNTER_WIDTH = 17
) (
    input             clk,
    input             reset,
    input      [31:0] hexValue,
    input      [7:0]  decimalPointEnable,

    output reg [6:0]  segments,
    output reg        DP,
    output reg [7:0]  AN
);

    reg [REFRESH_COUNTER_WIDTH-1:0] refreshCounter;
    wire [2:0] digitSelect;
    reg  [3:0] selectedNibble;

    assign digitSelect = refreshCounter[REFRESH_COUNTER_WIDTH-1 -: 3];

    always @(posedge clk) begin
        if (reset)
            refreshCounter <= {REFRESH_COUNTER_WIDTH{1'b0}};
        else
            refreshCounter <= refreshCounter + 1'b1;
    end

    // AN[0] is the rightmost digit and AN[7] is the leftmost digit.
    always @(*) begin
        AN = 8'hFF;
        AN[digitSelect] = 1'b0;

        case (digitSelect)
            3'd0: selectedNibble = hexValue[3:0];
            3'd1: selectedNibble = hexValue[7:4];
            3'd2: selectedNibble = hexValue[11:8];
            3'd3: selectedNibble = hexValue[15:12];
            3'd4: selectedNibble = hexValue[19:16];
            3'd5: selectedNibble = hexValue[23:20];
            3'd6: selectedNibble = hexValue[27:24];
            3'd7: selectedNibble = hexValue[31:28];
            default: selectedNibble = 4'h0;
        endcase

        // The Nexys A7 decimal point is active low.
        DP = ~decimalPointEnable[digitSelect];
    end

    // Segment order is {CA, CB, CC, CD, CE, CF, CG}; zero illuminates a
    // segment because the board display is active low.
    always @(*) begin
        case (selectedNibble)
            4'h0: segments = 7'b0000001;
            4'h1: segments = 7'b1001111;
            4'h2: segments = 7'b0010010;
            4'h3: segments = 7'b0000110;
            4'h4: segments = 7'b1001100;
            4'h5: segments = 7'b0100100;
            4'h6: segments = 7'b0100000;
            4'h7: segments = 7'b0001111;
            4'h8: segments = 7'b0000000;
            4'h9: segments = 7'b0000100;
            4'hA: segments = 7'b0001000;
            4'hB: segments = 7'b1100000;
            4'hC: segments = 7'b0110001;
            4'hD: segments = 7'b1000010;
            4'hE: segments = 7'b0110000;
            4'hF: segments = 7'b0111000;
            default: segments = 7'b1111111;
        endcase
    end

endmodule
