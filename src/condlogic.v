module condlogic (
    PCSrcE,
    RegWriteE,
    MemtoRegE,
    MemWriteE,
    BranchE,
    FlagWriteE,
    CondE,
    FlagsE,
    ALUFlags,
    // outputs
    BranchTakenE,
    FlagsNextE,
    PCSrcEOut,
    RegWriteEOut,
    MemWriteEOut
);
    input wire PCSrcE;
    input wire RegWriteE;
    input wire MemtoRegE;
    input wire MemWriteE;
    input wire BranchE;
    input wire [1:0] FlagWriteE;
    input wire [3:0] CondE;
    input [3:0] FlagsE;

    output reg [3:0] FlagsNextE;
    input wire [3:0] ALUFlags;
    output wire PCSrcEOut;
    output wire BranchTakenE;
    output wire RegWriteEOut;
    output wire MemWriteEOut;

    reg CondExE;
    wire neg, zero, carry, overflow, ge; 
    assign {neg, zero, carry, overflow} = FlagsE;
    assign ge = (neg == overflow); 
    always @(*) begin
        case (CondE)
            4'b0000: CondExE = zero;
            4'b0001: CondExE = ~zero;
            4'b0010: CondExE = carry;
            4'b0011: CondExE = ~carry;
            4'b0100: CondExE = neg;
            4'b0101: CondExE = ~neg;
            4'b0110: CondExE = overflow;
            4'b0111: CondExE = ~overflow;
            4'b1000: CondExE = carry & ~zero;
            4'b1001: CondExE = ~(carry & ~zero);
            4'b1010: CondExE = ge;
            4'b1011: CondExE = ~ge;
            4'b1100: CondExE = ~zero & ge;
            4'b1101: CondExE = ~(~zero & ge);
            4'b1110: CondExE = 1'b1;
            default: CondExE = 1'bx;
        endcase
        FlagsNextE[3:2] = (FlagWriteE[1] & CondExE) ? ALUFlags[3:2] : FlagsE[3:2];
        FlagsNextE[1:0] = (FlagWriteE[0] & CondExE) ? ALUFlags[1:0] : FlagsE[1:0];
    end
    
    assign BranchTakenE = BranchE & CondExE;

    assign RegWriteEOut = RegWriteE & CondExE;
    assign MemWriteEOut = MemWriteE & CondExE;
    assign PCSrcEOut = PCSrcE & CondExE;
endmodule