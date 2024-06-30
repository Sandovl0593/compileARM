from enum import Enum

class Token(Enum):
    ADD  = 1; ADDEQ = 2; ADDNE = 3; ADDGT = 4; ADDGE = 5; ADDLT = 6; ADDLE = 7
    SUB  = 8; SUBEQ = 9; SUBNE = 10; SUBGT = 11; SUBGE = 12; SUBLT = 13; SUBLE = 14
    FMUL = 15; FMULEQ = 16; FMULNE = 17; FMULGT = 18; FMULGE = 19; FMULLT = 20; FMULLE = 21
    AND  = 22; ANDEQ = 23; ANDNE = 24; ANDGT = 25; ANDGE = 26; ANDLT = 27; ANDLE = 28
    ORR  = 29; ORREQ = 30; ORRNE = 31; ORRGT = 32; ORRGE = 33; ORRLT = 34; ORRLE = 35
    LSL  = 36; LSLEQ = 37; LSLNE = 38; LSLGT = 39; LSLGE = 40; LSLLT = 41; LSLLE = 42
    LSR  = 43; LSREQ = 44; LSRNE = 45; LSRGT = 46; LSRGE = 47; LSRLT = 48; LSRLE = 49
    LDR  = 50; LDREQ = 51; LDRNE = 52; LDRGT = 53; LDRGE = 54; LDRLT = 55; LDRLE = 56
    STR  = 57; STREQ = 58; STRNE = 59; STRGT = 60; STRGE = 61; STRLT = 62; STRLE = 63
    B    = 64; BEQ   = 65; BNE   = 66; BGT   = 67; BGE   = 68; BLT   = 69; BLE   = 70
    LCOR = 71; RCOR  = 72; COMMA = 73; SEMICOLON = 74
    ADDS = 75; SUBS  = 76; FMULS = 77
    DNUM = 78; HEXNUM = 79; REG = 80
    LABEL = 81; TPOINTS = 82
    ERR = 83; END = 84; LOGERR = 85; COMMENT = 86; NEXT = 88

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
    type: Token
    mnemonic: Mnemonic
    lexema: str

    def __str__(self):
        tokk = str(self.type)
        if self.mnemonic != Mnemonic.UNCOND:
            tokk += str(self.mnemonic)
        if self.lexema == "":
            return tokk
        else:
            return tokk + "(" + self.lexema + ")"

    def __init__(self, type: Token, mnemonic: Mnemonic = Mnemonic.UNCOND, lexema: str = ""):
        self.type = type
        self.lexema = lexema
        self.mnemonic = mnemonic