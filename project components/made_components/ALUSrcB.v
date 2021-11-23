module ALUSrcB(
    input wire [1:0] selector,
    input wire [31:0] data0,
    input wire [15:0] data1,
    input wire [31:0] data2,

    output wire [31:0] data_out
);

    assign data_out =   (selector == 2'b00) ? data0 : 
                        ((selector == 2'b01) ? 32'd4 : 
                        ((selector == 2'b10) ? {{16{1'b0}}, data1} : data2));



endmodule