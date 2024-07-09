module fmul16 (
    input wire [15:0] A,
    input wire [15:0] B,
    output wire [15:0] Result,
);

    wire [4:0] exponentA, exponentB, exponentRes;
    wire [9:0] mantissaA, mantissaB;
    wire sign;
    wire [19:0] product;
    wire [9:0] mantissaNorm;

    // Step 1: Extract exponent
    assign exponentA[4] = 1'b0;
    assign exponentA[3:0] = A[14:11];
    assign exponentB[4] = 1'b0;
    assign exponentB[3:0] = B[14:11];

    // Step 2: Set mantissas
    // in A and B, the first bit is always 1 (implicit) and the rest is the fraction
    assign mantissaA[9] = 1'b1;
    assign mantissaA[8:0] = A[10:1]; 
    assign mantissaB[9] = 1'b1;
    assign mantissaB[8:0] = B[10:1];

    // Step 3: Calculate exponent
    assign exponentRes = exponentA + exponentB - 15;
    assign sign = A[15] ^ B[15]; // Calculate sign

    // Step 4: Multiply mantissas
    assign product = mantissaA * mantissaB;

    // Step 6: Normalize mantissa
    // if the 20th bit is 1, then the result is norm
    // otherwise the result needs to be shifted to the right
    assign mantissaNorm = (product[19]) ? product[18:8] : product[17:7];

    // Step 7: Combine the result
    assign Result = {sign, exponentRes, mantissaNorm};

endmodule