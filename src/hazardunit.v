module hazardunit (
    clk, reset,
    Match1E_M, Match1E_W, Match2E_M, Match2E_W, Match12D_E,
    BranchTakenE,
    MemtoRegE, RegWriteW, RegWriteM,
    StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE,
);

    input wire clk, reset;
    input wire Match1E_M, Match1E_W, Match2E_M, Match2E_W, Match12D_E;
    input wire BranchTakenE;
    input wire MemtoRegE, RegWriteW, RegWriteM;   // datapath inputs

    output wire StallF, StallD;
    output wire FlushD, FlushE;
    output reg [1:0] ForwardAE, ForwardBE;


    /// FALTA

endmodule