module DIV(
    input wire clk,
	input wire reset,
	input wire [31:0] a,
	input wire [31:0] b,
	input wire CtrlDiv,
	output reg DivStop,
	output reg DivZero, 
	output reg [31:0] DivHI_out,
	output reg [31:0] DivLO_out
);


integer counter = 31;
reg [31:0] quotient;
reg [31:0] remainder;
reg [31:0] dividend;
reg [31:0] divisor;
reg negative;
reg divNegative;
reg aux;

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
		aux = 1'b0;
	end
	
	// Inicio do algoritmo
	if(CtrlDiv == 1'b1) begin
		DivLO_out = 32'd0;
		DivHI_out = 32'd0;
		counter = 31;
		dividend = a;
		divisor = b;
		DivStop = 1'b0;
		if(divisor == 0) begin // Checa divByZero
			DivZero = 1'b1;
			counter = -10;
		end else begin
			aux = 1'b1;
			DivZero = 1'b0;
		end
				
		if(a[31] != b[31]) begin
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
	

  // Fim do algoritmo
	if(counter == 0) begin
		if(DivZero == 1'b0) begin
			DivLO_out = quotient;
			DivHI_out = remainder;
			if(negative == 1'b1 && DivLO_out != 0) begin
				DivLO_out = (~DivLO_out + 1);
			end
			if(divNegative == 1'b1 && DivHI_out != 0) begin
				DivHI_out = (~DivHI_out + 1);
			end
		end
		if(aux == 1'b1) begin
			DivStop = 1'b1;
			aux = 1'b0;
		end
		counter = -10;
	end
	

  // Mantém os campos limpos caso não esteja executando o algoritmo
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

endmodule: div