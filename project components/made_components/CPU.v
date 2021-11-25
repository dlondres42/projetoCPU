module CPU(
    input wire clk,
    input wire reset
);

///// ALU flags //////
    wire Of;
    wire NG;
    wire Zero;
    wire ET;
    wire GT;
    wire LT;
//////////////////////

///// Write flags/////
    wire PCWrite;
    wire MemWrite;
    wire EPCWrite;
    wire IRWrite;
    wire RegWrite;
    wire ABWrite;
    wire ALUoutWrite;
    wire HI_LO_WRITE;
    wire MDRWrite;
    assign MDRWrite = 1;
//////////////////////

///// Mult/Div flags ////
    wire MultStop;
    wire DivStop;
    wire DivZero;
/////////////////////////

///// Controls ////////////
    wire [1:0]CtrlALUSrcA;
    wire [1:0]CtrlALUSrcB;
    wire [2:0]CtrlRegDst;
    wire [2:0]CtrlPCSource;
    wire [3:0]CtrlMemtoReg;
    wire [2:0]CtrlIord;
    wire [2:0] CtrlALU;
    wire [2:0] CtrlShift;
    wire CtrlShiftSrcA;
    wire CtrlShiftSrcB;
    wire CtrlMult;
    wire CtrlDiv;
    wire CtrlHILO;
    wire [1:0]CtrlSetSize;
    wire [1:0]CtrlLoadSize;
////////////////////////////

///// IR entries ////////
    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] IMMEDIATE;
/////////////////////////

///// Out ////////////////////
    wire [31:0] PC_out;
    wire [31:0] ALUSrcA_out;
    wire [31:0] ALUSrcB_out;
    wire [31:0] MDR_out;
    wire [31:0] ALUout_out;
    wire [31:0] ALU_result;
    wire [31:0] EPC_out;
    wire [31:0] PCSource_out;
    wire [31:0] Iord_out;
    wire [4:0] RegDst_out;
    wire [31:0] MemtoReg_out;
    wire [31:0] Mem_out;
    wire [31:0] RB_to_A;
    wire [31:0] RB_to_B;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] SignXtend16to32_out;
    wire [31:0] SignXtend1to32_out;
    wire [31:0] ShiftLeft2_out;
    wire [31:0] ShiftLeft16_out;
    wire [31:0] ShiftSrcA_out;
    wire [4:0] ShiftSrcB_out;
    wire [31:0] ShiftReg_out;
    wire [31:0] SetSize_out;
    wire [31:0] Concatenate_out;
    wire [31:0] MDR_LS_out;
/////////////////////////////////////////

///// Mult/Div components ////
    wire [31:0]MultHI_out;
    wire [31:0]MultLO_out;
    wire [31:0]DivHI_out;
    wire [31:0]DivLO_out;
    wire [31:0]MuxHI_out;
    wire [31:0]MuxLO_out;
    wire [31:0]HI_out;
    wire [31:0]LO_out;
