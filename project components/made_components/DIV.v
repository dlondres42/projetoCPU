module DIV(
    input wire clk,
	input wire reset,
	input wire [31:0] A,
	input wire [31:0] B,
	input wire CtrlDiv,
	output reg DivStop,
	output reg DivZero, 
	output reg [31:0] HI,
	output reg [31:0] LO
);

reg [31:0] quotient;
reg [31:0] remainder;
reg [31:0] dividend;
reg [31:0] divisor;
reg negative;
reg divNegative;
reg temp;
integer counter = 31; // wait counter


initial begin
	DivStop = 1'b0;
	DivZero = 0;
end

always @ (posedge clk) begin
	if(reset == 1'b1) begin
		quotient = 32'b0;
		remainder = 32'b0;
		dividend = 32'b0;
		divisor = 32'b0;
		negative = 1'b0;
		divNegative = 1'b0;
		counter = 0;
		temp = 1'b0;
	end

	if(CtrlDiv == 1'b1) begin
		LO = 32'd0;
		HI = 32'd0;
		counter = 31;
		dividend = A;
		divisor = B;
		DivStop = 1'b0;
		if(divisor == 0) begin
			DivZero = 1'b1;
			counter = -10;
		end else begin
			temp = 1'b1;
			DivZero = 1'b0;
		end
				
		if(A[31] != B[31]) begin
			negative = 1'b1;
		end else begin
			negative = 1'b0;
		end

		if(dividend[31] == 1'b1) begin
			dividend = (~dividend + 32'd1);
			divNegative = 1'b1;
		end else begin
			divNegative = 1'b0;
		end

		if(divisor[31] == 1'b1) begin
			divisor = (~divisor + 32'd1);
		end

		quotient = 32'b0;
		remainder = 32'b0;				
    end else begin
        DivZero = 1'b0;
    end
	
	remainder = (remainder << 1);
	remainder[0] = dividend[counter];
	
	if(remainder >= divisor) begin
		remainder = remainder - divisor;
		quotient[counter] = 1;
	end	
	
	if(counter == 0) begin
		if(DivZero == 1'b0) begin
			LO = quotient;
			HI = remainder;
			if(negative == 1'b1 && LO != 0) begin
				LO = (~LO + 1);
			end
			if(divNegative == 1'b1 && HI != 0) begin
				HI = (~HI + 1);
			end
		end
		if(temp == 1'b1) begin
			DivStop = 1'b1;
			temp = 1'b0;
		end
		counter = -10;
	end
	

	if(counter == -10) begin
		quotient = 32'b0;
		remainder = 32'b0;
		dividend = 32'b0;
		divisor = 32'b0;
		negative = 1'b0;
		counter = 0;
	end

	counter = (counter - 1);
end

endmodule