module MuxMem(
    input wire selector,
    input wire [31:0] data0,
    input wire [31:0] data1,

    output wire [31:0] data_out
);

    assign data_out = (selector == 2'b00) ? data0 : data1;

endmodule