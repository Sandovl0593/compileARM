module arm (
    clk, reset,
    InstrF,
    ALUOutM,
    PCF,
    WriteDataM,
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

    reg StallF,  StallD;
    wire PCSrcD;
    wire RegSrcD;
    wire ImmSrcD;

    reg FlushD, FlushE;
    wire ALUSrcE;
    wire BranchTakenE;
    wire [2:0] ALUControlE;
    wire ALUSrcE;
    wire BranchTakenE;
    reg ForwardAE, ForwardBE;

    wire MemWriteM;   // for now
    wire ReadDataM;

    wire PCSrcW;
    wire RegWriteW;
    wire MemtoRegW;

    output wire [31:0] InstrD, InstrE, InstrM, InstrW;   // for testbench pipeline

    controller cll(
        .clk(clk),
        .reset(reset),
        .Op(Op),
        .Funct(Funct),
        .Rd(Rd),
        .CondD(CondD),
        .FlushE(FlushE),
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

    // hazard incomplete -> default values:
    always @(*) begin
        StallF = 0;
        StallD = 0;
        FlushD = 0;
        FlushE = 0;
        ForwardAE = 2'b00;
        ForwardBE = 2'b00;
    end

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