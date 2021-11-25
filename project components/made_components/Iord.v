module Iord(
	input wire [2:0] selector,
	input wire [31:0] PC_out,
	input wire [31:0] ALUout_out,
	input wire [31:0] ALU_result,
	output reg [31:0] data_out
);

always @(*) begin
	case(selector)
		3'b000: data_out = PC_out;
		3'b001: data_out = ALUout_out;
		3'b010: data_out = ALU_result;
		3'b011: data_out = 32'b00000000000000000000000011111101; // 253
		3'b100: data_out = 32'b00000000000000000000000011111110; // 254
		3'b101: data_out = 32'b00000000000000000000000011111111; // 255
	endcase
end

endmodule