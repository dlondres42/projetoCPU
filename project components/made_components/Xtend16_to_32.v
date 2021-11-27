module Xtend16_to_32(
    input wire [15:0]  IMMEDIATE,
    output wire [31:0] data_out
);
    assign data_out = (IMMEDIATE[15]) ? {{16{1'b1}},IMMEDIATE} : {{16{1'b0}},IMMEDIATE};

endmodule