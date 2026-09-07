`timescale 1ns / 1ps

module dataMemory_tb;

    reg        clk;
    reg        writeEnable;
    reg  [7:0] address;
    reg  [7:0] writeData;

    wire [7:0] readData;

    integer testsRun;
    integer errors;

    dataMemory uut (
        .clk(clk),
        .writeEnable(writeEnable),
        .address(address),
        .writeData(writeData),
        .readData(readData)
    );

    always #5 clk = ~clk;

    task checkRead;
        input [7:0] testAddress;
        input [7:0] expectedData;
        begin
            address = testAddress;
            #1;
            testsRun = testsRun + 1;

            if (readData !== expectedData) begin
                errors = errors + 1;
                $display("FAIL test %0d: address=%h data=%h expected=%h",
                         testsRun, testAddress, readData, expectedData);
            end
        end
    endtask

    task writeLocation;
        input [7:0] testAddress;
        input [7:0] testData;
        begin
            @(negedge clk);
            writeEnable = 1'b1;
            address = testAddress;
            writeData = testData;
            @(posedge clk);
            #1;
            writeEnable = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        writeEnable = 1'b0;
        address = 8'h00;
        writeData = 8'h00;
        testsRun = 0;
        errors = 0;

        // A few representative locations must begin at zero.
        checkRead(8'h00, 8'h00);
        checkRead(8'h5A, 8'h00);
        checkRead(8'hFF, 8'h00);

        // A proposed write must not appear before the rising clock edge.
        @(negedge clk);
        writeEnable = 1'b1;
        address = 8'h20;
        writeData = 8'hA5;
        #1;
        checkRead(8'h20, 8'h00);
        @(posedge clk);
        #1;
        writeEnable = 1'b0;
        checkRead(8'h20, 8'hA5);

        // Different addresses must store independent values.
        writeLocation(8'h21, 8'h3C);
        writeLocation(8'hFE, 8'h7E);
        checkRead(8'h20, 8'hA5);
        checkRead(8'h21, 8'h3C);
        checkRead(8'hFE, 8'h7E);

        // A disabled write must preserve the existing value.
        @(negedge clk);
        writeEnable = 1'b0;
        address = 8'h21;
        writeData = 8'hFF;
        @(posedge clk);
        #1;
        checkRead(8'h21, 8'h3C);

        // Changing only the address must immediately select another location.
        checkRead(8'h20, 8'hA5);

        if (errors == 0)
            $display("PASS: all %0d data-memory tests completed successfully.", testsRun);
        else
            $display("FAIL: %0d of %0d data-memory tests failed.", errors, testsRun);

        $finish;
    end

endmodule
