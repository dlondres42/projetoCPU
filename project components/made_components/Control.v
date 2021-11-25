module Control(
    input wire clk,
    input wire reset,

//flags
    input wire Of,
    input wire NG,
    input wire zero,
    input wire ET,
    input wire GT,
    input wire LT,
    input wire MultStop,
    input wire DivStop,
    input wire DivZero,

//Instruções
    input wire [5:0] OPCODE,
    input wire [5:0] FUNCT,

//Fios de controle
    // Registradores
    output reg MemWrite,
    output reg PCWrite,
    output reg IRWrite,
    output reg RegWrite,
    output reg ABWrite,
    output reg HILOWrite,
    output reg ALUoutWrite,
    output reg EPCWrite,

    // Operações
    output reg [2:0] CtrlALU,
    output reg [2:0] CtrlShift,
    output reg CtrlMult,
    output reg CtrlDiv,
    output reg [1:0] CtrlSetSize,
    output reg [1:0] CtrlLoadSize,


    // Muxes
    output reg [2:0]CtrlRegDst,
    output reg [3:0]CtrlMemtoReg,
    output reg [2:0]CtrlPCSource,
    output reg [1:0]CtrlALUSrcA,
    output reg [1:0]CtrlALUSrcB,
    output reg CtrlHILO,
    output reg CtrlShiftSrcA,
    output reg CtrlShiftSrcB,
    output reg [2:0] CtrlIord
);

//States
parameter FETCH1 = 7'd0;
parameter FETCH2 = 7'd1;
parameter FETCH3 = 7'd2;
parameter DECODE1 = 7'd3;
parameter DECODE2 = 7'd4;
parameter WAIT = 7'd5;
parameter EXECUTE = 7'd6;
parameter ADDI_ADDIU = 7'd7;
parameter ALUOUT_TO_RD = 7'd8;
parameter ALUOUT_TO_RT = 7'd22;
parameter OfEX1 = 7'd9;
parameter OfEX2 = 7'd10;
parameter DIVYBZEROEX1 = 7'd11;
parameter DIVYBZEROEX2 = 7'd12;
parameter OPCODEEX1 = 7'd13;
parameter OPCODEEX2 = 7'd14;
parameter END_EXCEPTION1 = 7'd15;
parameter END_EXCEPTION2 = 7'd16;
parameter END_EXCEPTION3 = 7'd17;
parameter END = 7'd21;
parameter MULT2 = 7'd23;
parameter MULT3 = 7'd24;
parameter SLLV2 = 7'd25;
parameter SRAV2 = 7'd26;
parameter SHIFT_END = 7'd27;
parameter SLL2 = 7'd30;
parameter SRL2 = 7'd31;
parameter SRA2 = 7'd32;
parameter XCGH2 = 7'd33;
parameter SW2 = 7'd34;
parameter SH2 = 7'd35;
parameter SB2 = 7'd36;
parameter LW2 = 7'd37;
parameter LH2 = 7'd38;
parameter LB2 = 7'd39;
parameter LW3 = 7'd40;
parameter LH3 = 7'd41;
parameter LB3 = 7'd42;
parameter JAL_END = 7'd43;
parameter SW3 = 7'd44;
parameter SW4 = 7'd45;
parameter BLM2 = 7'd46;
parameter BLM3 = 7'd47;
parameter BLM4 = 7'd48;
parameter SH3 = 7'd49;
parameter SH4 = 7'd50;
parameter SB3 = 7'd51;
parameter SB4 = 7'd52;
parameter SW5 = 7'd53;
parameter SB5 = 7'd54;
parameter SH5 = 7'd55;
parameter LW4 = 7'd56;
parameter LB4 = 7'd57;
parameter LH4 = 7'd58;
parameter BEQ2 = 7'd59;
parameter BNE2 = 7'd60;
parameter BGT2 = 7'd61;
parameter BLE2 = 7'd62;
parameter BLM5 = 7'd63;
parameter JAL2 = 7'D64;
parameter DIV2 = 7'd65;
parameter DIV3 = 7'd66;

