`timescale 1ns / 1ps

module regs(
    input        clk,
    // Writing port
    input        wen,
    input  [3:0] waddr,
    input  [7:0] wdata,
    // Reading port
    input  [3:0] raddr1,
    input  [3:0] raddr2,
    output [7:0] rdata1,
    output [7:0] rdata2
);

reg [7:0] registers [0:15]; // A set of 16 registers, each 8 bits wide

// Writing port
always @(posedge clk) begin
    if(wen) registers[waddr] <= wdata; // syncronous writing after clk in registers
end

// First port for reading
assign rdata1 = registers[raddr1]; // rdata1 output is the value from the register addressed by raddr1
// Second port for reading
assign rdata2 = registers[raddr2]; // rdata2 output is the value from the register addressed by raddr2

endmodule