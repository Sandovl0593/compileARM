module datapath (
    clk,
    reset,
    Adr,
    WriteData,
    ReadData,
    Instr,
    ALUFlags,
    PCWrite,
    RegWrite,
    IRWrite,
    AdrSrc,
    RegSrc,
    ALUSrcA,
    ALUSrcB,
    ResultSrc,
    ImmSrc,
    ALUControl
);
    input wire clk;
    input wire reset;
    output wire [31:0] Adr;
    output wire [31:0] WriteData;
    input wire [31:0] ReadData;
    output wire [31:0] Instr;
    output wire [3:0] ALUFlags;
    input wire PCWrite;
    input wire RegWrite;
    input wire IRWrite;
    input wire AdrSrc;
    input wire [1:0] RegSrc;
    input wire [1:0] ALUSrcA;
    input wire [1:0] ALUSrcB;
    input wire [1:0] ResultSrc;
    input wire [1:0] ImmSrc;
    input wire [2:0] ALUControl;
    wire [31:0] PCNext;
    wire [31:0] PC;
    wire [31:0] ExtImm;
    wire [31:0] SrcA;
    wire [31:0] SrcB;
    wire [31:0] Result;
    wire [31:0] Data;
    wire [31:0] RD1;
    wire [31:0] RD2;
    wire [31:0] A;
    wire [31:0] ALUResult;
    wire [31:0] ALUOut;
    wire [3:0] RA1;
    wire [3:0] RA2;

    // Your datapath hardware goes below. Instantiate each of the 
    // submodules that you need. Remember that you can reuse hardware
    // from previous labs. Be sure to give your instantiated modules 
    // applicable names such as pcreg (PC register), adrmux 
    // (Address Mux), etc. so that your code is easier to understand.

    // ADD CODE HERE
    //FETCH
    assign PCNext = Result;
    
    flopenr #(32) flopenrPCNext(
        .clk(clk),
        .reset(reset),
        .en(PCWrite),
        .d(PCNext),
        .q(PC)
    );
    mux2 #(32) PCmux(
        .d0(PC),
        .d1(Result),
        .s(AdrSrc),
        .y(Adr)
    );
    //DECODE
    flopenr #(32) flopenrInstr(
        .clk(clk),
        .reset(reset),
        .en(IRWrite),
        .d(ReadData),
        .q(Instr)
    );
    flopr #(32) floprData(
        .clk(clk),
        .reset(reset),
        .d(ReadData),
        .q(Data)
    );
    mux2 #(4) ra1mux(
        .d0(Instr[19:16]),
        .d1(4'b1111),
        .s(RegSrc[0]),
        .y(RA1)
    );
    mux2 #(4) ra2mux(
        .d0(Instr[3:0]),
        .d1(Instr[15:12]),
        .s(RegSrc[1]),
        .y(RA2)
    );
    regfile rf(
        .clk(clk),
        .we3(RegWrite),
        .ra1(RA1),
        .ra2(RA2),
        .wa3(Instr[15:12]),
        .wd3(Result),
        .r15(Result),
        .rd1(RD1),
        .rd2(RD2)
    );
    extend ext(
        .Instr(Instr[23:0]),
        .ImmSrc(ImmSrc),
        .ExtImm(ExtImm)
    );
    //EXECUTE
    flopr #(32) floprA(
        .clk(clk),
        .reset(reset),
        .d(RD1),
        .q(A)
    );
    flopr #(32) floprWriteData(
        .clk(clk),
        .reset(reset),
        .d(RD2),
        .q(WriteData)
    );
    
    mux3 #(32) APCALUmux(
        .d0(A),
        .d1(PC),
        .d2(ALUOut),
        .s(ALUSrcA),
        .y(SrcA)
    );
    mux3 #(32) WDExtImm4mux(
        .d0(WriteData),
        .d1(ExtImm),
        .d2(32'b100),
        .s(ALUSrcB),
        .y(SrcB)
    );
    alu alu(
        .a(SrcA),
        .b(SrcB),
        .ALUControl(ALUControl),
        .Result(ALUResult),
        .ALUFlags(ALUFlags)
    );
    //MEMORIA
    flopr #(32) floprALU(
        .clk(clk),
        .reset(reset),
        .d(ALUResult),
        .q(ALUOut)
    );
    mux3 #(32) Resultmux(
        .d0(ALUOut),
        .d1(Data),
        .d2(ALUResult),
        .s(ResultSrc),
        .y(Result)
    );
endmodule