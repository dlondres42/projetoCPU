module MuxHI(
    input wire seletor,
    input wire [31:0] DivHI_out,
    input wire [31:0] MultHI_out,
    output reg [31:0] data_out
);

always @(*) begin
	case(seletor)
		1'b00: data_out = DivHI_out;
		1'b01: data_out = MultHI_out;
	endcase
end

endmodule