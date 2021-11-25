module MuxLO(
    input wire seletor,
    input wire [31:0] DivLO_out,
    input wire [31:0] MultLO_out,
    output reg [31:0] data_out
);

always @(*) begin
    case(seletor)
		1'b00: data_out = DivLO_out;
		1'b01: data_out = MultLO_out;
	endcase
end
	
endmodule