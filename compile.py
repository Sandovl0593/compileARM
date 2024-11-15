import sys
from parser.tomachine import *
from parser.scanner import *

if (__name__ == '__main__'):
    if (len(sys.argv) != 2):
        print("Incorrect number of arguments")
        sys.exit(1)

    # open file
    file = sys.argv[1]
    t = open(file + ".asm", "r")
    out = open("src/memfile_" + file + "_bin.dat", "w")

    # con readlines se obtiene una lista con cada linea del archivo
    buffer = t.readlines()

    # posicion de los labels de branch
    real_pos = [-1] * len(buffer)
    count_labels = 0
    labels = {}
    for i in range(len(buffer)):
        if ':' in buffer[i]:
            count_labels += 1
        real_pos[i] = i - count_labels
            
    for i in range(len(buffer)):
        if ':' in buffer[i]:
            labels[buffer[i][:-2]] = real_pos[i]

    # se recorre cada linea
    for i in range(len(buffer)):
        # si alguno de los elementos de la linea tiene un comentario, se elimina
        line = buffer[i]
        if '//' in buffer[i]:
            line = line.split('//')[0]
        line = line.split(',')

        # se eliminan los espacios en blanco y se separan los elementos
        of_line = []
        for w in line:
            if len(w.split()) > 1:
                of_line += w.split()
            else:
                of_line.append(w.split()[0])

        print(of_line, ' ---:')
        # verificar si la instruccion es de tipo dp
        if len(of_line) >= 3:
            if '[' not in of_line[2]:
                inst = token_data_processing(of_line)
                out.write(toMachine_dp(**inst) + '\n')
            else:
                # remove all the brackets
                inst = token_memory(of_line)
                out.write(toMachine_memory(**inst) + '\n')
            print(inst, end='\n\n')

        elif ':' not in of_line[0]:
            inst = token_branch(of_line, labels, real_pos[i])
            out.write(toMachine_branch(**inst) + '\n')
        
            print(inst, end='\n\n')
    
    print("\nBinary code generated")
    out.close()
    t.close()

    # convert to hexadecimal code
    f = open("src/memfile_" + file + "_bin.dat", "r")
    final = open("src/memfile_" + file + "_hex.dat", "w")
    lines = f.readlines()

    for line in lines:
        hexnum = hex(int(line, 2)).upper()[2:]
        if len(hexnum) < 8:
            hexnum = "0" * (8 - len(hexnum)) + hexnum
        final.write(hexnum + '\n')

    f.close()
    final.close()
    print("\nHexadecimal code generated")