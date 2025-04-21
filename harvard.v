`timescale 1ns / 1ps

module harvard(
    input clk,
    input rst
);

//program memory
wire  [7:0] prog_addr;
wire [31:0] prog_out ;
//data memory
wire [7:0] mem_addr,mem_in,mem_out; 
wire wen;
    
processor CPU(
    .clk       (clk      ),
    .rst       (rst      ),
    .instr_addr(prog_addr),
    .instr     (prog_out ),
    .addr      (mem_addr ),
    .din       (mem_out  ),
    .write     (wen      ),
    .dout      (mem_in   )
);

datamem datamem(
    .clk(clk),
    .write(wen),
    .addr(mem_addr),
    .din(mem_in),
    .dout(mem_out)    
);

progmem progmem(
    .addr(prog_addr),
    .data_out(prog_out)
);

stack stack(
    .clk(clk),
    .rst(rst)
);
endmodule
