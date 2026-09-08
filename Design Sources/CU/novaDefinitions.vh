`ifndef NOVA_DEFINITIONS_VH
`define NOVA_DEFINITIONS_VH

// Sixteen-bit CPU instruction opcodes: instruction[15:12]
`define NOVA_OPCODE_NOP   4'h0
`define NOVA_OPCODE_LDI   4'h1
`define NOVA_OPCODE_MOV   4'h2
`define NOVA_OPCODE_ADD   4'h3
`define NOVA_OPCODE_SUB   4'h4
`define NOVA_OPCODE_AND   4'h5
`define NOVA_OPCODE_OR    4'h6
`define NOVA_OPCODE_XOR   4'h7
`define NOVA_OPCODE_LD    4'h8
`define NOVA_OPCODE_ST    4'h9
`define NOVA_OPCODE_JMP   4'hA
`define NOVA_OPCODE_JZ    4'hB
`define NOVA_OPCODE_JC    4'hC
`define NOVA_OPCODE_SHL   4'hD
`define NOVA_OPCODE_SHR   4'hE
`define NOVA_OPCODE_HALT  4'hF

// Internal three-bit ALU operation selections
`define NOVA_ALU_ADD      3'b000
`define NOVA_ALU_SUB      3'b001
`define NOVA_ALU_AND      3'b010
`define NOVA_ALU_OR       3'b011
`define NOVA_ALU_XOR      3'b100
`define NOVA_ALU_SHL      3'b101
`define NOVA_ALU_SHR      3'b110
`define NOVA_ALU_PASS_B   3'b111

// Register writeback multiplexer selections
`define NOVA_WB_ALU       2'b00
`define NOVA_WB_IMMEDIATE 2'b01
`define NOVA_WB_MEMORY    2'b10
`define NOVA_WB_REGISTER  2'b11

// Multicycle control-unit states
`define NOVA_STATE_FETCH      3'd0
`define NOVA_STATE_DECODE     3'd1
`define NOVA_STATE_EXECUTE    3'd2
`define NOVA_STATE_WRITEBACK  3'd3
`define NOVA_STATE_HALT       3'd4

`endif
