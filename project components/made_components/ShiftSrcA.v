module ShiftSrcA(
    input wire seletor,
    input wire [31:0] B_out,
    input wire [31:0] A_out,
    output reg [31:0] data_out
);

always@(*)begin
    case (seletor)
		2'b00: data_out = B_out;
		2'b10: data_out = A_out;
	endcase
end
endmodule