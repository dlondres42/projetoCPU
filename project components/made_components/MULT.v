module MULT(
	input wire clk,
	input wire reset,
	input wire [31:0] A,
	input wire [31:0] B,
	input wire CtrlMult,
	output reg MultStop,
	output reg [31:0] HI,
	output reg [31:0] LO
);

reg [64:0] sum;
reg [64:0] sub;
reg [64:0] product;
reg [31:0] negative;
reg temp;
integer counter = 0;

initial begin
	MultStop = 1'b0;
	temp = 1'b0;
end 

always @(posedge clk) begin
	if(reset == 1)begin
		MultStop = 1'b0;
		sum = 65'd0;
		sub = 65'd0;
		product = 65'd0;
		negative = 65'd0;
		counter = 0;
		HI = 32'd0;
	  LO = 32'd0;
	end

	if(CtrlMult == 1'b1) begin
		negative = (~A + 1'b1);
		sum = {A,33'b0};
		sub = {negative, 33'b0};
		product = {32'b0, B, 1'b0};
		counter = 33;
		MultStop = 1'b0;
		temp = 1'b1;	
	end
	
	if(counter > 1) begin
		case(product[1:0])
			2'b01: begin
				product = product + sum;
			end
			2'b10: begin
				product = product + sub;
			end		
		endcase
		
		product = (product >> 1);
		if(product[63] == 1'b1) begin
			product[64] = 1'b1;
		end	

		counter = (counter - 1);
	end

	if(counter == 1) begin
		HI = product[64:33];
		LO = product[32:1];
		counter = 0;
		if (temp == 1) begin
		   MultStop = 1'b1;
		   temp = 0;	
		end		
	end	

	if(counter == 0) begin
		sum = 65'd0;
		sub = 65'd0;
		product = 65'd0;
		negative = 32'd0;
	end
end

endmodule