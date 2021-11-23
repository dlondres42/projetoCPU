module ALUSrcA(
    input wire [1:0] selector,
    input wire [31:0] data0,
    input wire [31:0] data1,
    input wire [4:0] data2,

    output wire [31:0] data_out
);

    assign data_out = (selector == 2'b00) ? data0 :
                    ((selector == 2'b01) ? data1 : data2);

endmodule