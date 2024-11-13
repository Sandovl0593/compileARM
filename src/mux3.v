module mux3(
    d0, d1, d3, s, y
)
    input wire [31:0] d0;
    input wire [31:0] d1;
    input wire [31:0] d3;
    input wire [1:0] s;
    output wire [31:0] y

    assign y = (s1 ? d3 : (s0 ? d1 : d0));

endmodule