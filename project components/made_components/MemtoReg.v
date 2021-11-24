module MemtoReg (
    input wire [3:0] selector,
    input wire [31:0] data0,
    input wire [31:0] data1,
    input wire [15:0] data2,
    input wire [15:0] data3,
    input wire [31:0] data4,
    input wire [31:0] data5,
    input wire [15:0] data6,
    input wire [31:0] data7,
    input wire [31:0] data8,

    output wire [31:0] data_out
);
  assign data_out = (selector == 4'b0000) ? data0 :
                   ((selector == 4'b0001) ? data1 :
                   ((selector == 4'b0010) ? {{16{1'b0}}, data2} :
                   ((selector == 4'b0011) ? {{16{1'b0}}, data3} : 
                   ((selector == 4'b0100) ? data4 :
                   ((selector == 4'b0101) ? data5 :
                   ((selector == 4'b0110) ? {{16{1'b0}}, data6} :
                 ((selector == 4'b0111) ? 32'b00000000000000000000000011100011 :
                  ((selector == 4'b1000) ? data7 : data8))))))));
    
endmodule