module hazardunit (
    input wire Match1E_M, Match1E_W, Match2E_M, Match2E_W, Match12D_E,
    input wire BranchTakenE,
    input wire MemtoRegE, RegWriteW, RegWriteM, PCWrPendingF, PCSrcW,
    input wire PredictTaken,  // Salida del predictor
    input wire BranchTaken,   // Resultado real del branch
    output wire StallF, StallD, FlushD, FlushE,
    output reg [1:0] ForwardAE, ForwardBE
);

    wire LDRStall;
    assign LDRStall = Match12D_E & MemtoRegE;

    // Stall logic
    assign StallD = LDRStall;
    assign StallF = LDRStall | PCWrPendingF;

    // Flush logic: manejar branches incorrectos
    assign FlushD = (PredictTaken != BranchTaken) | PCSrcW | PCWrPendingF;
    assign FlushE = LDRStall | BranchTakenE;

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
endmodule