//instr R
parameter R_FORMAT = 6'd0;
parameter ADD = 6'h20;
parameter AND = 6'h24;
parameter SUB = 6'h22;
parameter DIV = 6'h1a;
parameter MULT = 6'h18;
parameter JR = 6'h8;
parameter MFHI = 6'h10;
parameter MFLO = 6'h12;
parameter BREAK = 6'hD;
parameter RTE = 6'h13;
parameter XCGH = 6'h5;
parameter SLT = 6'h2a;
parameter SLL = 6'h0;
parameter SRL = 6'h2;
parameter SRA = 6'h3;
parameter SLLV = 6'h4;
parameter SRAV = 6'h7;

//instr I
parameter ADDI = 6'h8;
parameter ADDIU = 6'h9;
parameter BEQ = 6'h4;
parameter BNE = 6'h5;
parameter BLE = 6'h6;
parameter BGT = 6'h7;
parameter BLM = 6'h1;
parameter LB = 6'h20;
parameter LH = 6'h21;
parameter LW = 6'h23;
parameter SB = 6'h28;
parameter SH = 6'h29;
parameter SW = 6'h2B;
parameter LUI = 6'hF;
parameter SLTI = 6'hA;

// instr J
parameter J = 6'h2;
parameter JAL = 6'h3;



reg[6:0] STATE;

initial begin
    STATE = FETCH1;
end

