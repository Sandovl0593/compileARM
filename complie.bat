@echo off

REM run arm.py with arg a asm file
python arm.py %1

REM execute testbench.v with iverilog and vvp
iverilog -o output src\testbench.v
vvp output