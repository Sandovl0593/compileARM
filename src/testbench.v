`timescale 1ns / 1ps

module testbench;
    reg clk;
    reg reset;

    wire [31:0] WriteDataM;
    wire [31:0] DataAdrM;
    wire MemWriteM;
    wire [31:0] InstrF;
    wire [31:0] ReadDataM;
    wire [31:0] PCF;
    wire [3:0] ALUFlags;

    wire [31:0] InstrD, InstrE, InstrM, InstrW;

    top dut(
        .clk(clk),
        .reset(reset),
        .WriteDataM(WriteDataM),
        .DataAdrM(DataAdrM),
        .MemWriteM(MemWriteM),
        .PCF(PCF),
        .InstrF(InstrF),
        .ReadDataM(ReadDataM),
        .InstrD(InstrD),
        .InstrE(InstrE),
        .InstrM(InstrM),
        .InstrW(InstrW)
    );

    initial begin
        reset <= 1;
        #(10);
        reset <= 0;
        #150;
        $finish;
    end
    
    always begin
        clk <= 1;
        #(5);
        clk <= 0;
        #(5);
    end


    always @(negedge clk) begin
        if (MemWrite)
            if ((DataAdr === 128) & (WriteData === 254)) 
            begin
                $display("Simulation succeeded");
                #30;
                $stop;
            end
            else if ((DataAdr === 128) & (WriteData !== 255)) 
            begin
                $display("Simulation failed");
                #30;
                $stop;
            end
    end

    /* initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars;
    end */
endmodule
