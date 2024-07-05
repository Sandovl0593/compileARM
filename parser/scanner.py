from .token import *

class Scanner:
    input: str
    first: int
    current: int
    
    def __init__(self, in_s: str):
        self.input = in_s
        self.first = 0
        self.current = 0
        self.r_mnemotics = [Mnemonic.UNCOND, Mnemonic.EQ, Mnemonic.NE, Mnemonic.GT, Mnemonic.GE, Mnemonic.LT, Mnemonic.LE]
        self.r_opers = [OpToken.ADD, OpToken.SUB, OpToken.FMUL, OpToken.AND, OpToken.ORR, OpToken.LSL, OpToken.LSR, OpToken.LDR, OpToken.LDRB, OpToken.STR, OpToken.B, OpToken.EOR]
        self.vec_opers = [VecToken.VADD, VecToken.VSUB, VecToken.VMUL, VecToken.VAND, VecToken.VORR, VecToken.VXOR]
        self.f_opers = [FToken.FADD16, FToken.FMUL16, FToken.FADD32, FToken.FMUL32]

    def reset(self):
        self.current = 0
        self.first = 0

    def startLexema(self):
        self.first = self.current - 1
 
    def getLexema(self):
        return self.input[self.first:self.current]
    
    def rollBack(self):
        self.current -= 1

    def nextChar(self):
        string = self.input[self.current]
        self.current += 1
        return string
        
    def nextToken(self) -> TokenData:
        if self.current < len(self.input)-1:
            c = self.nextChar()
        else:
            return TokenData(KeyToken.END)

        while c == ' ':
            c = self.nextChar()
        
        self.startLexema()

        if c == '#':
            c = self.nextChar()
            if c.isdigit():
                cn = self.nextChar()
                if c == '0' and cn == 'x':
                    c = self.nextChar()
                    while c.isdigit() or c.isalpha():
                        c = self.nextChar()
                    self.rollBack()
                    token = TokenData(KeyToken.HEXNUM, lexema=self.getLexema())
                else:
                    while cn.isdigit():
                        cn = self.nextChar()
                    self.rollBack()
                    token = TokenData(KeyToken.DNUM, lexema=self.getLexema())
            else:
                token = TokenData(KeyToken.ERR, lexema=c)
        
        elif c == 'R' or c == 'r':
            c = self.nextChar()
            if c.isdigit():
                if c == '1':
                    c2 = self.nextChar()
                    if c2.isdigit():
                        if c2 <= '5':
                            token = TokenData(KeyToken.REG, lexema=self.getLexema())
                        else:
                            token = TokenData(KeyToken.LOGERR, lexema=self.getLexema())
                    else:
                        self.rollBack()
                        token = TokenData(KeyToken.REG, lexema=self.getLexema())
                else:
                    token = TokenData(KeyToken.REG, lexema=self.getLexema())
            else:
                token = TokenData(KeyToken.ERR, lexema=c)
        
        elif c == '[':
            token = TokenData(KeyToken.LCOR)
        elif c == ']':
            token = TokenData(KeyToken.RCOR)
        elif c == ',':
            token = TokenData(KeyToken.COMMA)
        elif c == '\n':
            token = TokenData(KeyToken.NEXT)
        elif c == ';':
            c = self.nextChar()
            while c != '\n':
                c = self.nextChar()
            return TokenData(KeyToken.COMMENT)
        elif c == ':':
            token = TokenData(KeyToken.TPOINTS)
        
        elif c.isalpha():
            c = self.nextChar()
            while c.isalpha() or c.isdigit() or c == '_':
                c = self.nextChar()
            self.rollBack()
           
            lex = self.getLexema()
            if lex in FlagToken.__members__:
                tt = FlagToken[lex]
                token = TokenData(tt, mnemonic=Mnemonic.UNCOND)
            elif lex in FToken.__members__:
                tt = FToken[lex]
                for i in range(len(self.f_opers)):
                    if int(tt) >= 7*i+1 and int(tt) <= 7*(i+1):
                        token = TokenData(self.f_opers[i], mnemonic=self.r_mnemotics[(int(tt) % 7)-1])
                        break
            elif lex in VecToken.__members__:
                tt = VecToken[lex]
                for i in range(len(self.vec_opers)):
                    if int(tt) >= 7*i+1 and int(tt) <= 7*(i+1):
                        token = TokenData(self.vec_opers[i], mnemonic=self.r_mnemotics[(int(tt) % 7)-1])
                        break
            elif lex in OpToken.__members__:
                tt = OpToken[lex]
                for i in range(len(self.r_opers)):
                    if int(tt) >= 7*i+1 and int(tt) <= 7*(i+1):
                        token = TokenData(self.r_opers[i], mnemonic=self.r_mnemotics[(int(tt) % 7)-1])
                        break
            else:
                token = TokenData(KeyToken.LABEL, lexema=self.getLexema())
        else:
            token = TokenData(KeyToken.ERR, lexema=c)

        return token