module controlunit (
    Op, Funct, Rd,
    FlagWriteD,
    PCSrcD,
    RegWriteD,
    MemWriteD,
    MemtoRegD,
    ALUSrcD,
    ImmSrcD,
    RegSrcD,
    BranchD,
    ALUControlD
);
    input wire [1:0] Op;
    input wire [5:0] Funct;
    input wire [3:0] Rd;

    output reg [1:0] FlagWriteD;  /// Changed
    output wire PCSrcD; /// Changed
    output wire RegWriteD; /// Changed
    output wire MemWriteD; /// Changed
    output wire MemtoRegD; /// Changed
    output wire ALUSrcD; /// Changed
    output wire [1:0] ImmSrcD;  /// Changed
    output wire [1:0] RegSrcD;  /// Changed
    output reg [2:0] ALUControlD; /// Changed
    
    reg [9:0] controlsD;
    output wire BranchD;   /// Changed
    wire ALUOpD;
    
    always @(*)
        casex (Op)
            2'b00:
                if (Funct[5])
                    controlsD =      10'b0000101001;
                else
                    controlsD =      10'b0000001001;
            2'b01:
                if (Funct[0])
                    controlsD =      10'b0001111000;
                else
                    controlsD =      10'b1001110100;
            2'b10: controlsD =       10'b0110100010;
            default: controlsD =     10'bxxxxxxxxxx;
        endcase
 
    assign {RegSrcD, ImmSrcD, ALUSrcD, MemtoRegD, RegWriteD, MemWriteD, BranchD, ALUOpD} = controlsD;

    always @(*)
        if (ALUOpD) begin
            case (Funct[4:1])
                4'b0100: ALUControlD = 3'b000;
                4'b0010: ALUControlD = 3'b001;
                4'b0000: ALUControlD = 3'b010;
                4'b1100: ALUControlD = 3'b011;
                4'b0001: ALUControlD = 3'b100;  // EOR
                default: ALUControlD = 3'bxxx;
            endcase
            FlagWriteD[1] = Funct[0];
            FlagWriteD[0] = Funct[0] & ((ALUControlD == 3'b000) | (ALUControlD == 3'b001));
        end
        else begin
            ALUControlD = 3'b000;
            FlagWriteD = 2'b00;
        end

    assign PCSrcD = ((Rd == 4'b1111) & RegWriteD) | BranchD;
endmodule