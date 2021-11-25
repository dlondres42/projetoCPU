module SetSize(
    input wire [1:0] seletor,
    input wire [31:0] B_out,
    input wire [31:0] MDR_out,
    output reg [31:0] data_out
);

always @(*) begin
    case(seletor)
        2'b01: data_out = B_out;
        2'b10: data_out = {MDR_out[31:16], B_out[15:0]};
        2'b11: data_out = {MDR_out[31:8], B_out[7:0]};
    endcase
end

endmodule