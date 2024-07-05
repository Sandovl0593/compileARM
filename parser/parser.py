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

    def match(self, ttype) -> bool:
        if self.check(ttype):
            self.advance()
            return True
        return False
    
    def check(self, ttype) -> bool:
        if self.isAtEnd():
            return False
        return self.current.type == ttype

    def matchDpInstr(self, ttype) -> bool:
        if self.checkDpInstr(ttype):
            self.advance()
            return True
        return False

    def checkDpInstr(self) -> bool:
        if self.isAtEnd():
            return False
        return self.current.type in [OpToken.ADD, OpToken.SUB, OpToken.FMUL, OpToken.AND, OpToken.ORR, OpToken.LSL, OpToken.LSR, OpToken.EOR]

    def matchMemoryInstr(self, ttype) -> bool:
        if self.checkMemoryInstr(ttype):
            self.advance()
            return True
        return False
    
    def checkMemoryInstr(self) -> bool:
        if self.isAtEnd():
            return False
        return self.current.type in [OpToken.LDR, OpToken.STR, OpToken.LDRB]
    
    def matchFlagInstr(self, ttype) -> bool:
        if self.checkFlagInstr(ttype):
            self.advance()
            return True
        return False
    
    def checkFlagInstr(self) -> bool:
        if self.isAtEnd():
            return False
        return self.current.type in [FlagToken.ADDS, FlagToken.SUBS, FlagToken.FMULS]

    def advance(self) -> bool:
        if not self.isAtEnd():
            temp = self.current
            self.current = self.scanner.nextToken()
            self.previous = temp
            if self.check(KeyToken.ERR):
                print("Parse error, unrecognised character: " + self.current.lexema)
                exit(0)
            elif self.check(KeyToken.LOGERR):
                print("Error - asignacion invalida")
                exit(0)
            return True
        return False

    def isAtEnd(self) -> bool:
        return self.current.type == KeyToken.END

    def parserError(self, s: str):
        print("Parsing error: " + s)
        exit(0)

    def loadBranches(self, os: TextIO):
        if self.check(KeyToken.ERR):
            print("Error - caracter invalido")
            exit(0)
        elif self.check(KeyToken.LOGERR):
            print("Error - asignacion invalida")
            exit(0)

        if self.match(KeyToken.LABEL):
            label = self.parseDeclLabel(True)
            self.decLabels[label] = self.linePos + 1
        else:
            self.parseLine(os, True)
        while self.match(KeyToken.COMMENT) or self.match(KeyToken.NEXT):
            self.linePos += 1
            if self.match(KeyToken.LABEL):
                label = self.parseDeclLabel(True)
                self.decLabels[label] = self.linePos + 1
            else:
                self.parseLine(os, True)

        if self.current.type != KeyToken.END:
            print("Esperaba EOinput, se encontro " + str(self.current))
            exit(0)

    def parse(self, os: TextIO):
        self.current = self.scanner.nextToken()
        self.loadBranches(os)
        self.linePos = 0
        self.scanner.reset()

        self.current = self.scanner.nextToken()
        self.parseProgram(os)

    def parseProgram(self, os: TextIO):
        self.parseLine(os, False)
        while self.match(KeyToken.COMMENT) or self.match(KeyToken.NEXT):
            self.linePos += 1
            self.parseLine(os, False)

    def parseLine(self, os: TextIO, read):
        line = None
        if self.match(OpToken.B):
            line = self.parseBranchInstr(read)
        elif self.matchMemoryInstr():
            line = self.parseMemoryInstr()
        elif self.matchDpInstr():
            line = self.parseDpInstr(False)
        elif self.matchFlagInstr():
            line = self.parseDpInstr(True)
        elif self.match(KeyToken.LABEL):
            self.parseDeclLabel(read)
        if read:
            line.getARMcode()
        elif line:
            line.getMachineCode(os)

    def parseValue(self) -> int:
        extract = self.previous.lexema[1:]
        type = self.previous.type
        if type == KeyToken.HEXNUM:
            return int(extract[2:], 16)
        return int(extract)
    
    def parseDpInstr(self, flags: bool) -> DpInst:
        opcode = self.previous.type
        condit = self.previous.mnemonic
        if not self.match(KeyToken.REG):
            self.parserError("Se esperaba rd")
        reg1 = self.parseValue()
        if not self.match(KeyToken.COMMA):
            self.parserError("Se esperaba ','")
        if not self.match(KeyToken.REG):
            self.parserError("Se esperaba rn")
        reg2 = self.parseValue()
        if not self.match(KeyToken.COMMA):
            self.parserError("Se esperaba ','")
        if self.match(KeyToken.DNUM) or self.match(KeyToken.HEXNUM) or self.match(KeyToken.REG):
            sr2 = self.parseValue()
            inmed = self.previous.type != KeyToken.REG
            if condit != Mnemonic.UNCOND:
                return DpInst(str(opcode), str(condit), reg1, reg2, sr2, flags, inmed)
            else:
                return DpInst(str(opcode), "UNCOND", reg1, reg2, sr2, flags, inmed)
        self.parserError("Se esperaba numero")
        return None
    
    def parseMemoryInstr(self) -> MemoryInst:
        opcode = self.previous.type
        condit = self.previous.mnemonic
        if not self.match(KeyToken.REG):
            self.parserError("Se esperaba rd")
        reg1 = self.parseValue()
        if not self.match(KeyToken.COMMA):
            self.parserError("Se esperaba ','")
        if not self.match(KeyToken.LCOR):
            self.parserError("Se esperaba '['")
        if self.match(KeyToken.REG):
            reg2 = self.parseValue()
            if not self.match(KeyToken.RCOR):
                if not self.match(KeyToken.COMMA):
                    self.parserError("Se esperaba ','")
                if self.match(KeyToken.DNUM) or self.match(KeyToken.HEXNUM) or self.match(KeyToken.REG):
                    sr2 = self.parseValue()
                    inmed = self.previous.type != KeyToken.REG
                    if not self.match(KeyToken.RCOR):
                        self.parserError("Se esperaba ']'")
                    if condit != Mnemonic.UNCOND:
                        return MemoryInst(str(opcode), str(condit), reg1, reg2, sr2, inmed)
                    else:
                        return MemoryInst(str(opcode), "UNCOND", reg1, reg2, sr2, inmed)
                self.parserError("Se esperaba numero")
            else:
                if condit != Mnemonic.UNCOND:
                    return MemoryInst(str(opcode), str(condit), reg1, reg2, 0, True)
                else:
                    return MemoryInst(str(opcode), "UNCOND", reg1, reg2, 0, True)
        else:
            self.parserError("Se esperaba rn")
        return None
    
    def parseBranchInstr(self, read: bool) -> BranchInst:
        condit = self.previous.mnemonic
        if not self.match(KeyToken.LABEL):
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
        if not self.match(KeyToken.TPOINTS):
            self.parserError("Se esperaba ':'")
        self.linePos -= 1
        if read:
            print(label, ": ", end="\n")
        return label
