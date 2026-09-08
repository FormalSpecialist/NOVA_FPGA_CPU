`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: Pushbutton Conditioner
// Module Name: buttonConditioner
// Project Name: NOVA
// Description:
//   Synchronizes an asynchronous pushbutton, removes contact bounce, and emits
//   one system-clock pulse for each confirmed low-to-high button transition.
//////////////////////////////////////////////////////////////////////////////////

module buttonConditioner #(
    parameter integer COUNTER_WIDTH = 20
) (
    input  clk,
    input  reset,
    input  buttonIn,

    output reg buttonLevel,
    output reg buttonPressed
);

    // These two registers reduce the chance that button metastability reaches
    // the rest of the design.
    (* ASYNC_REG = "TRUE" *) reg buttonSyncStage1;
    (* ASYNC_REG = "TRUE" *) reg buttonSyncStage2;

    reg [COUNTER_WIDTH-1:0] debounceCounter;
    reg                     previousButtonLevel;

    always @(posedge clk) begin
        if (reset) begin
            buttonSyncStage1 <= 1'b0;
            buttonSyncStage2 <= 1'b0;
        end else begin
            buttonSyncStage1 <= buttonIn;
            buttonSyncStage2 <= buttonSyncStage1;
        end
    end

    always @(posedge clk) begin
        if (reset) begin
            debounceCounter     <= {COUNTER_WIDTH{1'b0}};
            buttonLevel        <= 1'b0;
            previousButtonLevel <= 1'b0;
            buttonPressed      <= 1'b0;
        end else begin
            // The input must disagree with the accepted level for an entire
            // counter interval before the new level is accepted.
            if (buttonSyncStage2 == buttonLevel) begin
                debounceCounter <= {COUNTER_WIDTH{1'b0}};
            end else if (&debounceCounter) begin
                debounceCounter <= {COUNTER_WIDTH{1'b0}};
                buttonLevel     <= buttonSyncStage2;
            end else begin
                debounceCounter <= debounceCounter + 1'b1;
            end

            // This pulse lasts exactly one 100 MHz system-clock cycle.
            previousButtonLevel <= buttonLevel;
            buttonPressed       <= buttonLevel & ~previousButtonLevel;
        end
    end

endmodule
