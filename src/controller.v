module controller (
    clk, reset,
    // Op, Funct, Rd,
    InstrD,
    // CondD,
    FlushE,
    ALUFlags,
    // outputs
    PCWrPendingF,  // for hazard detection
      RegSrcD,
      ImmSrcD,
        BranchTakenE,
        ALUControlE,
        MemtoRegE,  // for hazard detection
        ALUSrcE,
          MemWriteM,
            PCSrcW, // for hazard detection
            RegWriteM, // for hazard detection
            RegWriteW,
            MemtoRegW
);
    input wire clk;
    input wire reset;
    // input wire [1:0] Op;
    // input wire [5:0] Funct;
    // input wire [3:0] Rd;
    input wire [31:0] InstrD;
    wire [3:0] CondD;
    input wire [3:0] ALUFlags;

    wire PCSrcD;
    wire RegWriteD; 
    wire MemtoRegD;
    wire MemWriteD;
    wire [5:0] ALUControlD;
    wire BranchD;  
    wire ALUSrcD;
    wire [1:0] FlagWriteD;
    output wire [1:0] ImmSrcD;
    output wire [1:0] RegSrcD;

    input wire FlushE;
    wire [3:0] FlagsNextE;

    wire PCSrcE;
    wire RegWriteE;
    output wire MemtoRegE; // Changed for hazard detection
    wire MemWriteE;
    output wire [5:0] ALUControlE;
    wire BranchE;
    output wire ALUSrcE;
    wire [1:0] FlagWriteE;
    wire [3:0] CondE;
    wire [3:0] FlagsE;

    wire PCSrcE_afAnd;
    wire RegWriteE_afAnd;
    wire MemWriteE_afAnd;

    output wire BranchTakenE;

    wire PCSrcM;
    output wire RegWriteM; // Changed for hazard detection
    wire MemtoRegM;
    output wire MemWriteM;

    // for hazard detection
    output wire PCSrcW; // Changed for hazard detection
    output wire RegWriteW;
    output wire MemtoRegW;
    output reg PCWrPendingF;

    assign condD = InstrD[31:28];

    // ------- DECODE ------------
    controlunit cut(
        // .Op(Op), .Funct(Funct), .Rd(Rd),
        .InstrD(InstrD),
        // outputs
        .FlagWriteD(FlagWriteD),
        .PCSrcD(PCSrcD),
        .RegWriteD(RegWriteD),
        .MemWriteD(MemWriteD),
        .MemtoRegD(MemtoRegD),
        .BranchD(BranchD),
        .ALUSrcD(ALUSrcD),
        .ImmSrcD(ImmSrcD),
        .RegSrcD(RegSrcD),
        .ALUControlD(ALUControlD)
    );
    
    // ------- EXECUTE ------------
    floprc #(1) pcsrcEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(PCSrcD),.q(PCSrcE)
    );
    floprc #(1) regwriteEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(RegWriteD),.q(RegWriteE)
    );
    floprc #(1) memtoregEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(MemtoRegD),.q(MemtoRegE)
    );
    floprc #(1) memwriteEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(MemWriteD),.q(MemWriteE)
    );
    floprc #(3) alucontrolEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(ALUControlD),.q(ALUControlE)
    );
    floprc #(1) branchEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(BranchD),.q(BranchE)
    );
    floprc #(1) alusrcEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(ALUSrcD),.q(ALUSrcE)
    );
    floprc #(2) flagwriteEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(FlagWriteD),.q(FlagWriteE)
    );
    floprc #(4) condEreg(.clk(clk), .reset(reset), .clear(FlushE),
        .d(CondD),.q(CondE)
    );
    flopr #(4) flagsEreg(.clk(clk), .reset(reset),
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
        .ALUFlags(ALUFlags),
        // outputs
        .BranchTakenE(BranchTakenE),
        .FlagsNextE(FlagsNextE),
        .PCSrcEOut(PCSrcE_afAnd),
        .RegWriteEOut(RegWriteE_afAnd),
        .MemWriteEOut(MemWriteE_afAnd)
    );

    // ------- MEMORY ------------
    flopr #(1) pcsrcMreg(.clk(clk), .reset(reset),
        .d(PCSrcE_afAnd),.q(PCSrcM)
    );
    flopr #(1) regwriteMreg(.clk(clk), .reset(reset),
        .d(RegWriteE_afAnd),.q(RegWriteM)
    );
    flopr #(1) memtoregMreg(.clk(clk), .reset(reset),
        .d(MemtoRegE),.q(MemtoRegM)
    );
    flopr #(1) memwriteMreg(.clk(clk), .reset(reset),
        .d(MemWriteE_afAnd),.q(MemWriteM)
    );

    // ------- WRITE BACK ------------
    flopr #(1) pcsrcWreg(.clk(clk), .reset(reset),
        .d(PCSrcM),.q(PCSrcW)
    );
    flopr #(1) regwriteWreg(.clk(clk), .reset(reset),
        .d(RegWriteM),.q(RegWriteW)
    );
    flopr #(1) memtoregWreg(.clk(clk), .reset(reset),
        .d(MemtoRegM),.q(MemtoRegW)
    );

    always@(*) begin
        PCWrPendingF = PCSrcD | PCSrcE | PCSrcM;
    end

endmodule