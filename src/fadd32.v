module fadd32 (
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] Result,
);

    wire [8:0] exponentA, exponentB, shift, shiftNegative;
    wire [7:0] exponentC, exponentResult;
    wire [23:0] fractionA, fractionB, mantissaA, mantissaB;
    wire [24:0] mantissaC;
    wire [22:0] mantissaResult;
    
    // Step 1: Extract exponent and fraction
    assign exponentA[8] = 1'b0;
    assign exponentA[7:0] = A[30:23];
    assign exponentB[8] = 1'b0;
    assign exponentB[7:0] = B[30:23];
    
    // Step 2: Extract fraction
    // in A and B, the first bit is always 1 (implicit) and the rest is the fraction
    assign fractionA[23] = 1'b1;
    assign fractionA[22:0] = A[22:0];
    assign fractionB[23] = 1'b1;
    assign fractionB[22:0] = B[22:0];
    
    // Step 3: Calculate shift
    assign shift = exponentA + ~exponentB + 1;

    // shift[8] is the sign bit
    // if shift[8] is 1, then exponentB is larger than exponentA
    assign exponentC = (shift[8]) ? exponentB[7:0]: exponentA[7:0];

    // Step 4: Calculate mantissa
    assign shiftNegative = ~shift + 1; // 2's complement in the case of negative shift
   
    // mantissaA is the fraction of the number with the larger exponent
    assign mantissaA = (shift[8]) ? fractionB: fractionA;

    // mantissaB is the fraction of the number with the smaller exponent
    // here if shift is negative, we need to shift the fraction to the right,
    // otherwise we need to shift the fraction to the left
    assign mantissaB = (shift[8]) ? fractionA >> shiftNegative: fractionB >> shift;
    
    // Step 5: Add mantissas
    assign mantissaC = mantissaA + mantissaB;

    // Step 6: Normalize mantissa
    // exponentResult is the exponent of the result
    assign exponentResult = exponentC + mantissaC[24];
    // here we are focusing in the 24th bit of the mantissa because it is the carry bit
    // if the carry bit is 1, then the result is normalized, 
    // otherwise we need to shift the mantissa to the right
    assign mantissaResult = (mantissaC[24]) ? mantissaC[23:1] : mantissaC[22:0];
    
    // Step 7: Combine the result
    assign Result = {A[31], exponentResult, mantissaResult};

endmodule