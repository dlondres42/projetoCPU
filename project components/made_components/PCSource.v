module PCSource(
    input wire [2:0] selector,
    input wire [31:0] MDR_LS_out,
    input wire [31:0] ALU_result,
    input wire [31:0] ALUout_out,
    input wire [31:0] Concatenate_out,
    input wire [31:0] EPC_out,
    output reg [31:0] data_out
);


always @(*) begin
    case(selector)
        3'b000:data_out = MDR_LS_out; // exception destiny
		3'b001:data_out = ALU_result;
		3'b010:data_out = ALUout_out;
		3'b011:data_out = Concatenate_out;
		3'b100:data_out = EPC_out;
	endcase
end

endmodule