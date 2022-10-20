`include "defines.v"

module exe_stage (

    // ������׶λ�õ���Ϣ
    input  wire [`ALUTYPE_BUS	] 	exe_alutype_i,
    input  wire [`ALUOP_BUS	] 	    exe_aluop_i,
    input  wire [`REG_BUS 	] 	    exe_src1_i,
    input  wire [`REG_BUS 	] 	    exe_src2_i,
    input  wire [`REG_ADDR_BUS 	] 	exe_wa_i,
    input  wire 			        exe_wreg_i,
    input  wire                     exe_whilo_i,
    input  wire                     exe_mreg_i,
    input  wire [`REG_BUS   ]       exe_din_i,

    input  wire [`REG_BUS 	]       hi_i,
    input  wire [`REG_BUS 	]       lo_i,

    // �����ô�׶ε���Ϣ
    output wire [`ALUOP_BUS	] 	    exe_aluop_o,
    output wire [`REG_ADDR_BUS 	] 	exe_wa_o,
    output wire 			        exe_wreg_o,
    output wire [`REG_BUS 	] 	    exe_wd_o,
    output wire                     exe_whilo_o,
    output wire [`DOUBLE_REG_BUS]   exe_hilo_o,
    output wire                     exe_mreg_o,
    output wire [`REG_BUS   ]       exe_din_o
    );

    // ֱ�Ӵ�����һ�׶�
    assign exe_aluop_o = exe_aluop_i;
    assign exe_whilo_o = exe_whilo_i;
    assign exe_mreg_o  = exe_mreg_i;
    assign exe_din_o   = exe_din_i;

    wire [`REG_BUS       ]      logicres;       // �����߼�����Ľ��
    wire [`REG_BUS       ]      shiftres;       // ������λ����Ľ��
    wire [`REG_BUS       ]      arithres;       // �������������Ľ��
    wire [`DOUBLE_REG_BUS]      mulres;         // ����˷������Ľ��
    wire [`REG_BUS       ]      moveres; 
    wire [`REG_BUS       ]      hi_t;
    wire [`REG_BUS       ]      lo_t;
    
    // �����ڲ�������aluop�����߼�����
    assign logicres = (exe_aluop_i == `MINIMIPS32_AND )  ? (exe_src1_i & exe_src2_i) :
           (exe_aluop_i == `MINIMIPS32_ORI) ? (exe_src1_i | exe_src2_i) :
           (exe_aluop_i == `MINIMIPS32_LUI) ? exe_src2_i : `ZERO_WORD;
           
    assign shiftres = (exe_aluop_i == `MINIMIPS32_SLL) ? (exe_src2_i << exe_src1_i) : `ZERO_WORD;
    assign arithres = (exe_aluop_i == `MINIMIPS32_ADD) ? (exe_src1_i + exe_src2_i) :
            (exe_aluop_i == `MINIMIPS32_SUBU) ? (exe_src1_i + (~exe_src2_i) + 1) :
            (exe_aluop_i == `MINIMIPS32_SLT) ? (($signed(exe_src1_i) < $signed(exe_src2_i)) ? 32'b1 : 32'b0) :
            (exe_aluop_i == `MINIMIPS32_ADDIU) ? (exe_src1_i + exe_src2_i) :
            (exe_aluop_i == `MINIMIPS32_SLTIU) ? ((exe_src1_i < exe_src2_i) ? 32'b1 : 32'b0) :
            (exe_aluop_i == `MINIMIPS32_LB) ? (exe_src1_i + exe_src2_i) : 
            (exe_aluop_i == `MINIMIPS32_LW) ? (exe_src1_i + exe_src2_i) : `ZERO_WORD;

    assign hi_t = hi_i;
    assign lo_t = lo_i;
    assign moveres = (exe_aluop_i == `MINIMIPS32_MFHI) ? hi_t :
        (exe_aluop_i == `MINIMIPS32_MFLO) ? lo_t : `ZERO_WORD;

    // �����ڲ�������aluop���г˷�����, ������������һ�׶�
    assign mulres = ($signed(exe_src1_i) * $signed(exe_src2_i));
    assign exe_hilo_o = (exe_aluop_i == `MINIMIPS32_MULT) ? mulres : `ZERO_DWORD;

    assign exe_wa_o   = exe_wa_i;
    assign exe_wreg_o = exe_wreg_i;

    // ���ݲ�������alutypeȷ��ִ�н׶����յ����������ȿ����Ǵ�д��Ŀ�ļĴ��������ݣ�Ҳ�����Ƿ������ݴ洢���ĵ�ַ��
    assign exe_wd_o = (exe_alutype_i == `LOGIC    ) ? logicres  :
        (exe_alutype_i == `SHIFT) ? shiftres :
        (exe_alutype_i == `ARITH ) ? arithres :
        (exe_alutype_i == `MOVE) ? moveres : `ZERO_WORD;

endmodule