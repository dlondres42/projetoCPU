module SetSize(
input wire [1:0]  selector,
input wire [31:0] data0,
input wire [31:0] data1,
output reg [31:0] data_out
);

always @(*) begin
    case(selector)
        2'b01: data_out = data0;
        2'b10: data_out = {data1[31:16], data0[15:0]};
        2'b11: data_out = {data1[31:8], data0[7:0]};
    endcase
end

endmodule