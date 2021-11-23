module RegDst (
    input wire [2:0] selector,
    input wire [4:0] data0,
    input wire [15:0] data1,
    input wire [31:0] data2,

    output wire [31:0] data_out
);

    assign data_out = (selector == 3'b000) ? data0 :
                    ((selector == 3'b001) ? 31'd29 :
                    ((selector == 3'b010) ? 31'd31 :
                    ((selector == 3'b011) ? data1  : data2)));

endmodule