@echo off

REM run arm.py with arg a asm file
python compile.py %1

REM execute testbench.v with iverilog and vvp
iverilog -o output src/testbench.v src/adder.v src/alu.v src/arm.v src/condcheck.v src/condlogic.v src/controller.v src/datapath.v src/decode.v src/dmem.v src/extend.v src/flopenr.v src/flopr.v src/imem.v src/mux2.v src/regfile.v src/top.v
vvp output
@REM gtkwave output.vcd