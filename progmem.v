`include "isa.v"
`timescale 1ns / 1ps

module progmem(
    input  [7:0]  addr    ,
    output [31:0] data_out
);

reg [15:0] memory [0:255]; 

assign data_out = memory[addr];

// -----------------------------PIPELINE FORWARD TESTING----------------------------
//initial begi
//    memory[00] = 16'b1000_0000_1111_1111; // LOADC R0 #25
//    memory[01] = 16'b1000_0001_1111_1110; // LOADC R1 #25
//    memory[02] = 16'b1000_0010_1111_1101; // LOADC R2 #25
//    memory[03] = 16'b1001_0100_0000_0000; // LOAD  R4 R
//    memory[04] = 16'b1001_0101_0001_0000; // LOAD  R5 R
//    //memory[05] = 16'b0000_0000_0000_0000; // NO
//    memory[05] = 16'b0001_0110_0101_0100; // ADD   R6 R5 R
//    //memory[07] = 16'b0000_0000_0000_0000; // NO
//    memory[06] = 16'b1010_0000_0010_0110; // STORE R2 R
//    memory[07] = 16'b1111_1111_1111_1111; // HALT   
//en
// ----------------------------------------------------------------------------------

// ---------------------------------JMP INSTR TESTING--------------------------------
//initial begin
//    memory[00] = {`LOADC, `R0, 8'b1111_1111}; // LOADC R0 #255
//    memory[01] = {`LOADC, `R1, 8'b1111_1110}; // LOADC R1 #254
//    memory[02] = {`LOADC, `R2, 8'b1111_1101}; // LOADC R2 #253
//    memory[03] = {`JMP, 12'b0000_0000_0111 }; // JMP #7
//    memory[04] = {`ADD, `R6, `R5, `R4};       // ADD   R6 R5 R4
//    memory[05] = {`STORE, 4'b0000, `R2, `R6}; // STORE R2 R6
//    memory[06] = {`HALT, 12'b1111_1111_1111}; // HALT
//    memory[07] = {`LOAD, `R4, `R0, 4'b0000};  // LOAD  R4 R0
//    memory[08] = {`LOAD, `R5, `R1, 4'b0000};  // LOAD  R5 R1
//    memory[09] = {`JMP, 12'b0000_0000_0100};  // JMP #4
//end
// ----------------------------------------------------------------------------------

// ---------------------------------RET INSTR TESTING--------------------------------
initial begin
    memory[00] = {`RESERVED, `LOADC, `R0, 8'b1111_1111}; // LOADC R0 #255
    memory[01] = {`RESERVED, `JMP, 12'b0000_0000_1010 }; // JMP #10
    memory[02] = {`RESERVED, `LOADC, `R2, 8'b1111_1101}; // LOADC R2 #253
    memory[03] = {`RESERVED, `JMP, 12'b0000_0000_0111 }; // JMP #7
    memory[04] = {`RESERVED, `ADD, `R6, `R5, `R4      }; // ADD   R6 R5 R4
    memory[05] = {`RESERVED, `STORE, 4'b0000, `R2, `R6}; // STORE R2 R6
    memory[06] = {`RESERVED, `HALT, 12'b1111_1111_1111}; // HALT
    memory[07] = {`RESERVED, `LOAD, `R4, `R0, 4'b0000 }; // LOAD  R4 R0
    memory[08] = {`RESERVED, `LOAD, `R5, `R1, 4'b0000 }; // LOAD  R5 R1
    memory[09] = {`RESERVED, `RET, `NOPDUMMY          }; // RET
    memory[10] = {`RESERVED, `LOADC, `R1, 8'b1111_1110}; // LOADC R1 #254
    memory[11] = {`RESERVED, `RET, `NOPDUMMY          }; // RET  
end
// ----------------------------------------------------------------------------------


endmodule