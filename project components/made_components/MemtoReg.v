module MemtoReg(
    input wire [3:0] seletor,
    input wire [31:0] ALU_result,
    input wire [31:0] MDR_LS_out,
    input wire [31:0] LO_out,
    input wire [31:0] HI_out,
    input wire [31:0] ShiftReg_out,
    input wire [31:0] SignXtend16to32_out,
    input wire [31:0] ShiftLeft16_out,
    input wire [31:0] SignXtend1to32_out,
    input wire [31:0] A_out,
    input wire [31:0] B_out,
    output reg [31:0] data_out
);

always@(*) begin
    case(seletor)
		4'b0000: data_out = ALU_result;
		4'b0001: data_out = MDR_LS_out;
		4'b0010: data_out = LO_out;
        4'b0011: data_out = HI_out;
        4'b0100: data_out = ShiftReg_out;
		4'b0101: data_out = SignXtend16to32_out;
		4'b0110: data_out = ShiftLeft16_out;
        4'b0111: data_out = SignXtend1to32_out;
        4'b1000: data_out = 32'b00000000000000000000000011100011; // 227
		4'b1001: data_out = A_out;
		4'b1010: data_out = B_out;
	endcase
end
	
endmodule
