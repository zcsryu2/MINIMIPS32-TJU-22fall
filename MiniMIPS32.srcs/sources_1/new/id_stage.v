`include "defines.v"
// `include "Mux2.v"
module id_stage(
    
    // ��ȡָ�׶λ�õ�PCֵ
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // ��ָ��洢��������ָ����
    input  wire [`INST_BUS     ]    id_inst_i,

    // ��ͨ�üĴ����Ѷ��������� 
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
      
    // ����ִ�н׶ε�������Ϣ
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire                     id_wreg_o,
    output wire                     id_whilo_o,
    // output wire [`REG_BUS]          id_din_o,
    // ����ִ�н׶ε�Դ������1��Դ������2
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
      
    // ������ͨ�üĴ����Ѷ˿ڵ�ʹ�ܺ͵�ַ
    // output wire                     rreg1,
    output wire [`REG_ADDR_BUS ]    ra1,
    // output wire                     rreg2,
    output wire [`REG_ADDR_BUS ]    ra2
    );
    
    // ����С��ģʽ��ָ֯����
    wire [`INST_BUS] id_inst = {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

    // ��ȡָ�����и����ֶε���Ϣ
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    /*-------------------- ��һ�������߼���ȷ����ǰ��Ҫ�����ָ�� --------------------*/
    wire inst_reg  = ~|op;
    wire inst_and  = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    wire inst_add  = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_subu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
    wire inst_slt  = inst_reg& func[5]&~func[4]& func[3]&~func[2]& func[1]&~func[0];
    wire inst_mult = inst_reg&~func[5]& func[4]& func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mfhi = inst_reg&~func[5]& func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_mflo = inst_reg&~func[5]& func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_sll  = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]&~func[1]&~func[0];
    wire inst_ori  = ~op[5]&~op[4]& op[3]& op[2]&~op[1]& op[0];
    wire inst_lui  = ~op[5]&~op[4]& op[3]& op[2]& op[1]& op[0];
    wire inst_addiu  =~op[5]&~op[4]& op[3]&~op[2]&~op[1]& op[0];
    wire inst_sltiu  =~op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];
    /*------------------------------------------------------------------------------*/

    /*-------------------- �ڶ��������߼������ɾ�������ź� --------------------*/
    // ��������alutype
    assign id_alutype_o[2] = inst_sll;
    assign id_alutype_o[1] = inst_and|inst_mfhi|inst_mflo|inst_ori|inst_lui;
    assign id_alutype_o[0] = inst_add|inst_subu|inst_slt|inst_mfhi|inst_mflo|inst_addiu|inst_sltiu;

    // �ڲ�������aluop
    assign id_aluop_o[7]   = 1'b0;
    assign id_aluop_o[6]   = 1'b0;
    assign id_aluop_o[5]   = inst_slt|inst_sltiu;
    assign id_aluop_o[4]   = inst_and|inst_add|inst_subu|inst_sll|inst_mult|inst_addiu|inst_ori;
    assign id_aluop_o[3]   = inst_and|inst_add|inst_subu|inst_mfhi|inst_mflo|inst_addiu|inst_ori;
    assign id_aluop_o[2]   = inst_and|inst_slt|inst_mfhi|inst_mflo|inst_mult|inst_sltiu|inst_ori|inst_lui;
    assign id_aluop_o[1]   = inst_subu|inst_slt|inst_sltiu;
    assign id_aluop_o[0]   = inst_subu|inst_sll|inst_mflo|inst_addiu|inst_sltiu|inst_ori|inst_lui;

    // дͨ�üĴ���ʹ���ź�
    assign id_wreg_o       = inst_and|inst_add|inst_subu|inst_slt|inst_mfhi|inst_mflo|inst_sll|inst_ori|inst_lui|inst_addiu|inst_sltiu;

    assign id_whilo_o      = inst_mult;

    wire shift             = inst_sll;
    wire immsel            = inst_ori|inst_lui|inst_addiu|inst_sltiu ;
    wire rtsel             = inst_ori | inst_lui | inst_addiu|inst_sltiu ;
    wire sext              = inst_addiu | inst_sltiu  ; 
    wire upper             = inst_lui;
    // ��ͨ�üĴ����Ѷ˿�1ʹ���ź�
    // assign rreg1 = inst_and;
    // // ��ͨ�üĴ����Ѷ��˿�2ʹ���ź�
    // assign rreg2 = inst_and;
    /*------------------------------------------------------------------------------*/

    // ��ͨ�üĴ����Ѷ˿�1�ĵ�ַΪrs�ֶΣ����˿�2�ĵ�ַΪrt�ֶ�
    assign ra1   = rs;
    assign ra2   = rt;
                                            
    // ��ô�д��Ŀ�ļĴ����ĵ�ַ��rt��rd��
    assign id_wa_o      = (rtsel == `RT_ENABLE)?rt : rd;
    //��÷ô�׶�Ҫ�������ݴ洢��������
    // assign id_din_o     =rd2;
    // ���Դ������1�����shift�ź���Ч����Դ������1Ϊ��λλ��������Ϊ�Ӷ�ͨ�üĴ����Ѷ˿�1��õ�����
    assign id_src1_o = (shift  == `SHIFT_ENABLE   ) ? {27'b0,sa} : rd1;
    // Mux2 shiftmux(shift,rd1,{27'b0,sa},id_src1_o);
    // ���Դ������2�����immsel�ź���Ч����Դ������1Ϊ������������Ϊ�Ӷ�ͨ�üĴ����Ѷ˿�2��õ�����
    wire [31:0] imm_ext = (upper == `UPPER_ENABLE)? (imm << 16):(sext==`SIGNED_EXT)?{{16{imm[15]}},imm}:{{16{1'b0}},imm};
    assign id_src2_o =  (immsel  == `IMM_ENABLE) ? imm_ext : rd2;    
    // Mux2 immselmux(immsel,imm_ext,rd2,id_src2_o);                 

endmodule