//////////////////////////////

    Registrador PC_(
        clk,
        reset,
        PCWrite,
        PCSource_out,
        PC_out
    );

    Iord MuxIord_(
        CtrlIord,
        PC_out,
        ALUout_out,
        ALU_result,
        Iord_out
    );

    Memoria MEM_(
        Iord_out,
        clk,
        MemWrite,
        SetSize_out,
        Mem_out
    );

    Registrador MDR_(
        clk,
        reset,
        MDRWrite,
        Mem_out,
        MDR_out
    ); // feito

    SetSize SS_(
        CtrlSetSize,
        B_out,
        MDR_out,
        SetSize_out
    );

    LoadSize LS_(
        CtrlLoadSize,
        MDR_out,
        MDR_LS_out
    ); // feito

    Instr_Reg IR_(
        clk,
        reset,
        IRWrite,
        Mem_out,
        OPCODE,
        RS,
        RT,
        IMMEDIATE
    ); // feito

    RegDst MuxRegDst_(
        CtrlRegDst,
        RT,
        IMMEDIATE,
        RS,
        RegDst_out
    );

    MULT MULT_(
        clk,
        reset,
        A_out,
        B_out,
        CtrlMult,
        MultStop,
        MultHI_out,
        MultLO_out
    );

    DIV DIV_(
        clk,
        reset,
        A_out,
        B_out,
        CtrlDiv,
        DivStop,
        DivZero,
        DivHI_out,
        DivLO_out
    );

    MuxHI MuxHI_(
        CtrlHILO,
        DivHI_out,
        MultHI_out,
        MuxHI_out
    );

    MuxLO MuxLO_(
        CtrlHILO,
        DivLO_out,
        MultLO_out,
        MuxLO_out
    );

    Registrador HI_(
        clk,
        reset,
        HI_LO_WRITE,
        MuxHI_out,
        HI_out
    );

    Registrador LO_(
        clk,
        reset,
        HI_LO_WRITE,
        MuxLO_out,
        LO_out
    );
    
    MemtoReg MuxMemtoReg_(
        CtrlMemtoReg,
        ALU_result,
        MDR_LS_out,
        LO_out,
        HI_out,
        ShiftReg_out,
        SignXtend16to32_out,
        ShiftLeft16_out,
        SignXtend1to32_out,
        A_out,
        B_out,
        MemtoReg_out
    );

    ShiftSrcA M_SHIFTA_(
        CtrlShiftSrcA,
        B_out,
        A_out,
        ShiftSrcA_out
    );

    ShiftSrcB M_SHIFTB_(
        CtrlShiftSrcB,
        B_out,
        IMMEDIATE,
        ShiftSrcB_out
    );

    RegDesloc SHIFT_REG_(
        clk,
        reset,
        CtrlShift,
        CtrlShiftSrcB,
        CtrlShiftSrcA,
        ShiftReg_out
    );

    Banco_reg REG_BASE_(
        clk,
        reset,
        RegWrite,
        RS,
        RT,
        RegDst_out,
        MemtoReg_out,
        RB_to_A,
        RB_to_B
    );

    Registrador A_(
        clk,
        reset,
        ABWrite,
        RB_to_A,
        A_out
    );

    Registrador B_(
        clk,
        reset,
        ABWrite,
        RB_to_B,
        B_out
    );

    SignXtend16to32 EXT16_32_(
        IMMEDIATE,
        SignXtend16to32_out
    );

    ShiftLeft2 SLEFT_2_(
        SignXtend16to32_out,
        ShiftLeft2_out
    );
    
    SignXtend1to32 EXT1_32_(
        LT,
        SignXtend1to32_out
    );
    
    ShiftLeft16 SLEFT_16_(
        IMMEDIATE,
        ShiftLeft16_out
    );
    
    ALUSrcA MuxALUSrcA_(
        CtrlALUSrcA,
        PC_out,
        MDR_out,
        A_out,
        ALUSrcA_out
    );

    ALUSrcB MuxALUSrcB_(
        CtrlALUSrcB,
        B_out,
        SignXtend16to32_out,
        ShiftLeft2_out,
        ALUSrcB_out
    );
    
    Concatenate CONCAT_(
        PC_out,
        RS,
        RT,
        IMMEDIATE,
        Concatenate_out
    );

    PCSource MuxPCSource_(
        CtrlPCSource,
        MDR_LS_out,
        ALU_result,
        ALUout_out, 
        Concatenate_out,
        EPC_out,
        PCSource_out
    );

    ula32 ALU_(
        ALUSrcA_out,
        ALUSrcB_out,
        CtrlALU,
        ALU_result,
        Of,
        NG,
        Zero,
        ET,
        GT,
        LT
    );

    Registrador ALUOUT_(
        clk,
        reset,
        ALUoutWrite,
        ALU_result,
        ALUout_out
    );

    Registrador EPC_(
        clk,
        reset,
        EPCWrite,
        ALU_result,
        EPC_out
    );

    Control CTRL_(
        clk,
        reset,
        Of,
        NG,
        Zero,
        ET,
        GT,
        LT,
        MultStop,
        DivStop,
        DivZero,
        OPCODE,
        IMMEDIATE[5:0],
        MemWrite,
        PCWrite,
        IRWrite,
        RegWrite,
        ABWrite,
        HI_LO_WRITE,
        ALUoutWrite,
        EPCWrite,
        CtrlALU,
        CtrlShift,
        CtrlMult,
        CtrlDiv,
        CtrlSetSize,
        CtrlLoadSize,
        CtrlRegDst,
        CtrlMemtoReg,
        CtrlPCSource,
        CtrlALUSrcA,
        CtrlALUSrcB,
        CtrlHILO,
        CtrlShiftSrcA,
        CtrlShiftSrcB,
        CtrlIord
    );

endmodule