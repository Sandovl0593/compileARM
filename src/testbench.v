`timescale 1ns/1ps

module testbench;
    reg clk;
    reg reset;

    wire [31:0] WriteDataM;
    wire [31:0] DataAdrM;
    wire [31:0] InstrF;
    wire [31:0] ReadDataM;
    wire MemWriteM;
    wire [31:0] PCF;

    wire [31:0] InstrD, InstrE, InstrM, InstrW;

    top dut(
        .clk(clk),
        .reset(reset),
        .WriteDataM(WriteDataM),
        .MemWriteM(MemWriteM),
        .DataAdrM(DataAdrM),
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
        if (MemWriteM)
            if ((DataAdrM === 128) & (WriteDataM === 254)) 
            begin
                $display("Simulation succeeded");
                #30;
                $stop;
            end
            else if ((DataAdrM === 128) & (WriteDataM !== 255)) 
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
