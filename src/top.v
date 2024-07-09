module top (
    clk,
    reset,
    WriteData,
    DataAdr,
    MemWrite,
    PC,
    Instr,
    ReadData,
    ALUFlags
);
    input wire clk;
    input wire reset;
    output wire [31:0] WriteData;
    output wire [31:0] DataAdr;
    output wire MemWrite;
    output wire [31:0] PC;
    output wire [31:0] Instr;
    output wire [31:0] ReadData;
    output wire [3:0] ALUFlags;
    wire [31:0] LastUpdate;

    arm arm(
        .clk(clk),
        .reset(reset),
        .PC(PC),
        .Instr(Instr),
        .MemWrite(MemWrite),
        .ALUResult(DataAdr),
        .WriteData(WriteData),
        .ReadData(LastUpdate),
        .ALUFlags(ALUFLags)
    );
    imem imem(
        .a(PC),
        .rd(Instr)
    );
    dmem dmem(
        .clk(clk),
        .we(MemWrite),
        .a(DataAdr),
        .wd(WriteData),
        .rd(ReadData)
    );
endmodule