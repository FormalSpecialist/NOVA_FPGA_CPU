`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Engineer: Noah Arnold
//
// Design Name: Data Memory
// Module Name: dataMemory
// Project Name: NOVA
// Description:
//   A 256-location by 8-bit data memory. Reads are combinational, while writes
//   occur only on a rising clock edge when writeEnable is asserted.
//////////////////////////////////////////////////////////////////////////////////

module dataMemory (
    input            clk,
    input            writeEnable,
    input      [7:0] address,
    input      [7:0] writeData,

    output     [7:0] readData
);

    reg [7:0] memory [0:255];
    integer i;

    // Initialize RAM for a deterministic FPGA startup and simulation. CPU reset
    // does not clear data memory; doing so would require clearing every location.
    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 8'h00;
    end

    // The selected memory location is continuously visible at the read port.
    assign readData = memory[address];

    // Stored data changes only on the active clock edge.
    always @(posedge clk) begin
        if (writeEnable)
            memory[address] <= writeData;
    end

endmodule
