module alu (
    input [31:0]        a,
    input [31:0]        b,
    input [2:0]         ALUControl,
    output reg [31:0]   Result,
    output wire [3:0]   ALUFlags
);
    wire  neg, zero, carry, overflow;
    wire [31:0] condinvb;
    wire [32:0] sum;

    assign condinvb = ALUControl[0] ? ~b : b; // determina si se invierte b
    assign sum = a + condinvb + ALUControl[0];
    always @(*)
    begin
        casex (ALUControl[2:0])
        3'b00?: Result = sum;
        3'b010: Result = a & b;
        3'b011: Result = a | b;
        3'b100: Result = a ^ b;
        3'b101: Result = b;
        endcase
    end

    assign neg      = Result[31];
    assign zero     = (Result == 32'b0);
    assign carry    = (ALUControl[2] == 1'b0) & sum[32];
    assign overflow = (ALUControl[2] == 1'b0) & ~(a[31] ^ b[31] ^ ALUControl[0]) & (a[31] ^ sum[31]);
    assign ALUFlags = {neg, zero, carry, overflow};

endmodule
