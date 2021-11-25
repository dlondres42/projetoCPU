module ShiftSrcB(
    input wire seletor,
    input wire [31:0] B_out, 
    input wire [15:0] IMMEDIATE,
    output reg [4:0] data_out
);

always@(*) begin
    case(seletor)
		2'b00: data_out = B_out[4:0];
		2'b01: data_out = IMMEDIATE[10:6];
	endcase
end

endmodule