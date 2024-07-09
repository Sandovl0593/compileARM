module fmul32 (
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] Result,
);

    wire [8:0] exponentA, exponentB, exponentRes;
    wire [23:0] mantissaA, mantissaB;
    wire sign;
    wire [47:0] product
    wire [22:0] mantissaNorm;

    // Step 1: Extract exponent
    assign exponentA[8] = 1'b0;
    assign exponentA[7:0] = A[30:23];
    assign exponentB[8] = 1'b0;
    assign exponentB[7:0] = B[30:23];

    // Step 2: Set mantissas
    // in A and B, the first bit is always 1 (implicit) and the rest is the fraction
    assign mantissaA[23] = 1'b1;
    assign mantissaA[22:0] = A[22:0]; 
    assign mantissaB[23] = 1'b1;
    assign mantissaB[22:0] = B[22:0];

    // Step 3: Calculate exponent
    assign exponentRes = exponentA + exponentB - 127;
    assign sign = A[31] ^ B[31]; // Calculate sign

    // Step 4: Multiply mantissas
    assign product = mantissaA * mantissaB;

    // Step 6: Normalize mantissa
    // if the 48th bit is 1, then the result is norm
    // otherwise the result needs to be shifted to the right
    assign mantissaNorm = (product[47]) ? product[46:24] : product[45:23];

    // Step 7: Combine the result
    assign Result = {sign, exponentRes, mantissaNorm};

endmodule