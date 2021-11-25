module SignXtend1to32(
    input wire LT,
    output reg [31:0] data_out
);

always@(*) begin
    data_out = (32'b00000000000000000000000000000000 + LT);
end

endmodule