module ShiftSrcB (
    input wire [1:0] selector,
    input wire [31:0] data0,
    input wire [31:0] data1,
    input wire [31:0] data2,
    input wire [31:0] data3,

    output wire [31:0] data_out
);

    assign data_out = (selector == 2'b00) ? data0 : 
                     ((selector == 2'b01) ? data1 : 
                     ((selector == 2'b10) ? data2 : data3));

endmodule