`timescale 1ns / 1ps

module sevenSegmentDisplay_tb;

    reg         clk;
    reg         reset;
    reg  [31:0] hexValue;
    reg  [7:0]  decimalPointEnable;
    wire [6:0]  segments;
    wire        DP;
    wire [7:0]  AN;

    integer testsRun;
    integer errors;
    integer i;

    sevenSegmentDisplay #(
        .REFRESH_COUNTER_WIDTH(3)
    ) uut (
        .clk(clk),
        .reset(reset),
        .hexValue(hexValue),
        .decimalPointEnable(decimalPointEnable),
        .segments(segments),
        .DP(DP),
        .AN(AN)
    );

    always #5 clk = ~clk;

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

    task waitForDigit;
        input [2:0] digit;
        begin
            @(negedge clk);
            while (uut.digitSelect !== digit)
                @(negedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        hexValue = 32'h0000_0000;
        decimalPointEnable = 8'h00;
        testsRun = 0;
        errors = 0;

        repeat (2) @(posedge clk);
        reset = 1'b0;

        // Exercise every hexadecimal decoder entry on the rightmost digit.
        for (i = 0; i < 16; i = i + 1) begin
            hexValue[3:0] = i;
            waitForDigit(3'd0);
            testsRun = testsRun + 1;
            if (segments !== expectedSegments(i)) begin
                errors = errors + 1;
                $display("FAIL: hexadecimal %h produced segments %b; expected %b.",
                         i[3:0], segments, expectedSegments(i));
            end
        end

        // Check digit order, one-hot active-low anodes, and decimal points.
        hexValue = 32'h0123_4567;
        decimalPointEnable = 8'b0100_0100;

        for (i = 0; i < 8; i = i + 1) begin
            waitForDigit(i);

            testsRun = testsRun + 1;
            if (AN !== ~(8'b0000_0001 << i)) begin
                errors = errors + 1;
                $display("FAIL: digit %0d selected AN=%b.", i, AN);
            end

            testsRun = testsRun + 1;
            if (segments !== expectedSegments(7 - i)) begin
                errors = errors + 1;
                $display("FAIL: digit %0d displayed the wrong nibble.", i);
            end

            testsRun = testsRun + 1;
            if (DP !== ~decimalPointEnable[i]) begin
                errors = errors + 1;
                $display("FAIL: digit %0d decimal-point state is incorrect.", i);
            end
        end

        if (errors == 0)
            $display("PASS: all %0d seven-segment display tests completed successfully.",
                     testsRun);
        else
            $display("FAIL: %0d of %0d seven-segment display tests failed.",
                     errors, testsRun);

        $finish;
    end

endmodule
