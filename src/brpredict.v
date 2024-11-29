module brpredict (
    clk, reset, taken, out_taken
);
    input wire clk;
    input wire reset;
    input wire taken;
    output reg out_taken;

    parameter STRONGLY_NOT_TAKEN = 2'b00;
    parameter WEAKLY_NOT_TAKEN = 2'b01;
    parameter WEAKLY_TAKEN = 2'b10;
    parameter STRONGLY_TAKEN = 2'b11;

    reg [1:0] state, next_state;

    // next_state logic
    always @(*) begin
        case (state)
            STRONGLY_NOT_TAKEN: 
                next_state = taken ? WEAKLY_NOT_TAKEN : STRONGLY_NOT_TAKEN;
            WEAKLY_NOT_TAKEN:
                next_state = taken ? WEAKLY_TAKEN : STRONGLY_NOT_TAKEN;
            WEAKLY_TAKEN:
                next_state = taken ? STRONGLY_TAKEN : WEAKLY_NOT_TAKEN;
            STRONGLY_TAKEN: 
                next_state = taken ? STRONGLY_TAKEN : WEAKLY_TAKEN;
            default:   
                next_state = STRONGLY_NOT_TAKEN;
        endcase
    end

    // register
    always @(posedge clk or posedge reset) begin
        if (reset)
            state <= STRONGLY_NOT_TAKEN;
        else
            state <= next_state;
    end

    // output logic
    always @(*) begin
        out_taken = (state == WEAKLY_TAKEN || state == STRONGLY_TAKEN);
    end


endmodule