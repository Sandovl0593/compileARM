module fmul32 (
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] Result,
    output wire [3:0] ALUFlags
);

    wire [7:0] exponentA, exponentB;
    wire [8:0] exponentCur; exponentRes;
    wire [23:0] mantissaA, mantissaB;
    wire sign;
    wire [47:0] product;
    wire [22:0] mantissaNorm;
    wire neg, zero, carry, overflow;

    assign exponentA = A[30:23];
    assign mantissaA = {1'b1, A[22:0]};

    assign exponentB = B[30:23];
    assign mantissaB = {1'b1, B[22:0]};

    assign sign = A[31] ^ B[31]; // Calculate sign
    // Calculate exponent
    assign exponentCur = exponentA + exponentB - 127;
    // Multiply mantissas
    assign product = mantissaA * mantissaB;

    // Normalize mantissa
    // if the 48th bit is 1, then the result is norm
    // otherwise the result needs to be shifted to the right
    assign mantissaNorm = (product[47]) ? product[46:24] : product[45:23];

    assign exponentRes = exponentCur + product[47];

    // Combine the result
    assign Result = {sign, exponentRes[7:0], mantissaNorm};

    assign neg = (mantissaNorm[22] == 1);
    assign carry = (product[47] == 1);
    assign zero = (mantissaNorm == 23'h0000000 && exponentCur == 8'h00);
    assign overflow = (exponentCur > 8'hFF);
    assign ALUFlags = {neg, zero, carry, overflow};

endmodule