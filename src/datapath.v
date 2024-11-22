module datapath (
    clk,
    reset,
    RegSrcD,
    ImmSrcD,
      ALUSrcE,
      ALUControlE,
      BranchTakenE,
        ReadDataM,    // out from Dmem -> input to rdWreg flop
          PCSrcW,
          MemtoRegW,
          RegWriteW,
    // hazard inputs
    StallF,
      StallD,
      FlushD,
        FlushE,
        ForwardAE,
        ForwardBE,
    // outputs
    ALUFlags,
    PCF,
    InstrF,         // output testbench Instr in Fetch
      ALUOutM,
      WriteDataM,

    InstrD,         // output testbench Instr in Decode
    InstrE,         // output testbench Instr in Execute
    InstrM,         // output testbench Instr in Memory
    InstrW,         // output testbench Instr in Writeback

    // hazard detection
    Match_1E_M, Match_1E_W, 
    Match_2E_M, Match_2E_W,
    Match_12D_E
);
    input wire clk;
    input wire reset;
    input wire [1:0] RegSrcD;
    input wire RegWriteW;
    input wire [1:0] ImmSrcD;
    input wire ALUSrcE;
    input wire [2:0] ALUControlE;
    input wire MemtoRegW;
    input wire PCSrcW;

    output wire [3:0] ALUFlags;

    output wire [31:0] PCF;
    input wire [31:0] InstrF;     // output Fetch
    wire [31:0] PCNextF;
    wire [31:0] PCDefNextF;
    wire [31:0] PCPlus4F;
    
    input wire StallF, StallD, FlushD, FlushE;
    input wire [1:0] ForwardAE, ForwardBE;

    output wire [31:0] InstrD;    // output Decode
    wire [31:0] PCPlus8D;
    wire [31:0] ExtImmD;
    wire [3:0] RA1D, RA2D;
    wire [31:0] RD1D, RD2D;

    output wire [31:0] InstrE;    // output Execute
    input wire BranchTakenE;
    wire [31:0] SrcAE;
    wire [31:0] SrcBE;
    wire [31:0] ExtImmE;
    wire [31:0] ALUResultE;
    wire [31:0] WriteDataE;
    wire [3:0] WA3E;
    wire [31:0] RD1E, RD2E;
    wire [3:0] RA1E, RA2E; // for hazard detection

    output wire [31:0] InstrM;    // output Memory
    wire [3:0] WA3M;
    output wire [31:0] ALUOutM;
    input wire [31:0] ReadDataM;
    output wire [31:0] WriteDataM;

    output wire [31:0] InstrW;    // output Writeback
    wire [3:0] WA3W;
    wire [31:0] ALUOutW;
    wire [31:0] ReadDataW;

    wire [31:0] ResultW;

    // hazard detection
    input wire Match_1E_M, Match_1E_W;
    input wire Match_2E_M, Match_2E_W, Match_12D_E;

    mux2 #(32) pcmux(
        .d0(PCPlus4F),
        .d1(ResultW),
        .s(PCSrcW),
        .y(PCNextF)
    );
    mux2 #(32) pcdefmux(
        .d0(PCNextF),
        .d1(ALUResultE),
        .s(BranchTakenE),
        .y(PCDefNextF)
    );

    // ------- FETCH ------------
    flopenr #(32) pcreg(
        .clk(clk), .reset(reset), .en(~StallF),
        .d(PCDefNextF), .q(PCF)
    );
    adder #(32) pcadd1(
        .a(PCF),
        .b(32'b100),
        .y(PCPlus4F)
    );

    // out PCF -> input InstrF from imem    //  -> output InstrF to view

    assign PCPlus8D = PCPlus4F; // bottom instDreg flop

    // ------- DECODE ------------
    flopenrc #(32) instDreg(
        .clk(clk), .reset(reset),
        .en(~StallD), .clear(FlushD),
        .d(InstrF), .q(InstrD)           // -> output InstrD to view
    );

    mux2 #(4) ra1mux(
        .d0(InstrD[19:16]),
        .d1(4'b1111),
        .s(RegSrcD[0]),
        .y(RA1D)
    );
    mux2 #(4) ra2mux(
        .d0(InstrD[3:0]),
        .d1(InstrD[15:12]),
        .s(RegSrcD[1]),
        .y(RA2D)
    );
    regfile rf(
        // inputs
        .clk(clk),
        .we3(RegWriteW),
        .ra1(RA1D),
        .ra2(RA2D),
        .wa3(WA3W),
        .wd3(ResultW),
        .r15(PCPlus8D),
        // outputs
        .rd1(RD1D),
        .rd2(RD2D)
    );

    // ------- EXECUTE ------------
    floprc #(32) instEreg(
        .clk(clk), .reset(reset), .clear(FlushE),
        .d(InstrD), .q(InstrE)                // -> output InstrE to view
    );
    // --- hazard detection
    flopr #(4) ra1Ereg(
        .clk(clk), .reset(reset),
        .d(RA1D), .q(RA1E)
    );
    flopr #(4) ra2Ereg(
        .clk(clk), .reset(reset),
        .d(RA2D), .q(RA2E)
    );
    // --------------------
    floprc #(32) rd1Ereg(
        .clk(clk), .reset(reset), .clear(FlushE),
        .d(RD1D), .q(RD1E)
    );
    floprc #(32) rd2Ereg(
        .clk(clk), .reset(reset), .clear(FlushE),
        .d(RD2D), .q(RD2E)
    );
    floprc #(4) wa3Ereg(
        .clk(clk), .reset(reset), .clear(FlushE),
        .d(InstrD[15:12]), .q(WA3E)
    );
    extend ext(
        .Instr(InstrD[23:0]),
        .ImmSrc(ImmSrcD),
        .ExtImm(ExtImmD)
    );
    floprc #(32) extimmEreg(
        .clk(clk), .reset(reset), .clear(FlushE),
        .d(ExtImmD), .q(ExtImmE)
    );
    mux3 #(32) ressrcAmux(
        .d0(RD1E),
        .d1(ResultW),
        .d2(ALUOutM),
        .s(ForwardAE),
        .y(SrcAE)
    );
    mux3 #(32) wrdEmux(
        .d0(RD2E),
        .d1(ResultW),
        .d2(ALUOutM),
        .s(ForwardBE),
        .y(WriteDataE)
    );
    mux2 #(32) ressrcBmux(
        .d0(WriteDataE),
        .d1(ExtImmE),
        .s(ALUSrcE),
        .y(SrcBE)
    );
    alu alu(
        .a(SrcAE),
        .b(SrcBE),
        .ALUControl(ALUControlE),
        .Result(ALUResultE),
        .ALUFlags(ALUFlags)
    );

    // ------- MEMORY ------------
    flopr #(32) instrMreg(
        .clk(clk), .reset(reset),
        .d(InstrE), .q(InstrM)        // -> output InstrM to view
    );
    flopr #(32) aluoutMreg(
        .clk(clk), .reset(reset),
        .d(ALUResultE), .q(ALUOutM)
    );
    flopr #(32) writedataMreg(
        .clk(clk), .reset(reset),
        .d(WriteDataE), .q(WriteDataM)
    );
    flopr #(4) wa3Mreg(
        .clk(clk), .reset(reset),
        .d(WA3E), .q(WA3M)
    );

    // out ALUOutM -> input ReadDataM from dmem

    // ------- WRITEBACK ------------
    flopr #(32) instrWreg(
        .clk(clk), .reset(reset),
        .d(InstrM), .q(InstrW)        // -> output InstrW to view
    );
    flopr #(4) wa3Wreg(
        .clk(clk), .reset(reset),
        .d(WA3M), .q(WA3W)
    );
    flopr #(32) rdataWreg(
        .clk(clk), .reset(reset),
        .d(ReadDataM), .q(ReadDataW)
    );
    flopr #(32) aluoutWreg(
        .clk(clk), .reset(reset),
        .d(ALUOutM), .q(ALUOutW)
    );
    mux2 #(32) resmux(
        .d0(ALUOutW),
        .d1(ReadDataW),
        .s(MemtoRegW),
        .y(ResultW)
    );

    // match signals for hazard detection
    assign Match_1E_M = (WA3M == RA1E) & (WA3M != 4'b1111);
    assign Match_1E_W = (WA3W == RA1E) & (WA3M != 4'b1111);
    assign Match_2E_M = (WA3M == RA2E) & (WA3M != 4'b1111);
    assign Match_2E_W = (WA3W == RA2E) & (WA3M != 4'b1111);

    assign Match12D_E = ((WA3E == RA1D) & (WA3E != 4'b1111)) | 
                        ((WA3E == RA2D) & (WA3E != 4'b1111));

endmodule