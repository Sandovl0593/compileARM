module extend (
    Instr,
    ImmSrc,
    ExtImm
);
    input wire [23:0] Instr;
    input wire [1:0] ImmSrc;
    output reg [31:0] ExtImm;

    wire [3:0] Rotate;
    assign Rotate = Instr[11:8];

    always @(*)
        case (ImmSrc)
            2'b00: begin
                ExtImm = {24'b000000000000000000000000, Instr[7:0]};
                ExtImm = (ExtImm >> (Rotate << 1)) |
                         (ExtImm << (32 - (Rotate << 1)));
            end
            2'b01: ExtImm = {20'b00000000000000000000, Instr[11:0]};
            2'b10: ExtImm = {{6 {Instr[23]}}, Instr[23:0], 2'b00};
            default: ExtImm = 32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
        endcase
endmodule