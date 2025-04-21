`timescale 1ns / 1ps

module datamem(
    input        clk,
    input        write,
    input  [7:0] addr,
    input  [7:0] din,
    output [7:0] dout
);

reg [7:0] memory [0:255];
// reading from memory
assign dout = memory[addr];
// writing in memory - syncronous writing
always @(posedge clk) if(write) memory[addr] <= din;

// initial datas
initial begin
    memory[254] = 17;
    memory[255] = 23;
end

endmodule