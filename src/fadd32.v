module fadd32 (
    input wire [31:0] A,
    input wire [31:0] B,
    output wire [31:0] Result,
    output wire [3:0] ALUFlags
);

    wire [8:0] exponentA, exponentB, shift, shiftNegative;
    wire [7:0] exponentC, exponentRes;
    wire [23:0] fractionA, fractionB, mantissaA, mantissaB;
    wire [24:0] mantissaC;
    wire [22:0] mantissaResult;
    wire neg, zero, carry, overflow;
    
    assign exponentA = {1'b0, A[30:23]};
    assign fractionA = {1'b1, A[22:0]};

    assign exponentB = {1'b0, B[30:23]};
    assign fractionB = {1'b1, B[22:0]};
    
    // Calculate shift
    assign shift = exponentA + ~exponentB + 1;

    // shift[8] is the sign bit
    // if shift[8] is 1, then exponentB is larger than exponentA
    assign exponentC = (shift[8]) ? exponentB[7:0]: exponentA[7:0];

    // Calculate mantissa
    assign shiftNegative = ~shift + 1; // 2's complement in the case of negative shift
   
    // mantissaA is the fraction of the number with the larger exponent
    assign mantissaA = (shift[8]) ? fractionB: fractionA;

    // mantissaB is the fraction of the number with the smaller exponent
    // here if shift is negative, we need to shift the fraction to the right,
    // otherwise we need to shift the fraction to the left
    assign mantissaB = (shift[8]) ? fractionA >> shiftNegative: fractionB >> shift;
    
    // Add mantissas
    assign mantissaC = mantissaA + mantissaB;

    // Normalize mantissa
    // exponentRes is the exponent of the result
    assign exponentRes = exponentC + mantissaC[24];
    // here we are focusing in the 24th bit of the mantissa because it is the carry bit
    // if the carry bit is 1, then the result is normalized, 
    // otherwise we need to shift the mantissa to the right
    assign mantissaResult = (mantissaC[24]) ? mantissaC[23:1] : mantissaC[22:0];
    
    // Combine the result
    assign Result = {A[31], exponentRes, mantissaResult};

    assign neg = (mantissaResult[22] == 1);
    assign carry = (mantissaC[24] == 1);
    assign zero = (mantissaResult == 23'h0000000 && exponentRes == 8'h00);
    assign overflow = (exponentRes > 8'hFF);
    assign ALUFlags = {neg, zero, carry, overflow};

endmodule