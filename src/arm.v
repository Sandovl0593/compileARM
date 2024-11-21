module arm (
    clk, reset,
    InstrF,
    ALUOutM,
    PCF,
    WriteDataM,
    MemWriteM,
    ReadDataM,
    InstrD, InstrE, InstrM, InstrW
);
    input wire clk;
    input wire reset;
    input wire [31:0] InstrF; // <- from imem
    output wire [31:0] PCF; // -> to imem
    output wire [31:0] ALUOutM; // -> to dmem
    output wire [31:0] WriteDataM; // -> to dmem
    input wire [31:0] ReadDataM; // <- from dmem

    wire [1:0] Op;
    wire [5:0] Funct;
    wire [3:0] Rd;
    wire [3:0] CondD;
    wire [3:0] ALUFlags;

    wire StallF, StallD;
    wire PCSrcD;
    wire [1:0] RegSrcD;
    wire [1:0] ImmSrcD;

    wire FlushD, FlushE;
    wire ALUSrcE;
    wire BranchTakenE;
    wire [2:0] ALUControlE;
    wire ALUSrcE;
    wire [1:0] ForwardAE, ForwardBE;

    output wire MemWriteM;   // for now

    wire PCSrcW;
    wire RegWriteW;
    wire MemtoRegW;

    output wire [31:0] InstrD, InstrE, InstrM, InstrW;   // for testbench pipeline

    // hazard undone -> default values:
    assign StallF =1'b0;
       assign StallD = 1'b0;
        assign FlushD = 1'b0;
        assign FlushE = 1'b0;
        assign ForwardAE = 2'b00;
        assign ForwardBE = 2'b00;

    controller cll(
        .clk(clk),
        .reset(reset),
        .Op(InstrD[27:26]),
        .Funct(InstrD[25:20]),
        .Rd(InstrD[15:12]),
        .CondD(CondD),
        .FlushE(FlushE),
        .ALUFlags(ALUFlags),
        .RegSrcD(RegSrcD),
        .ImmSrcD(ImmSrcD),
        .BranchTakenE(BranchTakenE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .MemWriteM(MemWriteM),
        .PCSrcW(PCSrcW),
        .RegWriteW(RegWriteW),
        .MemtoRegW(MemtoRegW)
    );

    datapath dp(
        .clk(clk),
        .reset(reset),
        .RegSrcD(RegSrcD),
        .ImmSrcD(ImmSrcD),
        .ALUSrcE(ALUSrcE),
        .ALUControlE(ALUControlE),
        .BranchTakenE(BranchTakenE),
        .ReadDataM(ReadDataM),
        .PCSrcW(PCSrcW),
        .MemtoRegW(MemtoRegW),
        .RegWriteW(RegWriteW),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .ALUFlags(ALUFlags),
        .PCF(PCF),
        .InstrF(InstrF),
        .ALUOutM(ALUOutM),
        .WriteDataM(WriteDataM),
        // testbench pipeline outputs
        .InstrD(InstrD),
        .InstrE(InstrE),
        .InstrM(InstrM),
        .InstrW(InstrW)
    );

endmodule