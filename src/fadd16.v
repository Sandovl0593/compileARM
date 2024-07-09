module fadd16 (
    input wire [15:0] A,
    input wire [15:0] B,
    output wire [15:0] Result,
    output wire [3:0] ALUFlags
);

    wire [5:0] exponentA, exponentB, shift, shiftNegative;
    wire [4:0] exponentC, exponentRes;
    wire [8:0] fractionA, fractionB, mantissaA, mantissaB;
    wire [11:0] mantissaC;
    wire [9:0] mantissaResult;
    wire neg, zero, carry, overflow;
    
    assign exponentA = {1'b0, A[14:11]};
    assign fractionA = {1'b1, A[10:1]};

    assign exponentB = {1'b0, B[14:11]};
    assign fractionB = {1'b1, B[10:1]};

    // Calculate shift
    assign shift = exponentA + ~exponentB + 1;

    // shift[5] is the sign bit
    // if shift[5] is 1, then exponentB is larger than exponentA
    assign exponentC = (shift[5]) ? exponentB[4:0]: exponentA[4:0];

    // Calculate mantissa
    assign shiftNegative = ~shift + 1; // 2's complement in the case of negative shift
    
    // mantissaA is the fraction of the number with the larger exponent
    assign mantissaA = (shift[5]) ? fractionB: fractionA;
    
    // mantissaB is the fraction of the number with the smaller exponent
    // here if shift is negative, we need to shift the fraction to the right,
    // otherwise we need to shift the fraction to the left
    assign mantissaB = (shift[5]) ? fractionA >> shiftNegative: fractionB >> shift;

    // Add mantissas
    assign mantissaC = mantissaA + mantissaB;

    // Normalize mantissa
    // exponentRes is the exponent of the result
    assign exponentRes = exponentC + mantissaC[11];
    // here we are focusing in the 12th bit of the mantissa because it is the carry bit
    // if the carry bit is 1, then the result is normalized,
    // otherwise we need to shift the mantissa to the right
    assign mantissaResult = (mantissaC[11]) ? mantissaC[10:1] : mantissaC[9:0];

    // Combine the result
    assign Result = {A[15], exponentRes, mantissaResult};
    
    assign neg = (mantissaResult[9] == 1);
    assign carry = (mantissaC[10] == 1);
    assign zero = (mantissaResult == 10'h000000 && exponentRes == 5'h00);
    assign overflow = (exponentRes > 8'hFF);
    assign ALUFlags = {neg, zero, carry, overflow};

endmodule