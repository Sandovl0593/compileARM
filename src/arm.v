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

    output wire MemWriteM;

    wire PCSrcW;
    wire RegWriteW;
    wire MemtoRegW;

    output wire [31:0] InstrD, InstrE, InstrM, InstrW;   // for testbench pipeline

    // hazard variables
    wire Match1E_M, Match1E_W, Match2E_M, Match2E_W, Match12D_E;
    wire [1:0] ForwardAE, ForwardBE;
    wire RegWriteM, MemtoRegE; // for hazard detection
    wire PCWrPendingF;

    controller cll(
        .clk(clk),
        .reset(reset),
        .Op(InstrD[27:26]),
        .Funct(InstrD[25:20]),
        .Rd(InstrD[15:12]),
        .CondD(InstrD[31:28]),
        .FlushE(FlushE),
        .ALUFlags(ALUFlags),
        // outputs
        .RegSrcD(RegSrcD),
        .ImmSrcD(ImmSrcD),
        .BranchTakenE(BranchTakenE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .MemWriteM(MemWriteM),
        .PCSrcW(PCSrcW),
        .RegWriteW(RegWriteW),
        .MemtoRegW(MemtoRegW),
        // hazard detection outputs
        .MemtoRegE(MemtoRegE),
        .RegWriteM(RegWriteM),
        .PCWrPendingF(PCWrPendingF)
    );

    // hazard done
    hazardunit hz(
        .Match1E_M(Match1E_M),
        .Match1E_W(Match1E_W),
        .Match2E_M(Match2E_M),
        .Match2E_W(Match2E_W),
        .Match12D_E(Match12D_E),
        .BranchTakenE(BranchTakenE),
        .MemtoRegE(MemtoRegE),
        .RegWriteW(RegWriteW),
        .RegWriteM(RegWriteM),
        // outputs
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        // branch inputs
        .PCWrPendingF(PCWrPendingF),
        .PCSrcW(PCSrcW)
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
        .InstrW(InstrW),
        // hazard detection outputs
        .Match_1E_M(Match1E_M),
        .Match_1E_W(Match1E_W),
        .Match_2E_M(Match2E_M),
        .Match_2E_W(Match2E_W),
        .Match12D_E(Match12D_E)
    );

endmodule