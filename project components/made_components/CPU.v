module CPU(
    input wire clk,
    input wire reset
);

    // ALU flags
    wire Of;
    wire NG;
    wire Zero;
    wire ET;
    wire GT;
    wire LT;
    
    // DIV and MULT flags
    wire MultStop;
    wire DivStop;
    wire DivZero;

    // Instruction
    wire [5:0] OPCODE;
    wire [4:0] RS;
    wire [4:0] RT;
    wire [15:0] IMMEDIATE;

    // WRITEs
    wire PCWrite;
    wire MemWrite;
    wire EPCWrite;
    wire IRWrite;
    wire RegWrite;
    wire ABWrite;
    wire ALUoutWrite;
    wire HILOWrite;
    wire MDRWrite;
    assign MDRWrite = 1;

    // OUTs
    wire [4:0]RegDst_out;
    wire [31:0]MemtoReg_out;
    wire [31:0]ALU_result;
    wire [31:0] PC_out;
    wire [31:0] Mem_out;
    wire [31:0] RB_to_A;
    wire [31:0] RB_to_B;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] Xtend16_to_32_out;
    wire [31:0] Xtend1_to_32_out;
    wire [31:0] ShiftLeft2_out;
    wire [31:0] ALUSrcA_out;
    wire [31:0] ALUSrcB_out;
    wire [31:0] ALUout_out;
    wire [31:0] PCSource_out;
    wire [31:0] EPC_out;
    wire [31:0] CONCAT_out;
    wire [31:0] ShiftLeft16_out;
    wire [31:0] ShiftSrcA_out;
    wire [4:0] ShiftSrcB_out;
    wire [31:0] ShiftReg_out;
    wire [31:0] MDR_out;
    wire [31:0] SetSize_out;
    wire [31:0] MDR_LS_out;
    wire [31:0] Iord_out;
    wire [31:0] MULTHI_out;
    wire [31:0] MULTLO_out;
    wire [31:0] DIVHI_out;
    wire [31:0] DIVLO_out;
    wire [31:0] MHI_out;
    wire [31:0] MLO_out;
    wire [31:0] HI_out;
    wire [31:0] LO_out;

    // Controls
    wire CtrlMult;
    wire CtrlDiv;
    wire [1:0] CtrlSetSize;
    wire [1:0] CtrlLoadSize;
    wire [2:0] CtrlRegDst;
    wire [3:0] CtrlMemtoReg;
    wire [2:0] CtrlPCSource;
    wire [1:0] CtrlALUSrcA;
    wire [1:0] CtrlALUSrcB;
    wire CtrlHILO;
    wire CtrlShiftSrcA;
    wire CtrlShiftSrcB;
    wire [2:0] CtrlIord;
    wire [2:0] CtrlALU;
    wire [2:0] CtrlShift;

    Registrador PC_(
        clk,
        reset,
        PCWrite,
        PCSource_out,
        PC_out
    );

    Iord M_IORD_(
        CtrlIord,
        PC_out,
        ALU_result,
        ALUout_out,
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
    );

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
    );

    Instr_Reg IR_(
        clk,
        reset,
        IRWrite,
        Mem_out,
        OPCODE,
        RS,
        RT,
        IMMEDIATE
    );

    RegDst M_REGDST_(
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
        MULTHI_out,
        MULTLO_out
    );

    DIV DIV_(
        clk,
        reset,
        A_out,
        B_out,
        CtrlDiv,
        DivStop,
        DivZero,
        DIVHI_out,
        DIVLO_out
    );

    MuxHI M_HI_(
        CtrlHILO,
        MULTHI_out,
        DIVHI_out,
        MHI_out
    );

    MuxLO M_LO_(
        CtrlHILO,
        MULTLO_out,
        DIVLO_out,
        MLO_out
    );

    Registrador HI_(
        clk,
        reset,
        HILOWrite,
        MHI_out,
        HI_out
    );

    Registrador LO_(
        clk,
        reset,
        HILOWrite,
        MLO_out,
        LO_out
    );

    MemtoReg M_MEMTOREG_(
        CtrlMemtoReg,
        ALU_result,
        MDR_LS_out,
        HI_out,
        LO_out,
        Xtend1_to_32_out,
        Xtend16_to_32_out,
        ShiftLeft16_out,
        ShiftReg_out,
        A_out,
        B_out,
        MemtoReg_out
    );

    ShiftSrcA M_SHIFTA_(
        CtrlShiftSrcA,
        A_out,
        B_out,
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
        ShiftSrcB_out,
        ShiftSrcA_out,
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

    Xtend16_to_32 XT16_32_(
        IMMEDIATE,
        Xtend16_to_32_out
    );

    Xtend1_to_32 XT1_32_(
        LT,
        Xtend1_to_32_out
    );

    ShiftLeft2 SLEFT_2_(
        Xtend16_to_32_out,
        ShiftLeft2_out
    );

    ShiftLeft16 SLEFT_16_(
        IMMEDIATE,
        ShiftLeft16_out
    );

    ALUSrcA M_ULAA_(
        CtrlALUSrcA,
        PC_out,
        A_out,
        MDR_out,
        ALUSrcA_out
    );

    ALUSrcB M_ULAB_(
        CtrlALUSrcB,
        B_out,
        Xtend16_to_32_out,
        ShiftLeft2_out,
        ALUSrcB_out
    );
    
    CONCATENATE CONCAT_(
        PC_out,
        RS,
        RT,
        IMMEDIATE,
        CONCAT_out
    );

    PCSource M_PCSOURCE_(
        CtrlPCSource,
        MDR_LS_out,
        ALU_result,
        ALUout_out, 
        CONCAT_out,
        EPC_out,
        PCSource_out
    );

    ula32 ULA_(
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
        MemWrite,
        PCWrite,
        IRWrite,
        RegWrite,
        ABWrite,
        ALUoutWrite,
        EPCWrite,
        HILOWrite,
        CtrlALU,
        CtrlShift,
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
        CtrlIord,
        CtrlMult,
        CtrlDiv,
        MultStop,
        DivStop,
        DivZero,
        OPCODE,
        IMMEDIATE[5:0]
    );

endmodule