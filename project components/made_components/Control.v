module Control(
    input wire clk,
    input wire reset,

    // ALU flags
    input wire Of,
    input wire NG,
    input wire Zero,
    input wire ET,
    input wire GT,
    input wire LT,

    // WRITEs
    output reg MemWrite,
    output reg PCWrite,
    output reg IRWrite,
    output reg RegWrite,
    output reg ABWrite,
    output reg ALUoutWrite,
    output reg EPCWrite,
    output reg HILOWrite,

    // Controls
    output reg [2:0] CtrlALU,
    output reg [2:0] CtrlShift,
    output reg [1:0] CtrlSetSize,
    output reg [1:0] CtrlLoadSize,
    output reg [2:0] CtrlRegDst,
    output reg [3:0] CtrlMemtoReg,
    output reg [2:0] CtrlPCSource,
    output reg [1:0] CtrlALUSrcA,
    output reg [1:0] CtrlALUSrcB,
    output reg CtrlHILO,
    output reg CtrlShiftSrcA,
    output reg CtrlShiftSrcB,
    output reg [2:0] CtrlIord,
    output reg CtrlMult,
    output reg CtrlDiv,

    // DIV and MULT flags
    input wire MultStop,
    input wire DivStop,
    input wire DivZero,

    // Instruction
    input wire [5:0] OPCODE,
    input wire [5:0] FUNCT
);

// STATES
parameter FETCH1 = 7'd0;
parameter FETCH2 = 7'd1;
parameter FETCH3 = 7'd2;
parameter DECODE1 = 7'd3;
parameter DECODE2 = 7'd4;
parameter WAIT = 7'd5;
parameter EXECUTE = 7'd6;
parameter ADDI_ADDIU = 7'd7;
parameter ADD_SUB_AND = 7'd8;
parameter OfEX1 = 7'd9;
parameter OfEX2 = 7'd10;
parameter DIVYBZEROEX1 = 7'd11;
parameter DIVYBZEROEX2 = 7'd12;
parameter OPCODEEX1 = 7'd13;
parameter OPCODEEX2 = 7'd14;
parameter END_EXCEPTION1 = 7'd15;
parameter END_EXCEPTION2 = 7'd16;
parameter END_EXCEPTION3 = 7'd17;
parameter CLOSE_WRITE = 7'd21;
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
parameter JAL2 = 7'd64;
parameter DIV2 = 7'd65;
parameter DIV3 = 7'd66;

parameter R_FORMAT = 6'd0; // OPCODE FOR INSTRUCTION R
// FUNCT FOR R INSTRUCTIONS
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

// FOR I INSTRUCTIONS
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

// FOR J INSTRUCTIONS
parameter J = 6'h2;
parameter JAL = 6'h3;

reg [6:0] CURRENT_STATE;

initial begin
    CURRENT_STATE = FETCH1;
end

