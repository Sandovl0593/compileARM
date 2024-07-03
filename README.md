# CompileARM
## _MultiCycle processor With Floating Point Unit and Vector Unit support_

- Python Decoder from ARM ASM language to machine code (hexadecimal).
- Design execution with instructions machine code.

## Execute Simulation in Ikarus

### Script
```bat
python arm.py %1
iverilog -o output src\testbench.v
vvp output
```
### Running

```bat
./compile.bat "<name-asmfile>"
```

## Informe

## Cracks del proyecto
- Hósmer Casma M.
- Jazmin Soto Q.
- Adrian Sandoval H.
- Josep Castro E.
