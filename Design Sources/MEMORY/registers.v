`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Noah Arnold
// 
// Create Date: 08/09/2026 06:38:00 PM
// Design Name: Register File
// Module Name: registers
// Project Name: NOVA
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module registers(
    
    input clk,
    input reset,
    input writeEnable, // 1 - Write on Rising Clock Edge
    
    input [2:0] readAddressA,
    input [2:0] readAddressB,
    input [2:0] writeAddress,
    
    input [7:0] writeData,
    
    output wire [7:0] readDataA,
    output wire [7:0] readDataB

    );
    
    // Create and initialize the eight registers 
    //  [8 Bits] register [8 Instances]
    reg [7:0] registers [0:7];
    integer i;

    // Always have registers being read, via combinatorial logic  
    assign readDataA = registers[readAddressA];
    assign readDataB = registers[readAddressB];
    
    // Perform Reset and/or Write Statements
    always @ (posedge clk) begin
        
        // Assign zero to all registers on reset
        if (reset) begin            
            for ( i = 0; i < 8; i = i +1 ) begin
                registers[i] <= 8'b0000_0000;
            end          
        end
        else if (writeEnable) begin
            
            registers[writeAddress] <= writeData;
            
        end
        
    end


endmodule
