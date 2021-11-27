module RegDst(
    input wire [2:0]  seletor,
    input wire [4:0]  RT,
    input wire [15:0] IMMEDIATE,
    input wire [4:0]  RS,
    output reg [4:0]  data_out
);

always @(*) begin
    case(seletor)
        3'd0: data_out = RT;
        3'd1: data_out = 5'd29;
        3'd2: data_out = 5'd31;
        3'd3: data_out = IMMEDIATE[15:11];
        3'd4: data_out = RS;
    endcase
end

	
endmodule
