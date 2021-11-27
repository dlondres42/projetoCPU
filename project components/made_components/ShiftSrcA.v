module ShiftSrcA(
    input wire selector,
    input wire [31:0] A_out,
    input wire [31:0] B_out,
    output reg [31:0] data_out
);

always @(*) begin
    case(selector)
		2'd0: data_out = A_out;
	    2'd1: data_out = B_out;
	endcase
end

endmodule