module fmul16 (
    input wire [15:0] A,
    input wire [15:0] B,
    output wire [15:0] Result,
    output wire [3:0] ALUFlags
);

    wire [3:0] exponentA, exponentB;
    wire [4:0] exponentCur, exponentRes;
    wire [8:0] mantissaA, mantissaB;
    wire sign;
    wire [17:0] product;
    wire [9:0] mantissaNorm;

    assign exponentA = A[14:11];
    assign mantissaA = {1'b1, A[10:1]};

    assign exponentB = B[14:11];
    assign mantissaB = {1'b1, B[10:1]};

    assign sign = A[15] ^ B[15]; // Calculate sign
    // Calculate exponent
    assign exponentCur = exponentA + exponentB - 15;
    // Multiply mantissas
    assign product = mantissaA * mantissaB;

    // Normalize mantissa
    // if the 18th bit is 1, then the result is norm
    // otherwise the result needs to be shifted to the right
    assign mantissaNorm = (product[17]) ? product[16:8] : product[15:7];

    assign exponentRes = exponentCur + product[17];

    // Combine the result
    assign Result = {sign, exponentRes[4:0], mantissaNorm};

    assign neg = (mantissaNorm[9] == 1);
    assign carry = (product[19] == 1);
    assign zero = (mantissaNorm == 10'h000000 && exponentRes == 5'h00);
    assign overflow = (exponentRes > 5'h1F);
    assign ALUFlags = {neg, zero, carry, overflow};

endmodule