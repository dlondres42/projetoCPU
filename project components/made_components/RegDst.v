module RegDst(
    input wire [2:0] seletor,
    input wire [4:0] RT,
    input wire [15:0] IMMEDIATE,
    input wire [4:0] RS,
    output reg [4:0] data_out
);

always @ (*) begin
	case (selector)
        3'b000: data_out = RT;
		3'b001: data_out = 5'd29;
		3'b010: data_out = 5'd31;
		3'b011: data_out = IMMEDIATE[15:11]; // Instruction[15-11]
		3'b100: data_out = RS;
	endcase
end

endmodule
