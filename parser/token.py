from enum import Enum

class OpToken(Enum):
    ADD  = 1; ADDEQ = 2; ADDNE = 3; ADDGT = 4; ADDGE = 5; ADDLT = 6; ADDLE = 7
    SUB  = 8; SUBEQ = 9; SUBNE = 10; SUBGT = 11; SUBGE = 12; SUBLT = 13; SUBLE = 14
    FMUL = 15; FMULEQ = 16; FMULNE = 17; FMULGT = 18; FMULGE = 19; FMULLT = 20; FMULLE = 21
    AND  = 22; ANDEQ = 23; ANDNE = 24; ANDGT = 25; ANDGE = 26; ANDLT = 27; ANDLE = 28
    ORR  = 29; ORREQ = 30; ORRNE = 31; ORRGT = 32; ORRGE = 33; ORRLT = 34; ORRLE = 35
    LSL  = 36; LSLEQ = 37; LSLNE = 38; LSLGT = 39; LSLGE = 40; LSLLT = 41; LSLLE = 42
    LSR  = 43; LSREQ = 44; LSRNE = 45; LSRGT = 46; LSRGE = 47; LSRLT = 48; LSRLE = 49
    LDR  = 50; LDREQ = 51; LDRNE = 52; LDRGT = 53; LDRGE = 54; LDRLT = 55; LDRLE = 56
    LDRB = 57; LDRBEQ = 58; LDRBNE = 59; LDRBGT = 60; LDRBGE = 61; LDRBLT = 62; LDRBLE = 63
    STR  = 64; STREQ = 65; STRNE = 66; STRGT = 67; STRGE = 68; STRLT = 69; STRLE = 70
    B    = 71; BEQ   = 72; BNE   = 73; BGT   = 74; BGE   = 75; BLT   = 76; BLE   = 77
    EOR  = 78; EOREQ = 79; EORNE = 80; EORGT = 81; EORGE = 82; EORLT = 83; EORLE = 84

    def __str__(self):
        return self.name.upper()
    
    def __int__(self):
        return self.value
    

class FlagToken(Enum):
    ADDS = 1; SUBS = 2; FMULS = 3

    def __str__(self):
        return self.name.upper()
    
    def __int__(self):
        return self.value


class KeyToken(Enum):
    LCOR = 1; RCOR = 2; COMMA = 3; SEMICOLON = 4
    DNUM = 5; HEXNUM = 6; REG = 7
    LABEL = 8; TPOINTS = 9
    ERR = 10; END = 11; LOGERR = 12; COMMENT = 13; NEXT = 14

    def __str__(self):
        return self.name.upper()
    
    def __int__(self):
        return self.value


class FToken(Enum):
    FADD16 = 1; FADD16EQ = 2; FADD16NE = 3; FADD16GT = 4; FADD16GE = 5; FADD16LT = 6; FADD16LE = 7
    FMUL16 = 8; FMUL16EQ = 9; FMUL16NE = 10; FMUL16GT = 11; FMUL16GE = 12; FMUL16LT = 13; FMUL16LE = 14
    FADD32 = 15; FADD32EQ = 16; FADD32NE = 17; FADD32GT = 18; FADD32GE = 19; FADD32LT = 20; FADD32LE = 21
    FMUL32 = 22; FMUL32EQ = 23; FMUL32NE = 24; FMUL32GT = 25; FMUL32GE = 26; FMUL32LT = 27; FMUL32LE = 28

    def __str__(self):
        return self.name.upper()
    
    def __int__(self):
        return self.value


class VecToken(Enum):
    VADD = 1; VADDEQ = 2; VADDNE = 3; VADDGT = 4; VADDGE = 5; VADDLT = 6; VADDLE = 7
    VSUB = 8; VSUBEQ = 9; VSUBNE = 10; VSUBGT = 11; VSUBGE = 12; VSUBLT = 13; VSUBLE = 14
    VMUL = 15; VMULEQ = 16; VMULNE = 17; VMULGT = 18; VMULGE = 19; VMULLT = 20; VMULLE = 21
    VAND = 22; VANDEQ = 23; VANDNE = 24; VANDGT = 25; VANDGE = 26; VANDLT = 27; VANDLE = 28
    VORR = 29; VORREQ = 30; VORRNE = 31; VORRGT = 32; VORRGE = 33; VORRLT = 34; VORRLE = 35
    VXOR = 36; VXOREQ = 37; VXORNE = 38; VXORGT = 39; VXORGE = 40; VXORLT = 41; VXORLE = 42

    def __str__(self):
        return self.name.upper()
    
    def __int__(self):
        return self.value


class Mnemonic(Enum):
    UNCOND = 0; EQ = 1; NE = 2; GT = 3; GE = 4; LT = 5; LE = 6

    def __str__(self):
        return self.name.upper()
    
    def __int__(self):
        return self.value


class TokenData:

    def __str__(self):
        tokk = str(self.type)
        if self.mnemonic != Mnemonic.UNCOND:
            tokk += str(self.mnemonic)
        if self.lexema == "":
            return tokk
        else:
            return tokk + "(" + self.lexema + ")"

    def __init__(self, type, mnemonic: Mnemonic = Mnemonic.UNCOND, lexema: str = ""):
        self.type = type
        self.lexema = lexema
        self.mnemonic = mnemonic