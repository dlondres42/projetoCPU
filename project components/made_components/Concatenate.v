module CONCATENATE(
    input wire [31:0] PC_out,
    input wire [4:0] RS,
    input wire [4:0] RT,
    input wire [15:0] IMMEDIATE,
    output reg [31:0] data_out
);

reg [27:0] RT_temp;
reg [27:0] RS_temp;

always @ (*) begin
	// shifting registers
	RT_temp = (RT << 16);
	RS_temp = (RS << 21);

	// concatenating immediate
	data_out = (32'b00000000000000000000000000000000 + IMMEDIATE);
	data_out = (data_out + RT_temp + RS_temp);
	data_out = (data_out << 2);

	// concatenating PC[31:28]
	data_out[31] = (PC_out[31]);
	data_out[30] = (PC_out[30]);
	data_out[29] = (PC_out[29]);
	data_out[28] = (PC_out[28]);
end		

endmodule