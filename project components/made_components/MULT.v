module MULT(
	input wire clk,
	input wire reset,
	input wire [31:0] a,
	input wire [31:0] b,
	input wire CtrlMult,
	output reg MultStop,
	output reg [31:0] MultHI_out,
	output reg [31:0] MultLO_out
);

reg [64:0] sum;
reg [64:0] sub;
reg [64:0] multiplication;
reg [31:0] negative;
reg aux;
integer counter = 0;

initial begin
	MultStop = 1'b0;
	aux = 1'b0;
end 

always @ (posedge clk) begin
	if(reset == 1)begin
		MultStop = 1'b0;
		sum = 65'd0;
		sub = 65'd0;
		multiplication = 65'd0;
		negative = 65'd0;
		counter = 0;
		MultHI_out = 32'd0;
	  MultLO_out = 32'd0;
	end

  // Começa o algoritmo
	if(CtrlMult == 1'b1) begin
		negative = (~a + 1'b1);
		sum = {a,33'b0};
		sub = {negative, 33'b0};
		multiplication = {32'b0, b, 1'b0};
		counter = 33;
		MultStop = 1'b0;
		aux = 1'b1;	
	end

	
	if(counter > 1) begin
		case(multiplication[1:0])
			2'b01: begin
				multiplication = multiplication + sum;
			end
			2'b10: begin
				multiplication = multiplication + sub;
			end		
		endcase
		
		multiplication = (multiplication >> 1);
		if(multiplication[63] == 1'b1) begin
			multiplication[64] = 1'b1;
		end	

		counter = (counter - 1);
	end

  // Fim do algoritmo
	if(counter == 1) begin
		MultHI_out = multiplication[64:33];
		MultLO_out = multiplication[32:1];
		counter = 0;
		if (aux == 1) begin
		   MultStop = 1'b1;
		   aux = 0;	
		end		
	end	

  // Mantém os campos limpos caso não esteja executando o algoritmo
	if(counter == 0) begin
		sum = 65'd0;
		negative = 32'd0;
		sub = 65'd0;
		multiplication = 65'd0;
	end
end

endmodule