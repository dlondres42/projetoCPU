module CPU (
    input wire clk,
    input wire reset
);
    // DATA WIRES
////////////////////////////////////////////CONTROL WIRES////////////////////////////////////////////
    // ALU flags – control
    wire Of; // overflow
    wire Ng; // negative
    wire Zr; // zero
    wire Eq; // equal
    wire Gt; // greater than
    wire Lt; // less than

    // 1 bit control wires
    wire PC_w;
		
    // memory control
    wire MemWR;
    wire MemRead;

    // write's
    wire IRWrite;
    wire RegWrite;
    wire ABWrite;
    wire ALUoutWrite;

    // mux control
    wire [1:0] CtrlALUSrcA;
    wire [1:0] CtrlALUSrcB;
    wire [2:0] CtrlRegDst;
    wire [2:0] CtrlPCSource;
    wire [3:0] CtrlMemtoReg;
    wire [2:0] CtrlIord;

    // ALU control signal
    wire [2:0] CtrlULA;
///////////////////////////////////////////////////////////////////////////////////////////////////////
    // out's //
    wire [31:0] PC_out;
    wire [31:0] Memdata_out;
    wire [31:0] ALUSrcA_out;
    wire [31:0] ALUSrcB_out;
    wire [31:0] MDRls_out;
    wire [31:0] ALU_out;
    wire [31:0] EPC_out;
    wire [31:0] PCSource_out;
    wire [4:0] RegDst_out;
    wire [15:0] LO_out;
    wire [15:0] HI_out;
    wire [31:0] ShiftReg_out;
    wire [31:0] ExtendShiftLeft16_out;
    wire [31:0] Iord_out;
    wire [31:0] MemtoReg_out;
    wire [31:0] ULA_out;
    wire [31:0] A_out;
    wire [31:0] B_out;
    wire [31:0] ALUout_out;
    wire [31:0] MuxMem_out; // implementar MuxMem
    
    wire [31:0] ALU_result;
    // IR entries
    wire [5:0] opcode;
    wire [4:0] rs;
    wire [4:0] rt;
    wire [15:0] immediate;
    // RegBase entries
    wire [31:0] RB_to_A;
    wire [31:0] RB_to_B;

//////////////////////////////////////////////// MUXES //////////////////////////////////////////////    
    ALUSrcA M_ULAA_(
        CtrlALUSrcA,
        PC_out,
        Memdata_out,
        A_out,
        ALUSrcA_out
    );

    ALUSrcB M_ULAB_(
        CtrlALUSrcB,
        B_out,
        immediate,
        ExtendShiftLeft2,
        ALUSrcB_out
    );

    Iord M_IORD_(
        CtrlIord,
        PC_out,
        ALU_out,
        ALU_result,
        Iord_out
    );

    MemtoReg M_MEM_(
        CtrlMemtoReg,
        ALU_out,
        MDRls_out,
        LO_out,
        HI_out,
        ShiftReg_out,
        ExtendShiftLeft16_out,
        immediate,
        ALU_result,
        LTExtend_out,
        MemtoReg_out
    );

    RegDst M_REG_(
        CtrlRegDst,
        rt,
        immediate[15:11],
        RegDst_out
    );

    PCSource M_PC_(
        CtrlPCSource,
        MDRls_out,
        ALU_result,
        ALU_out,
        PC_out,
        EPC_out,
        PCSource_out
    );
/////////////////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////// GIVEN COMPONENTES ///////////////////////////////////////////
    Registrador ALUout_(
        clk,
        reset,
        ALUoutWrite,
        ALU_result,
        ALUout_out
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

    Registrador PC_(
        clk,
        reset,
        PC_w,
        PCSource_out,
        PC_out
    );

    Banco_reg RegBase_(
        clk,
        reset,
        RegWrite,
        rs,
        rt,
        RegDst_out,
        MemtoReg_out,
        RB_to_A,
        RB_to_B
    );

    Memoria Memdata_(
        Iord_out,
        clk,
        MemWR,
        MuxMem_out,
        Memdata_out
    );

    Instr_Reg IR_(
        clk,
        reset,
        IRWrite,
        Memdata_out,
        opcode,
        rs,
        rt,
        immediate
    );

    ula32 ULA_(
        ALUSrcA_out,
        ALUSrcB_out,
        CtrlULA,
        ALU_result,
        Of,
        Ng,
        Zr,
        Eq,
        Gt,
        Lt
    );
/////////////////////////////////////////////////////////////////////////////////////////////////////

    Control Control_u(
        clk,
        reset,
        Of, // overflow
        Ng, // negative
        Zr, // zero
        Eq, // equal
        Gt, // greater than
        Lt, // less than
        opcode,
        immediate[5:0], // funct
        PC_w,
        MemWR,
        MemRead,
        IRWrite,
        RegWrite,
        ABWrite,
        ALUoutWrite,
        CtrlALUSrcA,
        CtrlALUSrcB,
        CtrlRegDst,
        CtrlPCSource,
        CtrlMemtoReg,
        CtrlIord,
        CtrlULA //ALUOP
    );
    

endmodule
