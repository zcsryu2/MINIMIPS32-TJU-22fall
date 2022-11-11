`include "defines.v"

module exe_stage (

    // 从译码阶段获得的信息
    input  wire [`ALUTYPE_BUS	] 	exe_alutype_i,
    input  wire [`ALUOP_BUS	] 	    exe_aluop_i,
    input  wire [`REG_BUS 	] 	    exe_src1_i,
    input  wire [`REG_BUS 	] 	    exe_src2_i,
    input  wire [`REG_ADDR_BUS 	] 	exe_wa_i,
    input  wire 			        exe_wreg_i,
    input  wire                     exe_whilo_i,
    input  wire                     exe_mreg_i,
    input  wire [`REG_BUS   ]       exe_din_i,
    input  wire                     exe_whi_i,
    input  wire                     exe_wlo_i,
    input  wire                     exe_sext_i,

    input  wire [`REG_BUS 	]       hi_i,
    input  wire [`REG_BUS 	]       lo_i,

    // 送至访存阶段的信息
    output wire [`ALUOP_BUS	] 	    exe_aluop_o,
    output wire [`REG_ADDR_BUS 	] 	exe_wa_o,
    output wire 			        exe_wreg_o,
    output wire [`REG_BUS 	] 	    exe_wd_o,
    output wire                     exe_whilo_o,
    output wire [`DOUBLE_REG_BUS]   exe_hilo_o,
    output wire                     exe_mreg_o,
    output wire                     exe_whi_o,
    output wire                     exe_wlo_o,
    output wire                     exe_sext_o,
    output wire [`REG_BUS   ]       exe_din_o
    );

    // 直接传到下一阶段
    assign exe_aluop_o = exe_aluop_i;
    assign exe_whilo_o = exe_whilo_i;
    assign exe_mreg_o  = exe_mreg_i;
    assign exe_din_o   = exe_din_i;
    assign exe_whi_o   = exe_whi_i;
    assign exe_wlo_o   = exe_wlo_i;
    assign exe_sext_o   = exe_sext_i;
    wire [`REG_BUS       ]      logicres;       // 保存逻辑运算的结果
    wire [`REG_BUS       ]      shiftres;       // 保存移位运算的结果
    wire [`REG_BUS       ]      arithres;       // 保存算术操作的结果
    wire [`DOUBLE_REG_BUS]      mulres;         // 保存乘法操作的结果
    wire [`REG_BUS       ]      moveres; 
    wire [`REG_BUS       ]      hi_t;
    wire [`REG_BUS       ]      lo_t;
    wire [`DOUBLE_REG_BUS]      unsigned_mulres;
    
    // 根据内部操作码aluop进行逻辑运算
    assign logicres = (exe_aluop_i == `MINIMIPS32_AND )  ? (exe_src1_i & exe_src2_i) :
           (exe_aluop_i == `MINIMIPS32_ORI) ? (exe_src1_i | exe_src2_i) :
           (exe_aluop_i == `MINIMIPS32_LUI) ? exe_src2_i :
           (exe_aluop_i == `MINIMIPS32_ANDI) ? (exe_src1_i & exe_src2_i) :
           (exe_aluop_i == `MINIMIPS32_NOR) ? (~(exe_src1_i | exe_src2_i)) :
           (exe_aluop_i == `MINIMIPS32_OR) ? (exe_src1_i | exe_src2_i) :
           (exe_aluop_i == `MINIMIPS32_XOR) ? (exe_src1_i ^ exe_src2_i) :
           (exe_aluop_i == `MINIMIPS32_XORI) ? (exe_src1_i ^ exe_src2_i) : `ZERO_WORD;
           
    assign shiftres = (exe_aluop_i == `MINIMIPS32_SLL) ? (exe_src2_i << exe_src1_i) :
        (exe_aluop_i == `MINIMIPS32_SLLV) ? (exe_src2_i << exe_src1_i[`REG_ADDR_BUS]) :
        (exe_aluop_i == `MINIMIPS32_SRA) ? $signed(($signed(exe_src2_i)) >>> exe_src1_i) :
        (exe_aluop_i == `MINIMIPS32_SRAV) ? $signed(($signed(exe_src2_i)) >>> exe_src1_i[`REG_ADDR_BUS]) :
        (exe_aluop_i == `MINIMIPS32_SRL) ? (exe_src2_i >>> exe_src1_i) :
        (exe_aluop_i == `MINIMIPS32_SRLV) ? (exe_src2_i >> exe_src1_i[`REG_ADDR_BUS]) : `ZERO_WORD;
    assign arithres = (exe_aluop_i == `MINIMIPS32_ADD) ? (exe_src1_i + exe_src2_i) :
            (exe_aluop_i == `MINIMIPS32_SUBU) ? (exe_src1_i + (~exe_src2_i) + 1) :
            (exe_aluop_i == `MINIMIPS32_SLT) ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1 : 32'b0) :
            (exe_aluop_i == `MINIMIPS32_ADDIU) ? (exe_src1_i + exe_src2_i) :
            (exe_aluop_i == `MINIMIPS32_SLTIU) ? ((exe_src1_i < exe_src2_i) ? 32'b1 : 32'b0) :
            (exe_aluop_i == `MINIMIPS32_LB) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_LW) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_SB) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_SW) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_ADDI) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_ADDU) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_SUB) ? (exe_src1_i - exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_SLTI) ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1 : 32'b0) :
            (exe_aluop_i == `MINIMIPS32_SLTU) ? ((exe_src1_i < exe_src2_i) ? 32'b1 : 32'b0) :
            (exe_aluop_i == `MINIMIPS32_LBU) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_LH) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_LHU) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_SH) ? (exe_src1_i + exe_src2_i) : 
            `ZERO_WORD;

    assign hi_t = hi_i;
    assign lo_t = lo_i;
    assign moveres = (exe_aluop_i == `MINIMIPS32_MFHI) ? hi_t :
        (exe_aluop_i == `MINIMIPS32_MFLO) ? lo_t : `ZERO_WORD;

    // 根据内部操作码aluop进行乘法运算, 并保存送至下一阶段
    assign mulres = ($signed(exe_src1_i) * $signed(exe_src2_i));
    assign unsigned_mulres = exe_src1_i * exe_src2_i;
    assign exe_hilo_o = (exe_aluop_i == `MINIMIPS32_MULT) ? mulres :
        (exe_aluop_i == `MINIMIPS32_MULTU) ? unsigned_mulres :
        (exe_aluop_i == `MINIMIPS32_MTHI) ? ({exe_src1_i[31 : 0], 32'b0}) :
        (exe_aluop_i == `MINIMIPS32_MTLO) ? ({32'b0, exe_src1_i[31 : 0]}) : `ZERO_DWORD;

    assign exe_wa_o   = exe_wa_i;
    assign exe_wreg_o = exe_wreg_i;

    // 根据操作类型alutype确定执行阶段最终的运算结果（既可能是待写入目的寄存器的数据，也可能是访问数据存储器的地址）
    assign exe_wd_o = (exe_alutype_i == `LOGIC    ) ? logicres  :
        (exe_alutype_i == `SHIFT) ? shiftres :
        (exe_alutype_i == `ARITH ) ? arithres :
        (exe_alutype_i == `MOVE) ? moveres : `ZERO_WORD;

endmodule