`timescale 1ns / 1ps

module registers_tb;

    reg        clk;
    reg        reset;
    reg        writeEnable;
    reg  [2:0] readAddressA;
    reg  [2:0] readAddressB;
    reg  [2:0] writeAddress;
    reg  [7:0] writeData;

    wire [7:0] readDataA;
    wire [7:0] readDataB;

    integer testsRun;
    integer errors;
    integer i;

    registers uut (
        .clk(clk),
        .reset(reset),
        .writeEnable(writeEnable),
        .readAddressA(readAddressA),
        .readAddressB(readAddressB),
        .writeAddress(writeAddress),
        .writeData(writeData),
        .readDataA(readDataA),
        .readDataB(readDataB)
    );

    always #5 clk = ~clk;

    task expectReads;
        input [2:0] addressA;
        input [7:0] expectedA;
        input [2:0] addressB;
        input [7:0] expectedB;
        begin
            readAddressA = addressA;
            readAddressB = addressB;
            #1;

            testsRun = testsRun + 1;
            if ((readDataA !== expectedA) || (readDataB !== expectedB)) begin
                errors = errors + 1;
                $display("FAIL test %0d: R%0d=%h expected %h | R%0d=%h expected %h",
                         testsRun, addressA, readDataA, expectedA,
                         addressB, readDataB, expectedB);
            end
        end
    endtask

    task writeRegister;
        input [2:0] address;
        input [7:0] value;
        begin
            @(negedge clk);
            writeEnable = 1'b1;
            writeAddress = address;
            writeData = value;
            @(posedge clk);
            #1;
            writeEnable = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;
        writeEnable = 1'b0;
        readAddressA = 3'd0;
        readAddressB = 3'd0;
        writeAddress = 3'd0;
        writeData = 8'h00;
        testsRun = 0;
        errors = 0;

        // The reset is synchronous, so it takes effect on a rising edge.
        @(posedge clk);
        #1;
        reset = 1'b0;

        // Verify that reset cleared every register.
        for (i = 0; i < 8; i = i + 2)
            expectReads(i, 8'h00, i + 1, 8'h00);

        // Write a unique value to every register, then verify both read ports.
        for (i = 0; i < 8; i = i + 1)
            writeRegister(i, 8'h10 + i);

        for (i = 0; i < 8; i = i + 2)
            expectReads(i, 8'h10 + i, i + 1, 8'h11 + i);

        // A write must not appear before the active clock edge.
        @(negedge clk);
        writeEnable = 1'b1;
        writeAddress = 3'd2;
        writeData = 8'hA5;
        #1;
        expectReads(3'd2, 8'h12, 3'd6, 8'h16);
        @(posedge clk);
        #1;
        writeEnable = 1'b0;
        expectReads(3'd2, 8'hA5, 3'd6, 8'h16);

        // A disabled write must preserve the old value.
        @(negedge clk);
        writeEnable = 1'b0;
        writeAddress = 3'd2;
        writeData = 8'hFF;
        @(posedge clk);
        #1;
        expectReads(3'd2, 8'hA5, 3'd6, 8'h16);

        // Because the read ports are asynchronous, a completed write is
        // immediately visible when its address is selected.
        writeRegister(3'd4, 8'h7E);
        expectReads(3'd4, 8'h7E, 3'd4, 8'h7E);

        // A later synchronous reset must clear previously written values.
        @(negedge clk);
        reset = 1'b1;
        @(posedge clk);
        #1;
        reset = 1'b0;
        expectReads(3'd2, 8'h00, 3'd6, 8'h00);
        expectReads(3'd4, 8'h00, 3'd0, 8'h00);

        if (errors == 0)
            $display("PASS: all %0d register-file tests completed successfully.", testsRun);
        else
            $display("FAIL: %0d of %0d register-file tests failed.", errors, testsRun);

        $finish;
    end

endmodule
