// for Ikarus
// `include "imem.v"
// `include "arm.v"
// `include "dmem.v"

module top (
    input wire clk,
    input wire reset,
    output wire [31:0] WriteData,
    output wire [31:0] DataAdr,
    output wire MemWrite
);
    wire [31:0] PC;
    wire [31:0] Instr;
    wire [31:0] ReadData;

    arm arm(
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .ReadData(ReadData),
        
        .PC(PC), // out all wire
        .MemWrite(MemWrite),
        .ALUResult(DataAdr),
        .WriteData(WriteData)
    );
    imem imem(
        .a(PC),
        .rd(Instr) // out wire
    );
    dmem dmem(
        .clk(clk),
        .we(MemWrite),
        .a(DataAdr),
        .wd(WriteData),
        .rd(ReadData) // out wire
    );
endmodule