module PCSource (
    input wire [2:0] selector,
    input wire [31:0] data0,
    input wire [31:0] data1,
    input wire [31:0] data2,
    input wire [31:0] data3,
    input wire [31:0] data4,

    output wire [31:0] data_out
);


    assign data_out = (selector == 3'b000) ? data0 :
                     ((selector == 3'b001) ? data1 :
                     ((selector == 3'b010) ? data2 :
                     ((selector == 3'b011) ? data3 : data4)));

endmodule