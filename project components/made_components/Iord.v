module Iord(
	input wire [2:0]  selector,
	input wire [31:0] PC_out,
	input wire [31:0] ALU_result,
	input wire [31:0] ALUout_out,
	output reg [31:0] data_out
);

always @(*) begin
	case(selector)
		3'b000: data_out = PC_out;
		3'b001: data_out = ALU_result;
		3'b010: data_out = ALUout_out;
		3'b011: data_out = 32'd253;
		3'b100: data_out = 32'd254;
		3'b101: data_out = 32'd255;
	endcase
end

endmodule