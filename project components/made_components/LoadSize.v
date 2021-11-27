module LoadSize(
    input wire [1:0]  selector,
	input wire [31:0] data0,
	output reg [31:0] data_out
);

always @(*) begin
    case(selector)
        2'b01: data_out = data0;
        2'b10: data_out = {16'b0, data0[15:0]};
        2'b11: data_out = {24'b0, data0[7:0]};
    endcase
end

endmodule