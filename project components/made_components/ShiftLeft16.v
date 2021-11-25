module ShiftLeft16(
    input wire [15:0] IMMEDIATE,
    output reg [31:0] data_out
);

always @(*) begin
    data_out = {IMMEDIATE, {16{1'b0}}};
end
	
endmodule