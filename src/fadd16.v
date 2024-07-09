module fadd16 (
    input wire [15:0] A,
    input wire [15:0] B,
    output wire [15:0] Result,
);

    wire [4:0] exponentA, exponentB, shift, shiftNegative;
    wire [3:0] exponentC, exponentResult;
    wire [9:0] fractionA, fractionB, mantissaA, mantissaB;
    wire [10:0] mantissaC;
    wire [9:0] mantissaResult;
    
    // Step 1: Extract exponent and fraction
    assign exponentA[4] = 1'b0;
    assign exponentA[3:0] = A[14:11];
    assign exponentB[4] = 1'b0;
    assign exponentB[3:0] = B[14:11];
    
    // Step 2: Extract fraction
    // in A and B, the first bit is always 1 (implicit) and the rest is the fraction
    assign fractionA[9] = 1'b1;
    assign fractionA[8:0] = A[10:1];
    assign fractionB[9] = 1'b1;
    assign fractionB[8:0] = B[10:1];
    
    // Step 3: Calculate shift
    assign shift = exponentA + ~exponentB + 1;

    // shift[4] is the sign bit
    // if shift[4] is 1, then exponentB is larger than exponentA
    assign exponentC = (shift[4]) ? exponentB[3:0]: exponentA[3:0];

    // Step 4: Calculate mantissa
    assign shiftNegative = ~shift + 1; // 2's complement in the case of negative shift
   
    // mantissaA is the fraction of the number with the larger exponent
    assign mantissaA = (shift[4]) ? fractionB: fractionA;

    // mantissaB is the fraction of the number with the smaller exponent
    // here if shift is negative, we need to shift the fraction to the right,
    // otherwise we need to shift the fraction to the left
    assign mantissaB = (shift[4]) ? fractionA >> shiftNegative: fractionB >> shift;
    
    // Step 5: Add mantissas
    assign mantissaC = mantissaA + mantissaB;

    // Step 6: Normalize mantissa
    // exponentResult is the exponent of the result
    assign exponentResult = exponentC + mantissaC[10];
    // here we are focusing in the 10th bit of the mantissa because it is the carry bit
    // if the carry bit is 1, then the result is normalized,
    // otherwise we need to shift the mantissa to the right
    assign mantissaResult = (mantissaC[10]) ? mantissaC[9:1] : mantissaC[8:0];

    // Step 7: Combine the result
    assign Result = {A[15], exponentResult, mantissaResult};

endmodule