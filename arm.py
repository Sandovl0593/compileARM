
import sys
from parser.parser import *

if (__name__ == '__main__'):
    if (len(sys.argv) != 2):
        print("Incorrect number of arguments")
        sys.exit(1)

    # open file
    file = sys.argv[1]
    t = open("parser/" + file + ".asm", "r")
    out = open("src/memfile_bin.mem", "w")
    buffer = t.read()
    
    scanner = Scanner(buffer)
    parser = Parser(scanner)

    # parse and generate binary code
    print("program in ARM: \n")
    parser.parse(out)
    print("\nBinary code generated in memfile_bin.mem")
    out.close()
    t.close()

    # convert to hexadecimal code
    f = open("src/memfile_bin.mem", "r")
    lines = f.readlines()
    final = open("src/memfile.mem", "w")

    for line in lines:
        hexnum = hex(int(line, 2)).upper()[2:]
        if len(hexnum) < 8:
            hexnum = "0" * (8 - len(hexnum)) + hexnum
        final.write(hexnum + '\n')

    print("Hexadecimal code in memfile.mem")
    f.close()
    final.close()
