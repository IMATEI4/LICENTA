`timescale 1ns / 1ps
`include "isa.v"

module processor(
    input         clk       ,
    input         rst       ,
    //program memory
    output [7:0]  instr_addr,
    input  [31:0] instr     ,
    //data memory
    output [7:0]  addr      ,
    input  [7:0]  din       ,
    output        write     ,
    output [7:0]  dout
);

wire       halt;

// PC
reg  [7:0] pc;
wire       pc_load;
wire [7:0] pc_target;

// Dependencies
wire       fw1;
wire       fw2;

// R1 pipeline register
reg [16:0] r1;
wire [4:0] r1_opcode;
wire [3:0] r1_dest;
wire [3:0] r1_source1;
wire [3:0] r1_source2;
wire [7:0] r1_instr_data;

// R2 pipeline register wires
reg  [4:0] r2_opcode;
reg  [3:0] r2_dest;
reg  [7:0] r2_operand1;
reg  [7:0] r2_operand2;

wire [7:0] operand1;
wire [7:0] operand2;
wire [7:0] rdata1;
wire [7:0] rdata2;

//ALU wires
wire [7:0] alu_result;
wire [7:0] result;
//regs wires
reg        regs_wen;

// opcode == RET
wire [7:0] r1_pc    ;
wire [7:0] ret_pc   ;
wire [7:0] pc_target;

//--------------------------------PC--------------------------------
always @(posedge clk) begin
    if(rst)
        pc <= 0;
    else if(halt)
        pc <= pc;
    else if(pc_load)
        pc <= pc_target;
    else 
        pc <= pc + 1;
end
//------------------------------------------------------------------

//-------------------------------FETCH------------------------------
assign instr_addr = pc;
// Initialization of register pipeline R1
always @(posedge clk) begin
    if(rst)
        r1 <= 0;
    else if(halt)
        r1 <= r1;
    else if(pc_load)
        r1 <= 0; // If opcode was JUMP the next instruction in FETCH will be replaced with NOP
    else
        r1 <= instr[16:0];
end

assign r1_pc = pc - 1;
//--------------------------------------------------------------------
//------------------------------READ---------------------------------

//regs initialization
regs regs(
    .clk  (clk          ),
    // portul de scriere
    .wen  (regs_wen     ),
    .waddr(r2_dest      ),
    .wdata(result       ),
    // porturile de citire
    .raddr1(r1_source1   ),
    .raddr2(r1_source2   ),
    .rdata1(rdata1      ),
    .rdata2(rdata2      )
);
assign operand1 = fw1 ? result : rdata1;

assign r1_opcode     = r1[16:12]; // First byte of instr is opcode
assign r1_dest       = r1[11: 8]; // Second byte of instr is dest
assign r1_source1    = r1[ 7: 4]; // Third byte of instr is the first source
assign r1_source2    = r1[ 3: 0]; // Fourth byte of instr is the second source
assign r1_instr_data = r1[ 7: 0]; // Loading a constant into a register
assign operand2 = ((r1_opcode == `LOADC) || (r1_opcode == `JMP)) ? r1_instr_data : fw2 ? result : rdata2; // LOADC or JMP
//--------------------------------------------------------------------

//----------------------------Execute--------------------------------
//  Register R2 pipeline
always @(posedge clk) begin
    if(rst) begin
        // On reset all values go back to 0
        r2_opcode     <= 5'b0_0000;
        r2_dest       <= 4'b0000;
        r2_operand1   <= 4'b0000;
        r2_operand2   <= 4'b0000;
    end
    else if(halt) begin
        // On halt the destination, op1 and op2 can have any value
        r2_opcode     <= 5'b1_1111;
        r2_dest       <= 4'b1111;
//        r2_operand1   <= 0;
//        r2_operand2   <= 0;
    end
    else if(pc_load) begin
        // If the opcode was JUMP the next instruction from READ will be replaced by NOP
        r2_opcode     <= 5'b0_0000;
        r2_dest       <= 4'b0000;
        r2_operand1   <= 4'b0000;
        r2_operand2   <= 4'b0000;
    end
    else begin
        // Passing from register pipeline R1 to register pipeline R2
        r2_opcode     <= r1_opcode;
        r2_dest       <= r1_dest ;
        r2_operand1   <= operand1;
        r2_operand2   <= operand2;
    end
end

assign fw1 = (r2_dest == r1_source1) & regs_wen & ((r1_opcode == `ADD) | (r1_opcode == `SUB) | (r1_opcode == `LOAD) | (r1_opcode == `STORE));
assign fw2 = (r2_dest == r1_source2) & regs_wen & ((r1_opcode == `ADD) | (r1_opcode == `SUB) | (r1_opcode == `LOAD) | (r1_opcode == `STORE));
assign pc_load   = (r2_opcode == `JMP) | (r2_opcode == `RET);
assign pc_target = (r2_opcode == `RET) ? ret_pc : r2_operand2;
assign ret_pc    = r2_opcode == `JMP ? r1_pc : ret_pc;
//-------------------------------------------------------------------
//-------------------ALU and mem wires-------------------------------
assign addr   = r2_operand1;
assign dout   = r2_operand2;
assign write  = (r2_opcode == `STORE) ? 1 : 0;
assign result = (r2_opcode == `LOAD ) ? din : alu_result;

always @(*) begin
    case(r2_opcode)
    `ADD  :  regs_wen = 1; // ADD
    `SUB  :  regs_wen = 1; // SUB
    `LOADC:  regs_wen = 1; // LOADC
    `LOAD :  regs_wen = 1; // LOAD
    default: regs_wen = 0; // default
    endcase
end
assign halt = r2_opcode == `HALT; // halt is 1 if halt operation take place
//-------------------------------------------------------------------

//ALU initialization
alu alu(
    .opcode  (r2_opcode  ),
    .operand1(r2_operand1),
    .operand2(r2_operand2),
    .result  (alu_result )
);
endmodule