module controller (
    clk, reset,
    Op, Funct, Rd,
    CondD,
    FlushE,
    // outputs
    RegSrcD,
    ImmSrcD,
      BranchTakenE,
      ALUControlE,
      ALUSrcE,
        MemWriteM,
          PCSrcW,
          RegWriteW,
          MemtoRegW
);
    input wire clk;
    input wire reset;
    input wire [1:0] Op;
    input wire [5:0] Funct;
    input wire [3:0] Rd;
    input wire [3:0] CondD;

    wire PCSrcD;
    wire RegWriteD; 
    wire MemtoRegD;
    wire MemWriteD;
    wire [2:0] ALUControlD;
    wire BranchD;  
    wire ALUSrcD;
    wire [1:0] FlagWwiteD;
    output wire [1:0] ImmSrcD;
    output wire [1:0] RegSrcD;

    input wire FlushE;
    reg [3:0] FlagsNextE;

    wire PCSrcE;
    wire RegWriteE;
    wire MemtoRegE;
    wire MemWriteE;
    output wire [2:0] ALUControlE;
    wire BranchE;
    output wire ALUSrcE;
    wire [1:0] FlagWriteE;
    wire [3:0] CondE;
    reg [3:0] FlagsE;

    wire PCSrcE_afAnd;
    wire RegWriteE_afAnd;
    wire MemWriteE_afAnd;

    output wire BranchTakenE;

    wire PCSrcM;
    wire RegWriteM;
    wire MemtoRegM;
    output wire MemWriteM;

    output wire PCSrcW;
    output wire RegWriteW;
    output wire MemtoRegW;

    // ------- DECODE ------------
    controlunit cut(
        .Op(Op), .Funct(Funct), .Rd(Rd),
        // outputs
        .FlagWriteD(FlagWwiteD),
        .PCSrcD(PCSrcD),
        .RegWriteD(RegWriteD),
        .MemWriteD(MemWriteD),
        .MemtoRegD(MemtoRegD),
        .ALUSrcD(ALUSrcD),
        .ImmSrcD(ImmSrcD),
        .RegSrcD(RegSrcD),
        .ALUControlD(ALUControlD)
    );
    
    // ------- EXECUTE ------------
    floprc pcsrcEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(PCSrcD),.q(PCSrcE)
    );
    floprc regwriteEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(RegWriteD),.q(RegWriteE)
    );
    floprc memtoregEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(MemtoRegD),.q(MemtoRegE)
    );
    floprc memwriteEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(MemWriteD),.q(MemWriteE)
    );
    floprc alucontrolEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(ALUControlD),.q(ALUControlE)
    );
    floprc branchEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(BranchD),.q(BranchE)
    );
    floprc alusrcEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(ALUSrcD),.q(ALUSrcE)
    );
    floprc flagwriteEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(FlagWwiteD),.q(FlagWriteE)
    );
    floprc condEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(CondD),.q(CondE)
    );
    flopr flagsEreg(.clk(clk), .reset(reset),
        .d(FlagsNextE),.q(FlagsE)
    );
    
    condlogic cl(
        // inputs
        .PCSrcE(PCSrcE),
        .RegWriteE(RegWriteE),
        .MemtoRegE(MemtoRegE),
        .MemWriteE(MemWriteE),
        .BranchE(BranchE),
        .FlagWriteE(FlagWriteE),
        .CondE(CondE),
        .FlagsE(FlagsE),
        // outputs
        .BranchTakenE(BranchTakenE),
        .FlagsNextE(FlagsNextE),
        .PCSrcEOut(PCSrcE_afAnd),
        .RegWriteEOut(RegWriteE_afAnd),
        .MemWriteEOut(MemWriteE_afAnd)
    );

    // ------- MEMORY ------------
    flopr pcsrcMreg(.clk(clk), .reset(reset),
        .d(PCSrcE_afAnd),.q(PCSrcM)
    );
    flopr regwriteMreg(.clk(clk), .reset(reset),
        .d(RegWriteE_afAnd),.q(RegWriteM)
    );
    flopr memtoregMreg(.clk(clk), .reset(reset),
        .d(MemtoRegE),.q(MemtoRegM)
    );
    flopr memwriteMreg(.clk(clk), .reset(reset),
        .d(MemWriteE_afAnd),.q(MemWriteM)
    );

    // ------- WRITE BACK ------------
    flopr pcsrcWreg(.clk(clk), .reset(reset),
        .d(PCSrcM),.q(PCSrcW)
    );
    flopr regwriteWreg(.clk(clk), .reset(reset),
        .d(RegWriteM),.q(RegWriteW)
    );
    flopr memtoregWreg(.clk(clk), .reset(reset),
        .d(MemtoRegM),.q(MemtoRegW)
    );

    // Proximately: Hazard PREDICTION
    // TO DO
endmodule