module RegDst (
    input wire [2:0] selector,
    input wire [4:0] data0,
    input wire [4:0] data1,

    output wire [4:0] data_out
);

    assign data_out = (selector == 3'b000) ? data0 :
                    ((selector == 3'b001) ? 5'b11101 :
                    ((selector == 3'b010) ? 5'b11111 : data1));

endmodule