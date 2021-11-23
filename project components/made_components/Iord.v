module Iord (
    input wire [2:0] selector,
    input wire [31:0] data0,
    input wire [31:0] data1,
    input wire [31:0] data2,

    output wire [31:0] data_out
);



    assign  data_out =  (selector == 3'b000)? data0 :
                        ((selector == 3'b001)? data1 :
                        ((selector == 3'b010)? 32'd253 :
                        ((selector == 3'b011)? 32'd254 :
                        ((selector == 3'b100)? 32'd255 : data2))));


endmodule