always @(posedge clk) begin
    if(reset == 1'b1) begin // Tratar heap
        STATE = FETCH1;
        MemWrite = 0;
        PCWrite = 0;
        IRWrite = 0;
        RegWrite = 1;
        ABWrite = 0;
        HILOWrite = 0;
        ALUoutWrite = 0;
        EPCWrite = 0;
        CtrlALU = 3'd0;
        CtrlShift = 3'd0;
        CtrlMult = 0;
        CtrlDiv = 0;
        CtrlSetSize = 2'd0;
        CtrlLoadSize = 2'd0;
        CtrlRegDst = 3'd2;
        CtrlMemtoReg = 4'd8;
        CtrlPCSource = 3'd0;
        CtrlALUSrcA = 2'd0;
        CtrlALUSrcB = 2'd0;
        CtrlHILO = 0;
        CtrlShiftSrcA = 0;
        CtrlShiftSrcB = 0;
        CtrlIord = 3'd0;      
    end else begin
        case(STATE)
            FETCH1:begin
                CtrlMemtoReg = 4'd0;
                RegWrite = 0;
                CtrlRegDst = 3'd0;

                STATE = FETCH2;
                CtrlIord = 3'd0;
                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd1;
                CtrlALU = 3'd1;
                MemWrite = 0;
            end
            FETCH2:begin
                STATE = FETCH3;
                CtrlPCSource = 3'd1;
                PCWrite = 1;
            end
            FETCH3:begin
                STATE = DECODE1;
                PCWrite = 0;
                CtrlLoadSize = 2'd0;  
                CtrlSetSize = 2'd0;
                IRWrite = 1;
            end
            DECODE1:begin
                STATE = DECODE2;
                IRWrite = 0;
                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd3;
                CtrlALU = 3'd1;
                ALUoutWrite = 1;
            end
            DECODE2:begin
                STATE = EXECUTE;
                ABWrite = 1;
                ALUoutWrite = 0;
            end
            EXECUTE:begin
                ABWrite = 0;   
                case(OPCODE)
                    R_FORMAT: begin
                        case(FUNCT)
                            ADD: begin
                                STATE = ALUOUT_TO_RD;
                                CtrlALUSrcA = 2'd1;
                                CtrlALUSrcB = 2'd0;
                                CtrlALU = 3'd1;
                                ALUoutWrite = 1;
                            end
                            SUB: begin
                                STATE = ALUOUT_TO_RD;
                                CtrlALUSrcA = 2'd1;
                                CtrlALUSrcB = 2'd0;
                                CtrlALU = 3'd2;
                                ALUoutWrite = 1;
                            end
                            AND: begin
                                STATE = ALUOUT_TO_RD;
                                CtrlALUSrcA = 2'd1;
                                CtrlALUSrcB = 2'd0;
                                CtrlALU = 3'd3;
                                ALUoutWrite = 1;
                            end
                            DIV: begin
                                STATE = DIV2;
                                CtrlDiv = 1;
                            end     
                            MULT: begin
                                STATE = MULT2;
                                CtrlMult = 1;
                            end
                            JR: begin
                                STATE = END;
                                CtrlALUSrcA = 2'd1;
                                CtrlALU = 3'd0;
                                CtrlPCSource = 3'd1;
                                PCWrite = 1;
                            end
                            MFHI: begin
                                STATE = END;
                                CtrlMemtoReg = 4'd2;
                                CtrlRegDst = 3'd1;
                                RegWrite = 1;
                            end
                            MFLO: begin
                                STATE = END;
                                CtrlMemtoReg = 4'd03;
                                CtrlRegDst = 3'd1;
                                RegWrite = 1;
                            end
                            BREAK: begin
                                STATE = END;
                                CtrlALUSrcA = 2'd0;
                                CtrlALUSrcB = 2'd1;
                                CtrlALU = 3'd2;
                                CtrlPCSource = 3'd1;
                                PCWrite = 1;
                            end
                            SLT: begin
                                STATE = END;
                                CtrlALUSrcA = 2'd1;
                                CtrlALUSrcB = 2'd0;
                                CtrlALU = 3'd7;
                                CtrlRegDst = 3'd1;
                                CtrlMemtoReg = 4'd4;
                                RegWrite = 1;
                            end
                            RTE: begin
                                STATE = END;
                                CtrlPCSource = 3'd4;
                                PCWrite = 1;
                            end
                            XCGH: begin
                                STATE = XCGH2;
                                CtrlMemtoReg = 4'd09;
                                CtrlRegDst = 3'd0;
                                RegWrite = 1;
                            end
                            SLL: begin
                                CtrlShiftSrcA = 1;
                                CtrlShiftSrcB = 1;
                                CtrlShift = 3'd1;
                                STATE = SLL2;
                            end
                            SRL: begin
                                CtrlShiftSrcA = 1;
                                CtrlShiftSrcB = 1;
                                CtrlShift = 3'd1;
                                STATE = SRL2;
                            end 
                            SRA: begin
                                CtrlShiftSrcA = 1;
                                CtrlShiftSrcB = 1;
                                CtrlShift = 3'd1;
                                STATE = SRA2;
                            end 
                            SLLV: begin
                                CtrlShiftSrcA = 0;
                                CtrlShiftSrcB = 0;
                                CtrlShift = 3'd1;
                                STATE = SLLV2;
                            end
                            SRAV: begin
                                CtrlShiftSrcA = 0;
                                CtrlShiftSrcB = 0;
                                CtrlShift = 3'd1;
                                STATE = SRAV2;
                            end
                        endcase
                    end
                    ADDI, ADDIU: begin
                        STATE = ALUOUT_TO_RT;
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        ALUoutWrite = 1;
                    end
                    BEQ: begin
                       CtrlALUSrcA = 2'd1; 
                       CtrlALUSrcB = 2'd0; 
                       CtrlALU = 3'b111;
                       STATE = BEQ2;
                    end 
                    BNE: begin
                       CtrlALUSrcA = 2'd1; 
                       CtrlALUSrcB = 2'd0;  
                       CtrlALU = 3'b111;
                       STATE = BNE2;
                    end 
                   BLE: begin
                        CtrlALUSrcA = 2'd1; 
                        CtrlALUSrcB = 2'd0; 
                        CtrlALU = 3'b111;
                        STATE = BLE2;
                    end 
                    BGT: begin
                        CtrlALUSrcA = 2'd1; 
                        CtrlALUSrcB = 2'd0; 
                        CtrlALU = 3'b111;
                        STATE = BGT2;
                    end 
                    BLM: begin
                        CtrlALUSrcA = 1; 
                        CtrlALUSrcB = 1; 
                        CtrlALU = 3'b000;
                        CtrlIord = 3'd1;
                        STATE = BLM2;
                    end
                    SW: begin
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        ALUoutWrite = 1;
                        STATE = SW2;
                    end
                    SH: begin
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        ALUoutWrite = 1;
                        STATE = SH2;
                    end
                    SB: begin
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        ALUoutWrite = 1;
                        STATE = SB2;
                    end
                    LW: begin
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        CtrlIord = 1;
                        MemWrite = 0;
                        STATE = LW2;
                    end  
                    LH: begin
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        CtrlIord = 1;
                        MemWrite = 0;
                        STATE = LH2;
                    end  
                    LB: begin
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        CtrlIord = 1;
                        MemWrite = 0;
                        STATE = LB2;
                    end  
                    SLTI: begin
                        STATE = END;
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd7;
                        CtrlRegDst = 3'd0;
                        CtrlMemtoReg = 4'd4;
                        RegWrite = 1;
                    end
                    LUI: begin
                        STATE = END;
                        CtrlMemtoReg = 4'd6;
                        CtrlRegDst = 3'd0;
                        RegWrite = 1;
                    end
                    J: begin
                        STATE = END;
                        CtrlPCSource = 3'd3;
                        PCWrite = 1;
                    end 
                    JAL: begin
                        CtrlALUSrcA = 2'd0;
                        CtrlALU = 3'd0;
                        ALUoutWrite = 1;
                        STATE = JAL2;
                    end
                    default: begin// OPCODE Inexistente
                        STATE = OPCODEEX1;
                    end
                endcase 
            end 
            SW2: begin
                STATE = SW3;
                CtrlIord = 2'd2;
                MemWrite = 0;
            end
            SW3: begin
                STATE = SW4;
            end
            SW4: begin
                STATE = SW5;
            end
            SW5: begin
                STATE = END;
                CtrlSetSize = 2'd1;
                MemWrite = 1;
            end
            SH2: begin
                STATE = SH3;
                CtrlIord = 2'd2;
                MemWrite = 0;
            end
            SH3: begin
                STATE = SH4;
            end
            SH4: begin
                STATE = SH5;
            end
            SH5: begin
                STATE = END;
                CtrlSetSize = 2'd2;
                MemWrite = 1;
            end
            SB2: begin
                STATE = SB3;
                CtrlIord = 2'd2;
                MemWrite = 0;
            end
            SB3: begin
                STATE = SB4;
            end
            SB4: begin
                STATE = SB5;
            end
            SB5: begin
                STATE = END;
                CtrlSetSize = 2'd3;
                MemWrite = 1;
            end
            LW2: begin
                STATE = LW3;
            end
            LW3: begin
                STATE = LW4;
            end
            LW4: begin
                STATE = END;
                CtrlLoadSize = 2'd1;
                RegWrite = 1;
                CtrlMemtoReg = 1;
                CtrlRegDst = 0;
            end
            LH2: begin
                STATE = LH3;
            end
            LH3: begin
                STATE = LH4;
            end
            LH4: begin
                STATE = END;
                CtrlLoadSize = 2'd2;
                RegWrite = 1;
                CtrlMemtoReg = 1;
                CtrlRegDst = 0;
            end
            LB2: begin
                STATE = LB3;
            end
            LB3: begin
                STATE = LB4;
            end
            LB4: begin
                STATE = END;
                CtrlLoadSize = 2'd3;
                RegWrite = 1;
                CtrlMemtoReg = 1;
                CtrlRegDst = 0;
            end
            XCGH2: begin
                STATE = END;
                CtrlMemtoReg = 4'd10;
                CtrlRegDst = 3'd4;
            end
            MULT2: begin
                CtrlMult = 0;
                if(MultStop == 1) begin
                    STATE = MULT3;
                end
            end
            MULT3: begin
                CtrlHILO = 0;
                HILOWrite = 1;
                STATE = END;
            end
            DIV2: begin
                CtrlDiv = 0;
                if (DivZero) begin
					STATE = DIVYBZEROEX1;
                end else begin
                    if(DivStop == 1) begin
                        STATE = DIV3;
                    end 
                end
            end
            DIV3: begin
                CtrlHILO = 1;
                HILOWrite = 1;
                STATE = END;
            end
            SLLV2: begin
                CtrlShift = 3'b010;
                STATE = SHIFT_END;
            end
            SRAV2: begin
                CtrlShift = 3'b100;
                STATE = SHIFT_END;
            end
            SLL2: begin
                CtrlShift = 3'b010;
                STATE = SHIFT_END;
            end
            SRL2: begin
                CtrlShift = 3'b011;
                STATE = SHIFT_END;
            end
            SRA2: begin
                CtrlShift = 3'b100;
                STATE = SHIFT_END;
            end
            SHIFT_END: begin
                RegWrite = 1;
                CtrlMemtoReg = 4'd7;
                CtrlRegDst = 3'd1; 
                STATE = END;
            end
            JAL2: begin
                CtrlMemtoReg = 4'd0;
                CtrlRegDst = 3'd3;
                RegWrite = 1;
                STATE = JAL_END;
            end
            JAL_END: begin
                CtrlPCSource = 3'd3;
                PCWrite = 1;
                RegWrite = 0;
                STATE = END;
            end
            BEQ2: begin
                if(ET == 1) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1;
                end
                STATE = END;
            end
            BNE2: begin
                if(ET == 0) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1;
                end
                STATE = END;
            end
            BLE2: begin
                if(GT == 0) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1;
                end
                STATE = END;
            end
            BGT2: begin
                if(GT == 1) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1;
                end
                STATE = END;
            end
            BLM2: begin
                STATE = BLM3;
            end
            BLM3: begin
                STATE = BLM4;
            end
            BLM4: begin
                CtrlALUSrcA = 2'd2;
                CtrlALUSrcB = 2'd0;
                CtrlALU = 3'b111;
                STATE = BLM5; 
            end
            BLM5: begin
                if(LT == 1) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1; 
                end
                STATE = END;                
            end
            ALUOUT_TO_RD:begin
                if (Of == 1 && (FUNCT == ADD || FUNCT == SUB)) begin // Of apenas no add ou sub
                    STATE = OfEX1;
                end else begin
                    STATE = END;
                    ALUoutWrite = 0;
                    CtrlRegDst = 3'd1;
                    CtrlMemtoReg = 4'd0;
                    RegWrite = 1;
                end
            end
            ALUOUT_TO_RT:begin
                if (Of == 1 && OPCODE == ADDI) begin // Of apenas no addi
                    STATE = OfEX1;
                end else begin
                    STATE = END;
                    ALUoutWrite = 0;
                    CtrlRegDst = 3'd0;
                    CtrlMemtoReg = 4'd0;
                    RegWrite = 1;  
                end 
            end
            END: begin
                STATE = FETCH1;
                MemWrite = 0;
                PCWrite = 0;
                IRWrite = 0;
                RegWrite = 0;
                ABWrite = 0;
                HILOWrite = 0;
                ALUoutWrite = 0;
                EPCWrite = 0;
                CtrlALU = 3'd0;
                CtrlShift = 3'd0;
                CtrlMult = 0;
                CtrlDiv = 0;
                CtrlSetSize = 2'd0;
                CtrlLoadSize = 2'd0;
                CtrlRegDst = 3'd0;
                CtrlMemtoReg = 4'd0;
                CtrlPCSource = 3'd0;
                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd0;
                CtrlHILO = 0;
                CtrlShiftSrcA = 0;
                CtrlShiftSrcB = 0;
                CtrlIord = 3'd0;
            end
            OPCODEEX1: begin
                STATE = OPCODEEX2;
                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd1;
                CtrlALU = 3'd2;
                EPCWrite = 1;
            end
            OPCODEEX2: begin
                STATE = END_EXCEPTION1;
                CtrlIord=3'd3;
                MemWrite = 0;
            end
            OfEX1: begin
                STATE = OfEX2;
                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd1;
                CtrlALU = 3'd2;
                EPCWrite = 1;
            end
            OfEX2: begin
                STATE = END_EXCEPTION1;
                CtrlIord=3'd4;
                MemWrite = 0;
            end
            DIVYBZEROEX1: begin
                STATE = DIVYBZEROEX2;
                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd1;
                CtrlALU = 3'd2;
                EPCWrite = 1;
            end
            DIVYBZEROEX2: begin
                STATE = END_EXCEPTION1;
                CtrlIord=3'd5;
                MemWrite = 0;
            end
            END_EXCEPTION1: begin
                STATE = END_EXCEPTION2;//wait
            end
            END_EXCEPTION2: begin
                STATE = END_EXCEPTION3;//wait
            end
            END_EXCEPTION3: begin
                STATE = END;
                PCWrite = 1;
                CtrlPCSource = 3'd0;
                CtrlPCSource = 3'd0;
                CtrlLoadSize = 2'd3;
            end
            
        endcase
    end
end

endmodule