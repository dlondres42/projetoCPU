module ShiftLeft2(
    input wire [31:0] SignXtend16to32_out,
    output reg [31:0] data_out
);

always @(*) begin
    data_out = SignXtend16to32_out << 2;
end

endmodule