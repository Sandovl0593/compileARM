module top (
    clk,
    reset,
    WriteDataM,
    DataAdrM, // ALUOutM from datapath
    MemWriteM,
    PCF,
    InstrF,
    ReadDataM,
    // testbench pipeline outputs
    InstrD, InstrE, InstrM, InstrW
);
    input wire clk;
    input wire reset;

    output wire [31:0] WriteDataM;
    output wire [31:0] DataAdrM;
    output wire MemWriteM;
    output wire [31:0] PCF;
    output wire [31:0] InstrF;
    output wire [31:0] ReadDataM;

    output wire [31:0] InstrD, InstrE, InstrM, InstrW;

    arm arm(
        // inputs
        .clk(clk),
        .reset(reset),
        .InstrF(InstrF),
        .ReadDataM(ReadDataM),
        // outputs
        .PCF(PCF),
        .MemWriteM(MemWriteM),
        .WriteDataM(WriteDataM),
        .ALUOutM(DataAdrM),
        // testbench pipeline outputs
        .InstrD(InstrD),
        .InstrE(InstrE),
        .InstrM(InstrM),
        .InstrW(InstrW)
    );
    imem imem(
        .a(PCF),
        .rd(InstrF)
    );
    dmem dmem(
        // inputs
        .clk(clk),
        .we(MemWriteM),
        .a(DataAdrM),
        .wd(WriteDataM),
        // outputs
        .rd(ReadDataM)
    );
endmodule