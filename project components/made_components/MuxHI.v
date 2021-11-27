module MuxHI(
    input wire selector,
    input wire [31:0] MULT,
    input wire [31:0] DIV,
    output reg [31:0] data_out
);

always @(*) begin
	case (selector)
	    1'd0: data_out = MULT;
		1'd1: data_out = DIV;
	endcase
end

endmodule