always @(posedge clk) begin
    if(reset == 1'b1) begin
        CURRENT_STATE = FETCH1;

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
        case(CURRENT_STATE)

            FETCH1: begin
                CURRENT_STATE = FETCH2;

                RegWrite = 0; ///
                CtrlIord = 3'd0; ///
                CtrlALUSrcA = 2'd0; ///
                CtrlALUSrcB = 2'd1; ///
                CtrlALU = 3'd1; ///
                MemWrite = 0; ///
            end

            FETCH2: begin
                CURRENT_STATE = FETCH3;

                CtrlPCSource = 3'd1; ///
                PCWrite = 1; ///
            end

            FETCH3: begin
                CURRENT_STATE = DECODE1;

                PCWrite = 0; ///
                IRWrite = 1; ///
            end

            DECODE1: begin
                CURRENT_STATE = DECODE2;

                IRWrite = 0; ///
                CtrlALUSrcA = 2'd0; ///
                CtrlALUSrcB = 2'd3; ///
                CtrlALU = 3'd1; ///
                ALUoutWrite = 1; ///
            end

            DECODE2: begin
                CURRENT_STATE = EXECUTE;

                ABWrite = 1; ///
                ALUoutWrite = 0; ///
            end

            EXECUTE: begin  
                case(OPCODE)
                    R_FORMAT: begin
                        case(FUNCT) // CHECKING FUNCT OF R INSTRUCTION
                            ADD: begin
                                CURRENT_STATE = ADD_SUB_AND;

                                CtrlALUSrcA = 2'd1; ///
                                CtrlALUSrcB = 2'd0; ///
                                CtrlALU = 3'd1; ///
                                ALUoutWrite = 1;
                            end

                            SUB: begin
                                CURRENT_STATE = ADD_SUB_AND;

                                CtrlALUSrcA = 2'd1; ///
                                CtrlALUSrcB = 2'd0; ///
                                CtrlALU = 3'd2; ///
                                ALUoutWrite = 1;
                            end

                            AND: begin
                                CURRENT_STATE = ADD_SUB_AND;

                                CtrlALUSrcA = 2'd1; ///
                                CtrlALUSrcB = 2'd0; ///
                                CtrlALU = 3'd3; ///
                                ALUoutWrite = 1;
                            end

                            DIV: begin
                                CURRENT_STATE = DIV2;

                                CtrlDiv = 1;
                            end

                            MULT: begin
                                CURRENT_STATE = MULT2;
                                
                                CtrlMult = 1;
                            end

                            MFHI: begin
                                CURRENT_STATE = CLOSE_WRITE;

                                CtrlMemtoReg = 4'd2;
                                CtrlRegDst = 3'd1;
                                RegWrite = 1;
                            end

                            MFLO: begin
                                CURRENT_STATE = CLOSE_WRITE;

                                CtrlMemtoReg = 4'd03;
                                CtrlRegDst = 3'd1;
                                RegWrite = 1;
                            end
                            
                            JR: begin
                                CURRENT_STATE = CLOSE_WRITE;

                                CtrlALUSrcA = 2'd1;
                                CtrlALU = 3'd0;
                                CtrlPCSource = 3'd1;
                                PCWrite = 1;
                            end

                            BREAK: begin
                                CURRENT_STATE = CLOSE_WRITE;

                                CtrlALUSrcA = 2'd0;
                                CtrlALUSrcB = 2'd1;
                                CtrlALU = 3'd2;
                                CtrlPCSource = 3'd1;
                                PCWrite = 1;
                            end

                            RTE: begin
                                CURRENT_STATE = CLOSE_WRITE;

                                CtrlPCSource = 3'd4;
                                PCWrite = 1;
                            end

                            XCGH: begin
                                CURRENT_STATE = XCGH2;

                                CtrlMemtoReg = 4'd09;
                                CtrlRegDst = 3'd0;
                                RegWrite = 1;
                            end

                            SLT: begin
                                CURRENT_STATE = CLOSE_WRITE;

                                CtrlALUSrcA = 2'd1;
                                CtrlALUSrcB = 2'd0;
                                CtrlALU = 3'd7;
                                CtrlRegDst = 3'd1;
                                CtrlMemtoReg = 4'd4;
                                RegWrite = 1;
                            end

                            SLL: begin
                                CURRENT_STATE = SLL2;

                                CtrlShiftSrcA = 1;
                                CtrlShiftSrcB = 1;
                                CtrlShift = 3'd1;
                            end

                            SLLV: begin
                                CURRENT_STATE = SLLV2;

                                CtrlShiftSrcA = 0;
                                CtrlShiftSrcB = 0;
                                CtrlShift = 3'd1;
                            end

                            SRL: begin
                                CURRENT_STATE = SRL2;

                                CtrlShiftSrcA = 1;
                                CtrlShiftSrcB = 1;
                                CtrlShift = 3'd1;
                            end

                            SRA: begin
                                CURRENT_STATE = SRA2;

                                CtrlShiftSrcA = 1;
                                CtrlShiftSrcB = 1;
                                CtrlShift = 3'd1;
                            end

                            SRAV: begin
                                CURRENT_STATE = SRAV2;
                                
                                CtrlShiftSrcA = 0;
                                CtrlShiftSrcB = 0;
                                CtrlShift = 3'd1;
                            end
                        endcase
                    end

                    ADDIU, ADDI: begin
                        CURRENT_STATE = ADDI_ADDIU;

                        CtrlALUSrcA = 2'd1; ///
                        CtrlALUSrcB = 2'd2; ///
                        CtrlALU = 3'd1; ///
                        ALUoutWrite = 1; ///
                    end

                    BLE: begin
                        CURRENT_STATE = BLE2;
                        
                        CtrlALUSrcA = 2'd1; 
                        CtrlALUSrcB = 2'd0; 
                        CtrlALU = 3'b111;
                    end

                    BGT: begin
                        CURRENT_STATE = BGT2;

                        CtrlALUSrcA = 2'd1; 
                        CtrlALUSrcB = 2'd0; 
                        CtrlALU = 3'b111;
                    end

                    BEQ: begin
                        CURRENT_STATE = BEQ2;

                        CtrlALUSrcA = 2'd1; 
                        CtrlALUSrcB = 2'd0; 
                        CtrlALU = 3'b111;
                    end

                    BNE: begin
                        CURRENT_STATE = BNE2;

                        CtrlALUSrcA = 2'd1; 
                        CtrlALUSrcB = 2'd0;  
                        CtrlALU = 3'b111;
                    end

                    BLM: begin
                        CURRENT_STATE = BLM2;

                        CtrlALUSrcA = 1; 
                        CtrlALUSrcB = 1; 
                        CtrlALU = 3'b000;
                        CtrlIord = 3'd1;
                    end

                    SW: begin
                        CURRENT_STATE = SW2;

                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        ALUoutWrite = 1;
                    end

                    SH: begin
                        CURRENT_STATE = SH2;
                        
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        ALUoutWrite = 1;
                    end

                    SB: begin
                        CURRENT_STATE = SB2;
                        
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        ALUoutWrite = 1;
                    end

                    LW: begin
                        CURRENT_STATE = LW2;
                        
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        CtrlIord = 1;
                        MemWrite = 0;
                    end

                    LH: begin
                        CURRENT_STATE = LH2;

                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        CtrlIord = 1;
                        MemWrite = 0;
                    end

                    LB: begin
                        CURRENT_STATE = LB2;
                        
                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd1;
                        CtrlIord = 1;
                        MemWrite = 0;
                    end

                    SLTI: begin
                        CURRENT_STATE = CLOSE_WRITE;

                        CtrlALUSrcA = 2'd1;
                        CtrlALUSrcB = 2'd2;
                        CtrlALU = 3'd7;
                        CtrlRegDst = 3'd0;
                        CtrlMemtoReg = 4'd4;
                        RegWrite = 1;
                    end

                    LUI: begin
                        CURRENT_STATE = CLOSE_WRITE;

                        CtrlMemtoReg = 4'd6;
                        CtrlRegDst = 3'd0;
                        RegWrite = 1;
                    end

                    J: begin
                        CURRENT_STATE = CLOSE_WRITE;

                        CtrlPCSource = 3'd3;
                        PCWrite = 1;
                    end

                    JAL: begin
                        CURRENT_STATE = JAL2;
                        
                        CtrlALUSrcA = 2'd0;
                        CtrlALU = 3'd0;
                        ALUoutWrite = 1;
                    end
                    default: begin
                        CURRENT_STATE = OPCODEEX1;
                    end
                endcase 
            end 
            
            SW2: begin
                CURRENT_STATE = SW3;

                CtrlIord = 2'd2;
                MemWrite = 0;
            end
            
            SW3: begin
                CURRENT_STATE = SW4;
            end
            
            SW4: begin
                CURRENT_STATE = SW5;
            end
            
            SW5: begin
                CURRENT_STATE = CLOSE_WRITE;

                CtrlSetSize = 2'd1;
                MemWrite = 1;
            end
            
            SH2: begin
                CURRENT_STATE = SH3;

                CtrlIord = 2'd2;
                MemWrite = 0;
            end
            
            SH3: begin
                CURRENT_STATE = SH4;
            end
            
            SH4: begin
                CURRENT_STATE = SH5;
            end
            
            SH5: begin
                CURRENT_STATE = CLOSE_WRITE;

                CtrlSetSize = 2'd2;
                MemWrite = 1;
            end
            
            SB2: begin
                CURRENT_STATE = SB3;

                CtrlIord = 2'd2;
                MemWrite = 0;
            end
            
            SB3: begin
                CURRENT_STATE = SB4;
            end
            
            SB4: begin
                CURRENT_STATE = SB5;
            end
            
            SB5: begin
                CURRENT_STATE = CLOSE_WRITE;

                CtrlSetSize = 2'd3;
                MemWrite = 1;
            end
            
            LW2: begin
                CURRENT_STATE = LW3;
            end
            
            LW3: begin
                CURRENT_STATE = LW4;
            end
            
            LW4: begin
                CURRENT_STATE = CLOSE_WRITE;

                CtrlLoadSize = 2'd1;
                RegWrite = 1;
                CtrlMemtoReg = 1;
                CtrlRegDst = 0;
            end
            
            LH2: begin
                CURRENT_STATE = LH3;
            end
            
            LH3: begin
                CURRENT_STATE = LH4;
            end
            
            LH4: begin
                CURRENT_STATE = CLOSE_WRITE;

                CtrlLoadSize = 2'd2;
                RegWrite = 1;
                CtrlMemtoReg = 1;
                CtrlRegDst = 0;
            end
            
            LB2: begin
                CURRENT_STATE = LB3;
            end
            
            LB3: begin
                CURRENT_STATE = LB4;
            end
            
            LB4: begin
                CURRENT_STATE = CLOSE_WRITE;

                CtrlLoadSize = 2'd3;
                RegWrite = 1;
                CtrlMemtoReg = 1;
                CtrlRegDst = 0;
            end
            
            XCGH2: begin
                CURRENT_STATE = CLOSE_WRITE;

                CtrlMemtoReg = 4'd10;
                CtrlRegDst = 3'd4;
            end
            
            MULT2: begin
                CtrlMult = 0;
                if(MultStop == 1) begin
                    CURRENT_STATE = MULT3;
                end
            end
            
            MULT3: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                CtrlHILO = 0;
                HILOWrite = 1;
            end
            
            DIV2: begin
                CtrlDiv = 0;
                if (DivZero) begin
					CURRENT_STATE = DIVYBZEROEX1;
                end else begin
                    if(DivStop == 1) begin
                        CURRENT_STATE = DIV3;
                    end 
                end
            end
            
            DIV3: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                CtrlHILO = 1;
                HILOWrite = 1;
            end
            
            SLLV2: begin
                CURRENT_STATE = SHIFT_END;

                CtrlShift = 3'b010;
            end
            
            SRAV2: begin
                CURRENT_STATE = SHIFT_END;

                CtrlShift = 3'b100;
            end
            
            SLL2: begin
                CURRENT_STATE = SHIFT_END;

                CtrlShift = 3'b010;
            end
            
            SRL2: begin
                CURRENT_STATE = SHIFT_END;
                
                CtrlShift = 3'b011;
            end
            
            SRA2: begin
                CURRENT_STATE = SHIFT_END;
                
                CtrlShift = 3'b100;
            end
            
            SHIFT_END: begin
                CURRENT_STATE = CLOSE_WRITE;

                RegWrite = 1;
                CtrlMemtoReg = 4'd7;
                CtrlRegDst = 3'd1;
            end
            
            JAL2: begin
                CURRENT_STATE = JAL_END;
                
                CtrlMemtoReg = 4'd0;
                CtrlRegDst = 3'd3;
                RegWrite = 1;
            end
            
            JAL_END: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                CtrlPCSource = 3'd3;
                PCWrite = 1;
                RegWrite = 0;
            end
            
            BEQ2: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                if(ET == 1) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1;
                end
            end
            
            BNE2: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                if(ET == 0) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1;
                end
            end
            
            BLE2: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                if(GT == 0) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1;
                end
            end
            
            BGT2: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                if(GT == 1) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1;
                end
            end
            
            BLM2: begin
                CURRENT_STATE = BLM3;
            end
            
            BLM3: begin
                CURRENT_STATE = BLM4;
            end
            
            BLM4: begin
                CURRENT_STATE = BLM5;
                
                CtrlALUSrcA = 2'd2;
                CtrlALUSrcB = 2'd0;
                CtrlALU = 3'b111;
            end
            
            BLM5: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                if(LT == 1) begin
                    CtrlPCSource = 3'd2;
                    PCWrite = 1; 
                end               
            end
            
            ADD_SUB_AND: begin
                if ((FUNCT == ADD || FUNCT == SUB) && Of == 1) begin // CHECKING FOR OVERFLOW
                    CURRENT_STATE = OfEX1; // exception
                end else begin
                    CURRENT_STATE = CLOSE_WRITE;

                    CtrlRegDst = 3'd1; ///
                    CtrlMemtoReg = 4'd0; ///
                    RegWrite = 1; ///
                end
            end
            
            ADDI_ADDIU: begin
                if (OPCODE == ADDI && Of == 1) begin // CHECKING FOR OVERFLOW
                    CURRENT_STATE = OfEX1;
                end else begin
                    CURRENT_STATE = CLOSE_WRITE;

                    CtrlRegDst = 3'd0; ///
                    CtrlMemtoReg = 4'd0; ///
                    RegWrite = 1; ///
                end 
            end
            
            CLOSE_WRITE: begin
                CURRENT_STATE = FETCH1;

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
                CURRENT_STATE = OPCODEEX2;

                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd1;
                CtrlALU = 3'd2;
                EPCWrite = 1;
            end
            
            OPCODEEX2: begin
                CURRENT_STATE = END_EXCEPTION1;

                CtrlIord=3'd3;
                MemWrite = 0;
            end
            
            OfEX1: begin
                CURRENT_STATE = OfEX2;

                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd1;
                CtrlALU = 3'd2;
                EPCWrite = 1;
            end
            
            OfEX2: begin
                CURRENT_STATE = END_EXCEPTION1;

                CtrlIord=3'd4;
                MemWrite = 0;
            end
            
            DIVYBZEROEX1: begin
                CURRENT_STATE = DIVYBZEROEX2;

                CtrlALUSrcA = 2'd0;
                CtrlALUSrcB = 2'd1;
                CtrlALU = 3'd2;
                EPCWrite = 1;
            end
            
            DIVYBZEROEX2: begin
                CURRENT_STATE = END_EXCEPTION1;

                CtrlIord=3'd5;
                MemWrite = 0;
            end
            
            END_EXCEPTION1: begin
                CURRENT_STATE = END_EXCEPTION2;
            end
            
            END_EXCEPTION2: begin
                CURRENT_STATE = END_EXCEPTION3;
            end
            
            END_EXCEPTION3: begin
                CURRENT_STATE = CLOSE_WRITE;
                
                PCWrite = 1;
                CtrlPCSource = 3'd0;
                CtrlPCSource = 3'd0;
                CtrlLoadSize = 2'd3;
            end
            
        endcase
    end
end

endmodule