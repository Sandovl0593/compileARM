module top (
    clk,
    reset,
    WriteData,
    DataAdr, // ALUResult from datapath
    MemWrite,
    PC,
    Instr,
    ReadData
);
    input wire clk;
    input wire reset;

    output wire [31:0] WriteData;
    output wire [31:0] DataAdr;
    output wire MemWrite;
    output wire [31:0] PC;
    output wire [31:0] Instr;
    output wire [31:0] ReadData;

    arm arm(
        // inputs
        .clk(clk),
        .reset(reset),
        .Instr(Instr),
        .ReadData(ReadData),
        // outputs
        .PC(PC),
        .MemWrite(MemWrite),
        .WriteData(WriteData),
        .ALUResult(DataAdr)
    );
    imem imem(
        .a(PC),
        .rd(Instr)
    );
    dmem dmem(
        // inputs
        .clk(clk),
        .we(MemWrite),
        .a(DataAdr),
        .wd(WriteData),
        // outputs
        .rd(ReadData)
    );
endmodule