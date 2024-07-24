<h1 align="center">CompileARM</h1>

<h4 align="center"><em>[Title soon]</em></h4>

## Contenido

#### Python Decoder from ARM ASM language to machine code (hexadecimal).
#### Design execution by structural implem. Verilog using instructions machine code in the `imem.v`.

## Cracks del proyecto
- Adrian Sandoval Huamaní
- [Soon]

## Simulación in Ikarus

### Script
```bat
@echo off

REM run arm.py with arg a asm file
python arm.py %1

REM execute testbench.v with iverilog and vvp
iverilog -o output src/testbench.v src/adder.v src/alu.v src/arm.v src/condcheck.v src/condlogic.v src/controller.v src/datapath.v src/decode.v src/dmem.v src/extend.v src/flopenr.v src/flopr.v src/imem.v src/mux2.v src/regfile.v src/top.v
vvp output
gtkwave output.vcd
```
### Running

```bat
./compile.bat "<name-asmfile>"
```

## Informe

