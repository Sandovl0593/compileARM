SUB R3, R15, R15
ADD R0, R3, #0x100     // Valor 0x100 en R0
ADD R1, R3, #0x200     // Valor 0x200 en R1
ADD R2, R3, #0x3       // Valor 0x3 en R2
ADD R3, R0, R1         // R3 = R0 + R1, R3 = 0x100 + 0x200 = 0x300
SUB R4, R3, R2         // R4 = R3 - R2, R4 = 0x300 - 0x3 = 0x2FD
SUB R0, R15, R15
AND R3, R0, R4              // R3 = 0 & 0x2FD = 0
ADD R7, R0, R1, LSL #4         // R7 = R1 << 4, R7 = 0x200 << 4 = 0x2000
ADD R8, R0, R7, LSR #2         // R8 = R7 >> 2, R8 = 0x2000 >> 2 = 0x800
ADD R9, R0, R8, ASR #1         // R9 = R8 aritméticamente >> 1, R9 = 0x800 >> 1 = 0x400
ADD R0, R0, #10                 // R0 = R0 + 10 = 10
STR R8, [R3, #20]       // 0x800 = R8 -> mem[0 + 20]
UDIV R1, R8, R2       // R1 = R8 / R2, R1 = 0x800 / 0x3 = 0x2AA (sin signo)
LDR R10, [R3, #20]     // R10 = mem[0 + 20] = 0x800
SDIV R3, R9, R2       // R3 = R9 / R2, R3 = 0x400 / 0x3 = 0x155 (con signo)
ORR R5, R4, R2         // R5 = R4 | R2, R5 = 0x2FD | 0x3 = 0x2FF
MLA R0, R1, R2, R5    // R0 = R1 * R2 + R5, R0 = 0x2AA * 0x3 + 0x2FF = 0xB55
STR R10, [R3, #4]       // 0x800 = R10 -> mem[155 + 4]
ADD R2, R2, #300