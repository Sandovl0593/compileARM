module arm (
    clk,
    reset,
    PC,
    Instr,
    MemWrite,
    ALUResult,
    WriteData,
    ReadData,
    ALUFlags,
);
    input wire clk;
    input wire reset;
    input wire [31:0] Instr;

    output wire [31:0] PC;
    output wire MemWrite;
    output wire [31:0] ALUResult;
    output wire [31:0] WriteData;

    input wire [31:0] ReadData;

    output wire [3:0] ALUFlags;
    wire RegWrite;
    wire ALUSrc;
    wire MemtoReg;
    wire PCSrc;
    wire [1:0] RegSrc;
    wire [1:0] ImmSrc;
    wire [2:0] ALUControl;

    controller c(
        // inputs
        .clk(clk),
        .reset(reset),
        .Instr(Instr[31:12]),
        .ALUFlags(ALUFlags),
        // outputs
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc)
    );
    datapath dp(
        // inputs
        .clk(clk),
        .reset(reset),
        .RegSrc(RegSrc),
        .RegWrite(RegWrite),
        .ImmSrc(ImmSrc),
        .ALUSrc(ALUSrc),
        .ALUControl(ALUControl),
        .MemtoReg(MemtoReg),
        .PCSrc(PCSrc),
        .Instr(Instr),
        .ReadData(ReadData)
        // outputs
        .ALUFlags(ALUFlags),
        .PC(PC),
        .ALUResult(ALUResult),
        .WriteData(WriteData),
    );
endmodule