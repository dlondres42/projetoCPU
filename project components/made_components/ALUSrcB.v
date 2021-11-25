module ALUSrcB(
    input wire [1:0] seletor,
    input wire [31:0] B_out,
    input wire [31:0] SignXtend16to32_out,
    input wire [31:0] ShiftLeft2_out,
    output reg [31:0] data_out
);

always@(*) begin
    case(seletor)
		2'b00: data_out = B_out;
		2'b01: data_out = 32'b00000000000000000000000000000100;
		2'b10: data_out = SignXtend16to32_out;
        2'b11: data_out = ShiftLeft2_out;
	endcase 
end
	
endmodule