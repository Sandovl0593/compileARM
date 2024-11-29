module controlunit (
    // Op, Funct, Rd,
    InstrD,
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
    // input wire [1:0] Op;
    // input wire [5:0] Funct;
    // input wire [3:0] Rd;
    input wire [31:0] InstrD;

    output reg [1:0] FlagWriteD;  /// Changed
    output wire PCSrcD; /// Changed
    output wire RegWriteD; /// Changed
    output wire MemWriteD; /// Changed
    output wire MemtoRegD; /// Changed
    output wire ALUSrcD; /// Changed
    output wire [1:0] ImmSrcD;  /// Changed
    output wire [1:0] RegSrcD;  /// Changed
    output reg [5:0] ALUControlD; /// Changed
    wire ALUOpD;
    output wire BranchD;   /// Changed

    // Cambios en ISA { [ cond op I cmd S] }

    // ahora si op[1] = 1 -> DProccessing -> se toma op[0] y todo el cmd, siendo 5 bits para ALUControl
    // si op[1] = 0 -> {
    //    si op[0] = 1 -> Branch -> se toma I y cmd[3] como dos bits de Branch para ALUControl
    //    si op[0] = 0 -> Memory -> se toma todo el cmd siendo 4 bits para ALUControl
    // }

    wire isDataProcessing;
    assign isDataProcessing = InstrD[27]; // op[1]

    wire isInmediate;
    assign isInmediate = InstrD[25]; // I

    wire isBranch;
    assign isBranch = ~isDataProcessing & InstrD[26]; // 01

    wire setFlags;
    assign setFlags = InstrD[24]; // S
    
    wire cmd;
    assign cmd = InstrD[24:21];

    // ------------ fields Shift -> [ shamt 1 sh 0 Rm ]
    wire [1:0] ShiftOp;
    assign ShiftOp = InstrD[6:5];

    assign RegSrcD = isDataProcessing ? 2'b00 : (isBranch ? 2'b01 : {~setFlags, 1'b0});
    assign ImmSrcD = isDataProcessing ? 2'b00 : (isBranch ? 2'b10 : 2'b01);
    assign ALUSrcD = isDataProcessing ? isInmediate : 1'b1;
    assign MemtoRegD = isDataProcessing ? 1'b0 : (isBranch ? 1'b0 : setFlags);
    assign RegWriteD = isDataProcessing ? 1'b1 : (isBranch ? 1'b0 : ~setFlags);
    assign MemWriteD = isDataProcessing ? 1'b0 : (isBranch ? 1'b1 : ~setFlags);
    assign BranchD = isDataProcessing ? 1'b0 : isBranch;
    assign ALUOpD = isDataProcessing;
    
    always @(*) begin
        if (isDataProcessing) begin
            case ({ InstrD[26], cmd }) // op[0] cmd
                5'b00000: ALUControlD = 6'b100000;  // ADD -> NZCV
                5'b00001: ALUControlD = 6'b100001;  // ADC -> NZCV
                5'b00010: ALUControlD = 6'b100010;  // QADD -> NZCV
                5'b00011: ALUControlD = 6'b100011;  // SUB -> NZCV
                5'b00100: ALUControlD = 6'b100100;  // SBS -> NZCV
                5'b00101: ALUControlD = 6'b100101;  // SBC -> NZCV
                5'b00110: ALUControlD = 6'b100110;  // QSUB -> NZCV
                5'b00111: ALUControlD = 6'b100111;  // MUL -> NZ
                5'b01000: ALUControlD = 6'b101000;  // MLA -> NZ
                5'b01001: ALUControlD = 6'b101001;  // MLS -> NZ 
                5'b01010: ALUControlD = 6'b101010;  // UMULL -> NZ
                5'b01011: ALUControlD = 6'b101011;  // UMLAL -> NZ
                5'b01100: ALUControlD = 6'b101100;  // SMULL -> NZ
                5'b01101: ALUControlD = 6'b101101;  // SMLAL -> NZ
                5'b01110: ALUControlD = 6'b101110;  // UDIV -> NZ 
                5'b01111: ALUControlD = 6'b101111;  // SDIV -> NZ
                5'b10000: ALUControlD = 6'b110000;  // AND  -> NZ
                5'b10001: ALUControlD = 6'b110001;  // BIC -> NZ
                5'b10010: ALUControlD = 6'b110010;  // ORR -> NZ
                5'b10011: ALUControlD = 6'b110011;  // ORN -> NZ
                5'b10100: ALUControlD = 6'b110100;  // EOR -> NZ
                5'b10101: ALUControlD = 6'b110101;  // CMN -> NZ
                5'b10110: ALUControlD = 6'b110110;  // TST -> NZ
                5'b10111: ALUControlD = 6'b110111;  // TEQ -> NZ
                5'b11000: ALUControlD = 6'b111000;  // CMP -> NZCV
                5'b11001: ALUControlD = 6'b111001;  // MOV -> NZ
                5'b11010: ALUControlD = 6'b111010;  // LSR 
                5'b11011: ALUControlD = 6'b111011;  // ASR
                5'b11100: ALUControlD = 6'b111100;  // LSL
                5'b11101: ALUControlD = 6'b111101;  // ROR
                5'b11110: ALUControlD = 6'b111110;  // RRXs
                default:  ALUControlD = 6'bxxxxxx;
            endcase
            FlagWriteD[1] = setFlags;
            FlagWriteD[0] = setFlags & (
                (ALUControlD == 6'b100000) | (ALUControlD == 6'b100001) | 
                (ALUControlD == 6'b100010) | (ALUControlD == 6'b100011) |
                (ALUControlD == 6'b100100) | (ALUControlD == 6'b100101) | 
                (ALUControlD == 6'b100110) | (ALUControlD == 6'b110000) | 
                (ALUControlD == 6'b110001) | (ALUControlD == 6'b110010) | 
                (ALUControlD == 6'b110011) | (ALUControlD == 6'b110100) |
                (ALUControlD == 6'b110101) | (ALUControlD == 6'b110110) |
                (ALUControlD == 6'b110111) | (ALUControlD == 6'b111000) |
                (ALUControlD == 6'b111010) | (ALUControlD == 6'b111011) |
                (ALUControlD == 6'b111100) | (ALUControlD == 6'b111101) | (ALUControlD == 6'b111110)
            );
        end
        else begin
            if (isBranch) begin
                case (InstrD[25:24])  // I cmd[3]
                    2'b00:   ALUControlD = 6'b010000;  // B
                    2'b01:   ALUControlD = 6'b010001;  // BL
                    2'b11:   ALUControlD = 6'b010010;  // CBZ Test & branch
                    2'b10:   ALUControlD = 6'b010011;  // CBNZ Test & branch
                    default: ALUControlD = 6'bxxxxxx;
                endcase
                FlagWriteD = 2'b00;
            end 
            else begin
                case (InstrD[24:21]) // I cmd
                    4'b0000: ALUControlD = 6'b000010;  // LDR Offset
                    4'b0001: ALUControlD = 6'b000011;  // STR Offset
                    4'b0010: ALUControlD = 6'b000100;  // LDR Pre-offset
                    4'b0011: ALUControlD = 6'b000101;  // STR Pre-offset
                    4'b0100: ALUControlD = 6'b000110;  // LDR Post-offset
                    4'b0101: ALUControlD = 6'b000111;  // STR Post-offset
                    4'b0110: ALUControlD = 6'b001000;  // LDR Indexed
                    4'b0111: ALUControlD = 6'b001001;  // STR Indexed
                    4'b1000: ALUControlD = 6'b001010;  // LDR Literal
                    4'b1001: ALUControlD = 6'b001011;  // STR Literal
                    4'b1010: ALUControlD = 6'b001100;  // STMIA Positive stack
                    4'b1011: ALUControlD = 6'b001101;  // LDMDB Positive stack
                    4'b1100: ALUControlD = 6'b001110;  // STMDB Negative stack
                    4'b1101: ALUControlD = 6'b001111;  // LDMIA Negative stack
                    default: ALUControlD = 6'bxxxxxx;
                endcase
                FlagWriteD = 2'b00;
            end
        end
    end
    assign PCSrcD = ((InstrD[15:12] == 4'b1111) & RegWriteD[0]) | BranchD;
endmodule