module MemtoReg(
    input wire [3:0] selector,
    input wire [31:0] ALU_out,
    input wire [31:0] LoadSize_out,
    input wire [31:0] HI_out,
    input wire [31:0] LO_out,
    input wire [31:0] EXT1_32_out,
    input wire [31:0] EXT16_32_out,
    input wire [31:0] SLEFT_16_out,
    input wire [31:0] SHIFT_REG_out,
    input wire [31:0] A_out,
    input wire [31:0] B_out,
    output reg [31:0] data_out
);

always @(*) begin
    case(selector)
	    4'd0:  data_out = ALU_out;
		4'd1:  data_out = LoadSize_out;
		4'd2:  data_out = HI_out;
        4'd3:  data_out = LO_out;
        4'd4:  data_out = EXT1_32_out;
		4'd5:  data_out = EXT16_32_out;
		4'd6:  data_out = SLEFT_16_out;
        4'd7:  data_out = SHIFT_REG_out;
        4'd8:  data_out = 32'd227;
		4'd9:  data_out = A_out;
		4'd10: data_out = B_out;
	endcase
end
	
endmodule