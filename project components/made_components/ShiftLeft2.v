module ShiftLeft2(
    input wire [31:0] Xtend16_to_32_out,
    output reg [31:0] data_out
);

always @(*) begin
    data_out = Xtend16_to_32_out << 2;
end

endmodule