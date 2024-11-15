from parser.encoding import *

MAX = 2**32

def bn(str_num, size):
    if int(str_num) >= 0:
        return bin(int(str_num))[2:].zfill(size)
    # format two's complement (only restrict to size=32)
    signed = bin(MAX + int(str_num))[2:]
    return signed[(32-size):]


def toMachine_dp(base_ins, I, cmd, S, Rn, Rd, src2, cmd_sh, shamt, I_sh):
    code_cmd = cmd_ref[cmd]
    code_Rn = bn(Rn[1:], 4)
    code_Rd = bn(Rd[1:], 4)
    result_code =  base_ins + I  + code_cmd + S + code_Rn + code_Rd
    if int(I):
        number = src2[1:]
        value_imm = int(number, 16) if number[:2] == '0x' else int(number)
        value_rot = 0
        if value_imm > 255:
            while value_imm % 2 == 0:
                value_imm >>= 1
                value_rot += 1
            if value_rot % 2 == 1:
                value_rot -= 1
                value_imm <<= 1
            rot_code = bn((32 - value_rot)/2, 4)
        else:
            rot_code = '0000'
        code_imm = bn(value_imm, 8)
        print(value_rot, value_imm, "->", code_imm, rot_code)
        result_code += rot_code + code_imm
    else:
        code_Rm = bn(src2[1:], 4)
        if I_sh:
            cmd_shift = bn(shamt[1:], 5)
        else:
            cmd_shift = bn(shamt[1:], 4) + '0'
        code_sh = shifts[cmd_sh]
        code_I_sh = '0' if I_sh else '1'
        result_code += cmd_shift + code_sh + code_I_sh + code_Rm

    return result_code


def toMachine_memory(base_ins, neg_I, B, L, index, Rn, Rd, src2, shamt, cmd_sh):
    code_Rn = bn(Rn[1:], 4)
    code_Rd = bn(Rd[1:], 4)
    PW = '00' if index == 'post' else '01' if index == 'pre' else '10' if index == 'def' else '11'
    U = '1'
    result_code = base_ins + neg_I + PW[0] + U + B + PW[1] + L + code_Rn + code_Rd

    if not int(neg_I):
        number = src2[1:]
        value_imm = int(number, 16) if number[:2] == '0x' else int(number)
        
        U = '1' if value_imm >= 0 else '0'
        code_imm = bn(value_imm, 12)
        result_code += code_imm
    else:
        code_Rm = bn(src2[1:], 4)
        cmd_shift = bn(shamt[1:], 5)
        code_sh = shifts[cmd_sh]
        result_code += cmd_shift + code_sh + '0' + code_Rm
    return result_code 


def toMachine_branch(base_ins, L, offset):
    code_offset = bn(offset, 24)
    return base_ins + '1' + L + code_offset