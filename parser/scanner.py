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
        self.r_opers = [Token.ADD, Token.SUB, Token.FMUL, Token.AND, Token.ORR, Token.LSL, Token.LSR, Token.LDR, Token.STR, Token.B]
        
    def reset(self):
        self.current = 0
        self.first = 0

    def checkReserved(self, lexema: str) -> Token:
        if lexema in Token.__members__:
            return Token[lexema]
        else:
            return Token.ERR

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
            return TokenData(Token.END)

        while c == ' ':
            c = self.nextChar()
        
        self.startLexema()

        if c == '#':
            c = self.nextChar()
            if c.isdigit():
                cn = self.nextChar()
                if c == '0' and cn == 'x':
                    c = self.nextChar()
                    while c.isdigit():
                        c = self.nextChar()
                    self.rollBack()
                    token = TokenData(Token.HEXNUM, lexema=self.getLexema())
                else:
                    while cn.isdigit():
                        cn = self.nextChar()
                    self.rollBack()
                    token = TokenData(Token.DNUM, lexema=self.getLexema())
            else:
                token = TokenData(Token.ERR, lexema=c)
        
        elif c == 'R' or c == 'r':
            c = self.nextChar()
            if c.isdigit():
                if c == '1':
                    c2 = self.nextChar()
                    if c2.isdigit():
                        if c2 <= '5':
                            token = TokenData(Token.REG, lexema=self.getLexema())
                        else:
                            token = TokenData(Token.LOGERR, lexema=self.getLexema())
                    else:
                        self.rollBack()
                        token = TokenData(Token.REG, lexema=self.getLexema())
                else:
                    token = TokenData(Token.REG, lexema=self.getLexema())
            else:
                token = TokenData(Token.ERR, lexema=c)
        
        elif c == '[':
            token = TokenData(Token.LCOR)
        elif c == ']':
            token = TokenData(Token.RCOR)
        elif c == ',':
            token = TokenData(Token.COMMA)
        elif c == '\n':
            token = TokenData(Token.NEXT)
        elif c == ';':
            c = self.nextChar()
            while c != '\n':
                c = self.nextChar()
            return TokenData(Token.COMMENT)
        elif c == ':':
            token = TokenData(Token.TPOINTS)
        
        elif c.isalpha():
            c = self.nextChar()
            while c.isalpha() or c.isdigit() or c == '_':
                c = self.nextChar()
            self.rollBack()
           
            lex = self.getLexema()
            tt = self.checkReserved(lex)
            for i in range(10):
                if int(tt) >= 7*i+1 and int(tt) <= 7*(i+1):
                    return TokenData(self.r_opers[i], mnemonic=self.r_mnemotics[(int(tt) % 7)-1])
            
            if tt == Token.ADDS or tt == Token.SUBS or tt == Token.FMULS:
                token = TokenData(tt, mnemonic=Mnemonic.UNCOND)
            else:
                token = TokenData(Token.LABEL, lexema=self.getLexema())
        else:
            token = TokenData(Token.ERR, lexema=c)

        return token