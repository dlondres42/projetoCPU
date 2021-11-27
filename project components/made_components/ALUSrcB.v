module ALUSrcB(
    input wire [1:0]  selector,
    input wire [31:0] B_out,
    input wire [31:0] Xtend16_to_32_out,
    input wire [31:0] ShiftLeft2_out,
    output reg [31:0] data_out
);

always @(*) begin
   case (selector)
		2'd0: data_out = B_out;
		2'd1: data_out = 32'd4;
		2'd2: data_out = Xtend16_to_32_out;
        2'd3: data_out = ShiftLeft2_out;
	endcase 
end
	
endmodule
