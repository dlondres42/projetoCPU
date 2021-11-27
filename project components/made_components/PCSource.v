module PCSource(
    input wire [2:0]  selector,
    input wire [31:0] MDR_LS_out,
    input wire [31:0] ALU_result,
    input wire [31:0] ALUout_out,
    input wire [31:0] CONCAT_out,
    input wire [31:0] EPC_out,
    output reg [31:0] data_out
);

always @(*) begin
	case(selector)
        3'd0: data_out = MDR_LS_out;
		3'd1: data_out = ALU_result;
		3'd2: data_out = ALUout_out;
		3'd3: data_out = CONCAT_out;
		3'd4: data_out = EPC_out;
	endcase
end	

endmodule