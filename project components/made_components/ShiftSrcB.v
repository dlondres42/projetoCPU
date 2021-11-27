module ShiftSrcB(
    input wire selector,
    input wire [31:0] B_out, 
    input wire [15:0] IMMEDIATE,
    output reg [4:0]  data_out
);

always @(*) begin
    case(selector)
		2'd0: data_out = B_out[4:0];
		2'd1: data_out = IMMEDIATE[10:6];
	endcase
end

endmodule