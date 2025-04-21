//ALU opcodes

`define NOP   5'b0_0000
`define ADD   5'b0_0001
`define SUB   5'b0_0010
`define AND   5'b0_0011
`define CMP   5'b0_0100
`define LOADC 5'b0_1000
`define LOAD  5'b0_1001
`define STORE 5'b0_1010
`define JMP   5'b0_1100
`define RET   5'b0_1101
`define HALT  5'b0_1111
`define NOPDUMMY 12'b0000_0000_0000
`define RESERVED 15'b000_0000_0000_0000



// Registers
`define  R0 4'b0000
`define  R1 4'b0001
`define  R2 4'b0010
`define  R3 4'b0011
`define  R4 4'b0100
`define  R5 4'b0101
`define  R6 4'b0110
`define  R7 4'b0111

`define  R8 4'b1000
`define  R9 4'b1001
`define R10 4'b1010
`define R11 4'b1011
`define R12 4'b1100
`define R13 4'b1101
`define R14 4'b1110
`define R15 4'b1111