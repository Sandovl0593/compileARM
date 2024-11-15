from parser.encoding import *

dp_binary_op = [
    "ADD", "SUB", "AND", "ORR", "EOR", "UDIV", "SDIV"
]
dp_only_flags = [
    "CMP", "CMN", "TST", "TEQ"
]

def token_data_processing(list_of_tokens):
    # formato Data Processing ARMv7
    get_oper = list_of_tokens[0]  # obviamente el primer token es la operacion
    command = get_oper
    for oper in dp_binary_op:
        if oper in command: command = oper; break

    for oper in dp_only_flags:
        if oper in command: command = oper; break

    if "MOV" in command: command = "MOV"
    if "MLA" in command: command = "MLA"

    # for oper in dp_terna_op:
    #     if oper in command: command = oper; break

    # ----------- base inst
    post_cmd = get_oper[len(command):]
    S = '0'
    cond = 'AL'
    if len(post_cmd) == 1 and 'S' == post_cmd[0]:
        S = '1'
    elif len(post_cmd) == 2:
        cond = post_cmd
    elif len(post_cmd) > 2 and 'S' == post_cmd[0]:
        S = '1'
        cond = post_cmd[1:]
    # -------------

    inst = {
        "base_ins": conditions[cond] + '00',
        "S": S,
        "cmd": command
    }

    if command in dp_binary_op:
        # -- [OP][S][cond] Rn, Rd, Operand2
        inst["Rd"] = list_of_tokens[1]
        inst["Rn"] = list_of_tokens[2]
        src2 = inst["src2"] = list_of_tokens[3]
        inst["I"] = '1' if src2[0] == '#' else '0'

        # -- [OP][S][cond] Rn, Rd, Operand2 shift Operand3
        if len(list_of_tokens) == 6:
            inst["cmd_sh"] = list_of_tokens[4]
            shamt = inst["shamt"] = list_of_tokens[5]
            inst["I_sh"] = shamt[0] == '#'
        else:
            inst["cmd_sh"] = 'LSL'
            inst["shamt"] = 'R0'
            inst["I_sh"] = True

    elif command == "MOV":
        # -- [OP][S][cond] Rd, Operand2
        inst["Rd"] = list_of_tokens[1]
        inst["Rn"] = '0'
        src2 = inst["src2"] = list_of_tokens[2]
        inst["I"] = '1' if src2[0] == '#' else '0'
        inst["cmd_sh"] = 'LSL'
        inst["shamt"] = 'R0'
        inst["I_sh"] = True

    elif command in dp_only_flags:
        # -- [OP][S][cond] Rn, Operand2
        inst["Rd"] = '0'
        inst["Rn"] = list_of_tokens[1]
        src2 = inst["src2"] = list_of_tokens[2]
        inst["I"] = '1' if src2[0] == '#' else '0'

        # -- [OP][S][cond] Rn, Operand2 shift Operand3
        if len(list_of_tokens) == 6:
            inst["cmd_sh"] = list_of_tokens[4]
            shamt = inst["shamt"] = list_of_tokens[5]
            inst["I_sh"] = shamt[0] == '#'
        else:
            inst["cmd_sh"] = 'LSL'
            inst["shamt"] = 'R0'
            inst["I_sh"] = True

    elif command == "MLA":
        # -- [OP][S][cond] Rn, Rd, Rm, Operand2
        inst["Rd"] = list_of_tokens[1]
        inst["Rn"] = list_of_tokens[2]
        src2 = inst["src2"] = list_of_tokens[3]
        inst["I"] = '0'
        inst["cmd_sh"] = 'LSL'
        shamt = inst["shamt"] = list_of_tokens[4]
        inst["I_sh"] = False

    return inst


