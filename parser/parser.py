from .scanner import *
from .ast import *
from typing import TextIO

class Parser:
    def __init__(self, scanner: Scanner):
        self.scanner = scanner
        self.current = None
        self.previous = None
        self.decLabels = {}
        self.linePos = 0
        return

    def match(self, ttype: Token) -> bool:
        if self.check(ttype):
            self.advance()
            return True
        return False

    def check(self, ttype: Token) -> bool:
        if self.isAtEnd():
            return False
        return self.current.type == ttype

    def advance(self) -> bool:
        if not self.isAtEnd():
            temp = self.current
            self.current = self.scanner.nextToken()
            self.previous = temp
            if self.check(Token.ERR):
                print("Parse error, unrecognised character: " + self.current.lexema)
                exit(0)
            elif self.check(Token.LOGERR):
                print("Error - asignacion invalida")
                exit(0)
            return True
        return False

    def isAtEnd(self) -> bool:
        return self.current.type == Token.END

    def parserError(self, s: str):
        print("Parsing error: " + s)
        exit(0)

    def loadBranches(self, os: TextIO):
        if self.check(Token.ERR):
            print("Error - caracter invalido")
            exit(0)
        elif self.check(Token.LOGERR):
            print("Error - asignacion invalida")
            exit(0)

        if self.match(Token.LABEL):
            label = self.parseDeclLabel(True)
            self.decLabels[label] = self.linePos + 1
        else:
            self.parseLine(os, True)
        while self.match(Token.COMMENT) or self.match(Token.NEXT):
            self.linePos += 1
            if self.match(Token.LABEL):
                label = self.parseDeclLabel(True)
                self.decLabels[label] = self.linePos + 1
            else:
                self.parseLine(os, True)

        if self.current.type != Token.END:
            print("Esperaba EOinput, se encontro " + str(self.current))
            exit(0)

    def parse(self, os: TextIO):
        print("MAIN:")
        self.current = self.scanner.nextToken()
        self.loadBranches(os)
        self.linePos = 0
        self.scanner.reset()

        self.current = self.scanner.nextToken()
        self.parseProgram(os)

    def parseProgram(self, os: TextIO):
        self.parseLine(os, False)
        while self.match(Token.COMMENT) or self.match(Token.NEXT):
            self.linePos += 1
            self.parseLine(os, False)

    def parseLine(self, os: TextIO, read):
        line = None
        if self.match(Token.B):
            line = self.parseBranchInstr(read)
        elif self.match(Token.LDR) or self.match(Token.STR):
            line = self.parseMemoryInstr()
        elif self.match(Token.ADD) or self.match(Token.SUB) or self.match(Token.FMUL) or self.match(Token.AND) or \
             self.match(Token.ORR) or self.match(Token.LSL) or self.match(Token.LSR):
            line = self.parseDpInstr(False)
        elif self.match(Token.ADDS) or self.match(Token.SUBS) or self.match(Token.FMULS):
            line = self.parseDpInstr(True)
        elif self.match(Token.LABEL):
            self.parseDeclLabel(read)
        if read:
            line.getARMcode()
        elif line:
            line.getMachineCode(os)

    def parseValue(self) -> int:
        extract = self.previous.lexema[1:]
        type = self.previous.type
        if type == Token.HEXNUM:
            return int(extract[2:], 16)
        return int(extract)
    
    def parseDpInstr(self, flags: bool) -> DpInst:
        opcode = self.previous.type
        condit = self.previous.mnemonic
        if not self.match(Token.REG):
            self.parserError("Se esperaba rd")
        reg1 = self.parseValue()
        if not self.match(Token.COMMA):
            self.parserError("Se esperaba ','")
        if not self.match(Token.REG):
            self.parserError("Se esperaba rn")
        reg2 = self.parseValue()
        if not self.match(Token.COMMA):
            self.parserError("Se esperaba ','")
        if self.match(Token.DNUM) or self.match(Token.HEXNUM) or self.match(Token.REG):
            sr2 = self.parseValue()
            inmed = self.previous.type != Token.REG
            if condit != Mnemonic.UNCOND:
                return DpInst(str(opcode), str(condit), reg1, reg2, sr2, flags, inmed)
            else:
                return DpInst(str(opcode), "UNCOND", reg1, reg2, sr2, flags, inmed)
        self.parserError("Se esperaba numero")
        return None
    
    def parseMemoryInstr(self) -> MemoryInst:
        opcode = self.previous.type
        condit = self.previous.mnemonic
        if not self.match(Token.REG):
            self.parserError("Se esperaba rd")
        reg1 = self.parseValue()
        if not self.match(Token.COMMA):
            self.parserError("Se esperaba ','")
        if not self.match(Token.LCOR):
            self.parserError("Se esperaba '['")
        if not self.match(Token.REG):
            self.parserError("Se esperaba rn")
        reg2 = self.parseValue()
        if not self.match(Token.COMMA):
            self.parserError("Se esperaba ','")
        if self.match(Token.DNUM) or self.match(Token.HEXNUM) or self.match(Token.REG):
            sr2 = self.parseValue()
            inmed = self.previous.type != Token.REG
            if not self.match(Token.RCOR):
                self.parserError("Se esperaba ']'")
            if condit != Mnemonic.UNCOND:
                return MemoryInst(str(opcode), str(condit), reg1, reg2, sr2, inmed)
            else:
                return MemoryInst(str(opcode), "UNCOND", reg1, reg2, sr2, inmed)
        self.parserError("Se esperaba ']'")
        return None
    
    def parseBranchInstr(self, read: bool) -> BranchInst:
        condit = self.previous.mnemonic
        if not self.match(Token.LABEL):
            self.parserError("Se esperaba label")
        label = self.previous.lexema
        if read:
            return BranchInst(str(condit), label, 0)
        BTA = self.decLabels[label] - (self.linePos + 3)
        if condit != Mnemonic.UNCOND:
            return BranchInst(str(condit), label, BTA)
        return BranchInst("UNCOND", label, BTA)
    
    def parseDeclLabel(self, read) -> str:
        label = self.previous.lexema
        if not self.match(Token.TPOINTS):
            self.parserError("Se esperaba ':'")
        self.linePos -= 1
        if read:
            print(label, ": ", end="\n")
        return label
