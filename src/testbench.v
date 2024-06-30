`include "src/top.v"

module testbench;
    reg clk;
    reg reset;
    wire [31:0] WriteData;
    wire [31:0] Adr;
    wire MemWrite;

    top dut(
        .clk(clk),
        .reset(reset),
        .WriteData(WriteData),
        .Adr(Adr),
        .MemWrite(MemWrite)
    );
    initial begin
        reset <= 1;
        #(22)
            ;
        reset <= 0;
    end
    always begin
        clk <= 1;
        #(5)
            ;
        clk <= 0;
        #(5)
            ;
    end
    always @(negedge clk)
        if (MemWrite)
            if ((Adr === 100) & (WriteData === 7)) begin
                $display("Simulation succeeded");
                $stop;
            end
            else if (Adr !== 96) begin
                $display("Simulation failed");
                $stop;
            end
            
    initial begin
        $dumpfile("output.vcd");
        $dumpvars;
    end
endmodule