def token_memory(list_of_tokens):
    # formato Memory ARMv7
    get_oper = list_of_tokens[0]  # obviamente el primer token es la operacion
    command = get_oper
    if "STR" in command: command = "STR"
    if "LDR" in command: command = "LDR"

    # ----------- base inst
    post_cmd = get_oper[len(command):]
    B = '0'
    cond = 'AL'
    if len(post_cmd) == 1: 
        B = '1'
    elif len(post_cmd) == 2:
        cond = post_cmd
    elif len(post_cmd) > 2 and 'B' == post_cmd[0]:
        B = '1'
        cond = post_cmd[1:]

    L = '1' if command == 'LDR' else '0'
    # -------------

    inst = {
        "base_ins": conditions[cond] + '01', 
        "Rd": list_of_tokens[1],
        "B": B,
        "L": L,
        "shamt": 'R0',
        "neg_I": '0',
        "cmd_sh": 'LSL',
    }

    if len(list_of_tokens) == 3:
        # -- [OP][cond] Rd, [Rn] -> offset
        inst["Rn"] = list_of_tokens[2][1:-1]
        inst["src2"] = 'R0'
        inst["index"] = 'def'
    elif len(list_of_tokens) == 4:
        inst["neg_I"] = '0' if list_of_tokens[3][0] == '#' else '1'
        # -- [OP][cond] Rd, [Rn, src2]! -> preindex
        if '!' in list_of_tokens[3]:
            inst["Rn"] = list_of_tokens[2][1:]
            inst["src2"] = list_of_tokens[3][:-2]
            inst["index"] = 'pre'
        # -- [OP][cond] Rd, [Rn, src2] -> offset
        elif ']' in list_of_tokens[3]:
            inst["Rn"] = list_of_tokens[2][1:]
            inst["src2"] = list_of_tokens[3][:-1]
            inst["index"] = 'def'
        # -- [OP][cond] Rd, [Rn], #offset -> postindex
        elif ']' in list_of_tokens[2]:
            inst["Rn"] = list_of_tokens[2][1:-1]
            inst["src2"] = list_of_tokens[3]
            inst["index"] = 'post'
    
    #shift
    elif len(list_of_tokens) == 6:
        inst["neg_I"] = '0' if list_of_tokens[3][0] == '#' else '1'
        inst["Rn"] = list_of_tokens[2][1:]
        inst["src2"] = list_of_tokens[3]
        inst["cmd_sh"] = list_of_tokens[4]
        # -- [OP][cond] Rd, [Rn, Rm, [shift] #offset]! -> preindex
        if '!' in list_of_tokens[5]:
            inst["Rn"] = list_of_tokens[2][1:]
            inst["shamt"] = list_of_tokens[5][:-2]
            inst["index"] = 'pre'
        # -- [OP][cond] Rd, [Rn, Rm, [shift] #offset] -> offset
        elif ']' in list_of_tokens[5]:
            inst["Rn"] = list_of_tokens[2][1:]
            inst["shamt"] = list_of_tokens[5][:-1]
            inst["index"] = 'def'
        # -- [OP][cond] Rd, [Rn], Rm, [shift] #offset -> postindex
        elif ']' in list_of_tokens[2]:
            inst["Rn"] = list_of_tokens[2][1:-1]
            inst["shamt"] = list_of_tokens[5]
            inst["index"] = 'post'

    return inst


def token_branch(list_of_tokens, labels, pos):
    # formato Branch ARMv7
    get_oper = list_of_tokens[0]  # obviamente el primer token es la operacion
    # if "B" in command: command = "B"

    # ----------- base inst
    post_cmd = get_oper[1:]
    cond = 'AL'
    L = '0'
    if len(post_cmd) == 1 and 'L' == post_cmd[0]:
        L = '1'
    elif len(post_cmd) == 2:
        cond = post_cmd
    elif len(post_cmd) > 2 and 'L' == post_cmd[0]:
        L = '1'
        cond = post_cmd[1:]
    # -------------

    inst = {
        "base_ins": conditions[cond] + '10',
        "L": L,
        "offset": (labels[list_of_tokens[1]] - (pos + 2)) + 1
    }

    return inst