module ALUSrcA(
    input wire [1:0] seletor,
    input wire [31:0] PC_out,
    input wire [31:0] MDR_out,
    input wire [31:0] A_out,
    output reg [31:0] data_out
);

always@(*) begin
    case(seletor)
        2'b00: data_out = PC_out;
        2'b01: data_out = MDR_out;
        2'b11: data_out = A_out;
    endcase
end

endmodule