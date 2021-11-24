module Control (
    input wire clk,
    input wire reset,
    // flags
    input wire Of, // overflow
    input wire Ng, // negative
    input wire Zr, // zero
    input wire Eq, // equal
    input wire Gt, // greater than
    input wire Lt, // less than

    input wire [5:0] OPCODE,
    input wire [5:0] FUNCT,
    // 1 bit control wires
    output reg PC_w,
    output reg MemWR,
    output reg MemRead,
	output reg IRWrite,
	output reg RegWrite,
	output reg ABWrite,
    output reg ALUoutWrite,

    // mux control
    output reg [1:0] CtrlALUSrcA,
    output reg [1:0] CtrlALUSrcB,
    output reg [2:0] CtrlRegDst,
    output reg [2:0] CtrlPCSource,
    output reg [3:0] CtrlMemtoReg,
    output reg [2:0] CtrlIord,

   // ALU control signal
    output reg [2:0] CtrlULA //ALUOP
);

// STATE and COUNTER
reg [6:0] STATE;
reg [5:0] COUNTER;

// OPCODES
parameter OP_R =   6'b000000;

// STATES
parameter STATE_RESET =        7'b0000000;  // 0
parameter STATE_CLOSEWRITE =   7'b0000001;  // 1
parameter STATE_WAIT =         7'b0000010;  // 2
parameter STATE_FETCH1 =       7'b0000011;  // 3
parameter STATE_FETCH2 =       7'b0000100;  // 4
parameter STATE_FETCH3 =       7'b0000101;  // 5
parameter STATE_DECODE =       7'b0000110;  // 6
parameter STATE_ADD =          7'b0000111;  // 7
parameter STATE_AND =          7'b0001000;  // 8
parameter STATE_SUB =          7'b0001001;  // 9
parameter STATE_ADD_AND_SUB =  7'b0001010;  // 10

// FUNCT (for R instructions)
parameter FUNCT_ADD = 6'b100000;
parameter FUNCT_AND = 6'b100100;
parameter FUNCT_SUB = 6'b100010;


initial begin
    STATE = STATE_RESET;
end

always @(posedge clk) begin
    if (reset == 1'b1) begin
        // NEXT STATE and COUNTER
        STATE = STATE_FETCH1;
        COUNTER = 6'b000000;

        PC_w = 1'b0;
        MemWR = 1'b0; 
        IRWrite = 1'b0;
        RegWrite = 1'b1; ///
        ABWrite = 1'b0;
        ALUoutWrite = 1'b0;
        EPCWrite = 1'b0;

        CtrlALUSrcA = 2'b00;
        CtrlALUSrcB = 2'b00;
        CtrlRegDst = 3'b001; ///
        CtrlPCSource = 3'b000;
        CtrlMemtoReg = 4'b0111; ///
        CtrlIord = 3'b000;
        CtrlShifSrcA = 1'b0;
        CtrlShifSrcB = 1'b0;
        CtrlDivSrcA = 1'b0;
        CtrlDivSrcB = 2'b00;
        CtrlMuxSSrcB = 1'b0;
        CtrlULA = 3'b000;
    end
    else begin
        case (STATE)
            STATE_FETCH1: begin
                // NEXT STATE and COUNTER
                STATE = STATE_FETCH2;
                COUNTER = 6'b000000;

                PC_w = 1'b0;
                MemWR = 1'b0; /// 0 stands for READ ; 1 stands for WRITE
                IRWrite = 1'b0;
                RegWrite = 1'b0; ///
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b00; ///
                CtrlALUSrcB = 2'b01; ///
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000; ///
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b001; ///
            end
            
            STATE_FETCH2: begin
                STATE = STATE_FETCH3;
                COUNTER = 6'b000000;

                PC_w = 1'b1; ///
                MemWR = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b00;
                CtrlALUSrcB = 2'b00;
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b001; ///
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b000;
            end
            
            STATE_FETCH3: begin
                STATE = STATE_DECODE;
                COUNTER = 6'b000000;

                PC_w = 1'b0; ///
                MemWR = 1'b0;
                IRWrite = 1'b1; ///
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b00;
                CtrlALUSrcB = 2'b00;
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b000;
            end
            
            STATE_DECODE: begin
                COUNTER = 6'b000000;

                PC_w = 1'b0;
                MemWR = 1'b0;
                IRWrite = 1'b0; ///
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b1; ///
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b00; ///
                CtrlALUSrcB = 2'b11; ///
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b001; ///
                
                // CASE STATEMENT TO SELECT R INSTRUTION
                case (OPCODE)
                    OP_R: begin
                        case (FUNCT)
                            FUNCT_ADD: begin
                                STATE = STATE_ADD;
                            end

                            FUNCT_AND: begin
                                STATE = STATE_AND;
                            end

                            FUNCT_SUB: begin
                                STATE = STATE_SUB;
                            end
                        endcase
                    end
                endcase
            end

            STATE_ADD: begin
                STATE = STATE_ADD_AND_SUB;
                COUNTER = 6'b000000;

                PC_w = 1'b0;
                MemWR = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b10; ///
                CtrlALUSrcB = 2'b00; ///
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b001; ///
            end

            STATE_AND: begin
                STATE = STATE_ADD_AND_SUB;
                COUNTER = 6'b000000;

                PC_w = 1'b0;
                MemWR = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b10; ///
                CtrlALUSrcB = 2'b00; ///
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b010; ///
            end

            STATE_SUB: begin
                STATE = STATE_ADD_AND_SUB;
                COUNTER = 6'b000000;

                PC_w = 1'b0;
                MemWR = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b10; ///
                CtrlALUSrcB = 2'b00; ///
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b001; ///
            end

            STATE_ADD_AND_SUB: begin
                STATE = STATE_CLOSEWRITE;
                COUNTER = 6'b000000;

                PC_w = 1'b0;
                MemWR = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b1; ///
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b00;
                CtrlALUSrcB = 2'b00;
                CtrlRegDst = 3'b011; ///
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b1000; ///
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b000;
            end

            STATE_CLOSEWRITE: begin
                STATE = STATE_WAIT;
                COUNTER = 6'b000000;

                PC_w = 1'b0; ///
                MemWR = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0; ///
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0; ///
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b00;
                CtrlALUSrcB = 2'b00;
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b000;
            end

            STATE_WAIT: begin
                STATE = STATE_FETCH1;
                COUNTER = 6'b000000;

                PC_w = 1'b0; ///
                MemWR = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                CtrlALUSrcA = 2'b00;
                CtrlALUSrcB = 2'b00;
                CtrlRegDst = 3'b000;
                CtrlPCSource = 3'b000;
                CtrlMemtoReg = 4'b0000;
                CtrlIord = 3'b000;
                CtrlShifSrcA = 1'b0;
                CtrlShifSrcB = 1'b0;
                CtrlDivSrcA = 1'b0;
                CtrlDivSrcB = 2'b00;
                CtrlMuxSSrcB = 1'b0;
                CtrlULA = 3'b000;
            end
                
        endcase

    end
end

endmodule