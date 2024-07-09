module testbench;
    reg clk;
    reg reset;
    wire [31:0] WriteData;
    wire [31:0] DataAdr;
    wire MemWrite;
    wire [31:0] Instr;
    wire [31:0] ReadData;
    wire [31:0] PC;
    top dut(
        .clk(clk),
        .reset(reset),
        .WriteData(WriteData),
        .DataAdr(DataAdr),
        .MemWrite(MemWrite),
        .PC(PC),
        .Instr(Instr),
        .ReadData(ReadData),
        .ALUFlags(ALUFlags)
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

/*
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
    end */

    /*initial begin
        $dumpfile("lab5.vcd");
        $dumpvars;
    end */
endmodule
