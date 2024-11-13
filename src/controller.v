module controller (
    clk,
    reset,
    Instr,
    ALUFlags,
    RegSrc,
    RegWrite,
    ImmSrc,
    ALUSrc,
    ALUControl,
    MemWrite,
    MemtoReg,
    PCSrc
);
    input wire clk;
    input wire reset;
    input wire [31:12] Instr;
    input wire [3:0] ALUFlags;

    output wire [1:0] RegSrc;
    output wire RegWrite;
    output wire [1:0] ImmSrc;
    output wire ALUSrc;
    output wire [2:0] ALUControl;
    output wire MemWrite;
    output wire MemtoReg;
    output wire PCSrc;

    wire [1:0] FlagW;
    wire PCS;
    wire RegW;
    wire MemW;

    decode dec(
        // inputs
        .Op(Instr[27:26]),
        .Funct(Instr[25:20]),
        .Rd(Instr[15:12]),
        // outputs
        .FlagW(FlagW),            // reg
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        .MemtoReg(MemtoReg),
        .ALUSrc(ALUSrc),
        .ImmSrc(ImmSrc),
        .RegSrc(RegSrc),
        .ALUControl(ALUControl)   // reg
    );
    condlogic cl(
        // inputs
        .clk(clk),
        .reset(reset),
        .Cond(Instr[31:28]),
        .ALUFlags(ALUFlags),
        .FlagW(FlagW),
        .PCS(PCS),
        .RegW(RegW),
        .MemW(MemW),
        // outputs
        .PCSrc(PCSrc),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite)
    );
endmodule