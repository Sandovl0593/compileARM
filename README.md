<h1 align="center">CompileARM</h1>

<h4 align="center"><em>MultiCycle proccessor With Floating Point Unit and Vector Unit support</em></h4>

## Contenido

#### Python Decoder from ARM ASM language to machine code (hexadecimal).
#### Design execution structural implem. Verilog with instructions machine code.

## Cracks del proyecto
- Hósmer Casma M.
- Jazmin Soto Q.
- Adrian Sandoval H.
- Josep Castro E.

## Simulación in Ikarus

### Script
```bat
@echo off
python arm.py %1
iverilog -o output src\testbench.v
vvp output
```
### Running

```bat
./compile.bat "<name-asmfile>"
```

## Informe

