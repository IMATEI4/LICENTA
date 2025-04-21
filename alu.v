`timescale 1ns / 1ps
`include "isa.v"

module alu(
    input      [4:0] opcode,
    input      [7:0] operand1,
    input      [7:0] operand2,
    output reg [7:0] result,
    output reg [2:0] flags
);

wire SF;

// result
always @(*) begin
    case(opcode)
        `NOP:   result = 0;
        `ADD:   result = operand1 + operand2;
        `SUB:   result = operand1 - operand2;
        `LOADC: result = operand2;
        `LOAD:  result = operand2;
        `STORE: result = operand2;
    default: result = 8'd0;
    endcase
end

assign SF = result[7];

// flags
always @(*) begin
    case(opcode)
        `CMP:   begin
            flags[0] = (operand1 == operand2) ? 1 : 0; // ZF(zero flag) set if operands are equal
            flags[1] = (operand1 < operand2) ? 1 : 0;  // CF(carry flag) set if first operand is lower than the second operand
            flags[2] = SF;                             // SF(sign flag) set for 2 complent - indicates signed numbers
         end
         default flags = flags;
    endcase
end
endmodule