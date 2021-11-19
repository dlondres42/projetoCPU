// ainda ta faltando alguns sinais no controle

// eu decidi excluir o sinal de reset auxiliar do tutorial
// (reset_out), acho que desse jeito que tá aí pode rodar de boa.
// Além disso, fiquei em dúvida no final do CLOSEWRITE, tinha um wait
// com PC_w = 0, mas esse sinal já era zerado no ciclo anterior.
// Botei assim do mesmo jeito pq tava no diagrama né kkkkkkkk
// qqlr coisa vcs mudam aí.

module Control (
    input wire      clk,
    input wire      reset,
    // flags
    input wire      Of, // overflow
    input wire      Ng, // negative
    input wire      Zr, // zero
    input wire      Eq, // equal
    input wire      Gt, // greater than
    input wire      Lt, // less than

    input wire [5:0]    OPCODE,
    input wire [5:0]    FUNCT,
    // controladores de 1 bit
    output reg      PC_w,
    output reg      MemWrite,
    output reg      MemRead,
	output reg      IRWrite,
	output reg      RegWrite,
	output reg      ABWrite,
    output reg      ALUoutWrite,
    output reg      EPCWrite,

    // mux control
    output reg [1:0] CtrlALUSrcA,
    output reg [1:0] CtrlALUSrcB,
    output reg [2:0] CtrlRegDst,
    output reg [2:0] CtrlPCSource,
    output reg [3:0] CtrlMemtoReg,
    output reg [2:0] CtrlIord,

    //  shift control
    output reg      CtrlShifSrcA,
    output reg [1:0] CtrlShifSrcB,

        // ctrl div
    output reg      CtrlDivSrcA,
    output reg      CtrlDivSrcB,

        // mux source B control
    output reg CtrlMuxSSrcB,

   // ALU control signal
    output reg [2:0] CtrlULA //ALUOP

   // controlador especial para o reset
);

// VARIAVEIS
reg [6:0] STATE;

// OPCODES
parameter instruct_R =   6'h0;

// estados
parameter FETCH1 = 7'd0;
parameter FETCH2 = 7'd1;
parameter FETCH3 = 7'd2;
parameter DECODE = 7'd3;
parameter DECODE2 = 7'd4;
parameter WAIT = 7'd5;
parameter EXECUTE = 7'd6;

parameter ADD_SUB_AND = 7'd7;
parameter CLOSEWRITE = 7'd8;
parameter WAIT_END = 7'd9;


// instruções R
parameter R_FORMAT = 6'd0;
// FUNCT
parameter ADD = 6'h20;
parameter AND = 6'h24;
parameter SUB = 6'h22;

// pra primeira entrega faz só essas 2 instruções que sao mto parecidas

initial begin
    STATE = FETCH1;
end

always @(posedge clk) begin
    
    if (reset == 1'b1) begin
        STATE = FETCH1;

        PC_w = 1'b0;
        MemWrite = 1'b0;
        MemRead = 1'b0;
        IRWrite = 1'b0;
        RegWrite = 1'b1; ///
        ABWrite = 1'b0;
        ALUoutWrite = 1'b0;
        EPCWrite = 1'b0;

        // missing LO/HI WRITE and ShiftControl

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

        // COUNTER 
    end
    else begin
        case (STATE)
            FECTH1: begin
                STATE = FETCH2;

                PC_w = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b1; ///
                IRWrite = 1'b0;
                RegWrite = 1'b0; ///
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                // missing LO/HI WRITE and ShiftControl

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

                // COUNTER 
            end
            
            FECTH2: begin
                STATE = FETCH3;

                PC_w = 1'b1; ///
                MemWrite = 1'b0;
                MemRead = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                // missing LO/HI WRITE and ShiftControl

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

                // COUNTER 
            end
            
            FECTH3: begin
                STATE = DECODE;

                PC_w = 1'b0; ///
                MemWrite = 1'b0;
                MemRead = 1'b0;
                IRWrite = 1'b1; ///
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                // missing LO/HI WRITE and ShiftControl

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

                // COUNTER 
            end
            
            DECODE: begin
                STATE = EXECUTE;

                PC_w = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                IRWrite = 1'b0; ///
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b1; ///
                EPCWrite = 1'b0;

                // missing LO/HI WRITE and ShiftControl

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

                // COUNTER 
            end

            EXECUTE: begin
                ABWrite = 1'b0;
                case(OPCODE)
                    R_FORMAT: begin
                        case (FUNCT)
                            ADD: begin
                                STATE = ADD_SUB_AND;

                                PC_w = 1'b0;
                                MemWrite = 1'b0;
                                MemRead = 1'b0;
                                IRWrite = 1'b0;
                                RegWrite = 1'b0;
                                ABWrite = 1'b0;
                                ALUoutWrite = 1'b0;
                                EPCWrite = 1'b0;

                                // missing LO/HI WRITE and ShiftControl

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

                                // COUNTER 
                            end

                            AND: begin
                                STATE = ADD_SUB_AND;

                                PC_w = 1'b0;
                                MemWrite = 1'b0;
                                MemRead = 1'b0;
                                IRWrite = 1'b0;
                                RegWrite = 1'b0;
                                ABWrite = 1'b0;
                                ALUoutWrite = 1'b0;
                                EPCWrite = 1'b0;

                                // missing LO/HI WRITE and ShiftControl

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
                                CtrlULA = 3'b011; ///

                                // COUNTER 
                            end

                            SUB: begin
                                STATE = ADD_SUB_AND;

                                PC_w = 1'b0;
                                MemWrite = 1'b0;
                                MemRead = 1'b0;
                                IRWrite = 1'b0;
                                RegWrite = 1'b0;
                                ABWrite = 1'b0;
                                ALUoutWrite = 1'b0;
                                EPCWrite = 1'b0;

                                // missing LO/HI WRITE and ShiftControl

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

                                // COUNTER 
                            end
                        endcase

                    end
                endcase

                            // default: OPCODE INEXISTENTE! COMPLETAR DEPOIS 
            end

            ADD_SUB_AND: begin
                STATE = CLOSEWRITE;

                PC_w = 1'b0;
                MemWrite = 1'b0;
                MemRead = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b1; ///
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                // missing LO/HI WRITE and ShiftControl

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

                // COUNTER 
            end

            CLOSEWRITE: begin
                STATE = WAIT_END;

                PC_w = 1'b0; ///
                MemWrite = 1'b0;
                MemRead = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0; ///
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0; ///
                EPCWrite = 1'b0;

                // missing LO/HI WRITE and ShiftControl

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

                // COUNTER 
            end

            WAIT_END: begin
                STATE = FETCH1;

                PC_w = 1'b0; ///
                MemWrite = 1'b0;
                MemRead = 1'b0;
                IRWrite = 1'b0;
                RegWrite = 1'b0;
                ABWrite = 1'b0;
                ALUoutWrite = 1'b0;
                EPCWrite = 1'b0;

                // missing LO/HI WRITE and ShiftControl

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

                // COUNTER 
            end
                
        endcase
        
    end
    
end

endmodule