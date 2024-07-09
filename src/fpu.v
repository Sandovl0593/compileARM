module fpu (
    input wire [31:0] A, B,
    input wire [1:0] FPUControl,
    output wire [31:0] result,
);
    wire [31:0] fadd16Value;
    wire [31:0] fadd32Value;
    wire [31:0] fmul16Value;
    wire [31:0] fmul32Value;

    // evaluate fadd16 or fadd32 or fmul16 or fmul32
    fadd16 fadd16Module (
        .A(A[15:0]),
        .B(B[15:0]),
        .Result(fadd16Value)
    );

    fadd32 fadd32Module (
        .A(A),
        .B(B),
        .Result(fadd32Value)
    );

    fmul16 fmul16Module (
        .A(A[15:0]),
        .B(B[15:0]),
        .Result(fmul16Value)
    );

    fmul32 fmul32Module (
        .A(A),
        .B(B),
        .Result(fmul32Value)
    );

    // select the result
    always @(*) begin
        case (FPUControl)
            2'b00: result = fadd16Value;
            2'b01: result = fadd32Value;
            2'b10: result = fmul16Value;
            2'b11: result = fmul32Value;
        endcase
    end
    
endmodule