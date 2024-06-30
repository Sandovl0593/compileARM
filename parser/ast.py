from typing import TextIO

# --------- codes for ARM instructions ---------
commands = {
    "ADD" :"0100",
    "ADDS":"0100",
    "SUB" :"0010",
    "SUBS":"0010",
    "ORR" :"1100",
    "AND" :"0000",
    "FMUL":"1111",
    "FMULS":"1111",
    "LSL" :"1101",
    "LSR" :"1101",
}

conditions = {
    "EQ": "0000",
    "NE": "0001",
    "GE": "1010",
    "GT": "1100",
    "LT": "1011",
    "LE": "1101",
    "UNCOND": "1110"
}

class Instr:
    def getARMcode(self):
        pass
    
    def getMachineCode(self, os: TextIO):
        pass

class DpInst(Instr):
    def __init__(self, cmd: str, cond: str, rd: int, rn: int, sr2: int, flags: bool, inmediate: bool):
        self.cmd = cmd
        self.cond = cond
        self.rd = rd
        self.rn = rn
        self.sr2 = sr2
        self.flags = flags
        self.inmediate = inmediate
    
    def getARMcode(self):
        print(f"  {self.cmd}{self.cond if self.cond != 'UNCOND' else ''}{'S' if self.flags else ''} R{self.rd}, R{self.rn}, {'#' if self.inmediate else 'R'}{self.sr2}")
    
    def getMachineCode(self, os: TextIO):
        os.write(conditions[self.cond])           # cond
        os.write("00")                            # op
        os.write("1" if self.inmediate else "0")  # I
        os.write(commands[self.cmd])               # cmd
        os.write("1" if self.flags else "0")       # S
        os.write(format(self.rn, '04b'))           # Rn
        os.write(format(self.rd, '04b'))           # Rd

        if self.inmediate:
            # get 8 bits from sr2 with 4 bits of rotation 
            sr2_ = self.sr2
            rot = 0
            while sr2_ > 255:
                sr2_ = sr2_ >> 2
                rot += 1
            os.write(format(rot, '04b')) # rotation
            os.write(format(sr2_, '08b')) # sr2
        else:
            # register without shift
            os.write("0000") # no shift
            os.write("000") # default
            os.write(format(self.sr2, '05b')) # rm
        os.write("\n")
    
    def __del__(self):
        pass

class MemoryInst(Instr):
    def __init__(self, cmd: str, cond: str, rd: int, rn: int, offset: int, inmediate: bool):
        self.cmd = cmd
        self.cond = cond
        self.rd = rd
        self.rn = rn
        self.offset = offset
        self.inmediate = inmediate
    
    def getARMcode(self):
        print(f"  {self.cmd}{self.cond if self.cond != 'UNCOND' else ''} R{self.rd}, [R{self.rn}, {'#' if self.inmediate else 'R'}{self.offset}]")
    
    def getMachineCode(self, os: TextIO):
        os.write(conditions[self.cond])                        # cond
        os.write("01")                                        # op
        os.write("0" if self.inmediate else "1")              # ~I
        os.write("1")                                         # P
        os.write("1")                                         # U
        os.write("1" if 'B' in self.cmd else "0")             # B
        os.write("0")                                         # W
        os.write("1" if 'L' in self.cmd else "0")             # L
        os.write(format(self.rn, '04b'))                      # Rn
        os.write(format(self.rd, '04b'))                      # Rd

        if self.inmediate:
            # get 12 bits from offset
            os.write(format(self.offset, '012b')) # offset
        else:
            # register without shift
            os.write("00000")                        # no shift
            os.write("001")                          # default
            os.write(format(self.offset, '04b'))     # rm
        os.write("\n")
    
    def __del__(self):
        pass

class DeclBranch(Instr):
    def __init__(self, label: str):
        self.label = label
    
    def getARMcode(self):
        print(f"  {self.label}:")
    
    def getMachineCode(self, os: TextIO):
        pass
    
    def __del__(self):
        pass

class BranchInst(Instr):
    def __init__(self, cond: str, label: str, count_pos_instr: int):
        self.cond = cond
        self.label = label
        self.count_pos_instr = count_pos_instr
    
    def getARMcode(self):
        print(f"  B{self.cond if self.cond != 'UNCOND' else ''} {self.label}")
    
    def getMachineCode(self, os: TextIO):
        os.write(conditions[self.cond])               # cond
        os.write("10")                               # op
        os.write("10")                               # 1L (no linked in this case)
        os.write(format(self.count_pos_instr, '024b') if self.count_pos_instr > 0 else "0"*24) # count_pos_instr between BTA and PC+8
        os.write("\n")
    
    def __del__(self):
        pass