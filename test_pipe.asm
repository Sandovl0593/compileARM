SUB R0, R15, R15
ADD R1, R0, #1
ADD R2, R0, #2
ADD R3, R0, #3
ADD R4, R0, #4
ADD R5, R0, #5
ADD R6, R0, #6
ADD R7, R0, #7
ADD R1, R4, R5      // R1 = 4 + 5 = 9
AND R8, R1, R3      // R8 = 1001 & 0011 = 0001 = 1
ORR R9, R6, R1      // R9 = 0110 | 1001 = 1111 = 15
SUB R10, R1, R7     // R10 = 9 - 7 = 2
STR R3, [R4, #40]   
LDR R1, [R4, #40]   // R1 = 3
AND R8, R1, R3      // R8 = 0011 & 0011 = 0011 = 3
ORR R9, R6, R1	    // R9 = 0110 | 0011 = 0111 = 7
SUB R10, R1, R2     // R10 = 3 - 2 = 1
