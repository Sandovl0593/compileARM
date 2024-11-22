module hazardunit (
    // clk, reset,
    Match1E_M, Match1E_W, Match2E_M, Match2E_W, Match12D_E,
    BranchTakenE,
    MemtoRegE, RegWriteW, RegWriteM,
    StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE,
    // branch inputs
    PCWrPendingF, PCSrcW
);

    // input wire clk, reset;
    input wire Match1E_M, Match1E_W, Match2E_M, Match2E_W, Match12D_E;
    input wire BranchTakenE;
    input wire MemtoRegE, RegWriteW, RegWriteM;   // datapath inputs
    input wire PCWrPendingF, PCSrcW;   // branch inputs
    
    output wire StallF, StallD;
    output wire FlushD, FlushE;
    output reg [1:0] ForwardAE, ForwardBE;

    // Forwarding logic
    always@(*) begin
        if (Match1E_M & RegWriteM)
            ForwardAE = 2'b10;
        else if (Match1E_W & RegWriteW)
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;

        if (Match2E_M & RegWriteM)
            ForwardBE = 2'b10;
        else if (Match2E_W & RegWriteW)
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end

    wire LDRStall;
    // Stall logic
    assign LDRStall = Match12D_E & MemtoRegE;
    assign StallD = LDRStall;
    assign StallF = LDRStall | PCWrPendingF;
    assign FlushD = PCWrPendingF | PCSrcW | BranchTakenE;
    assign FlushE = LDRStall | BranchTakenE;

endmodule