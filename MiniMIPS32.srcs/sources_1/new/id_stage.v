`include "defines.v"
// `include "Mux2.v"
module id_stage(
    
    // 从取指阶段获得的PC值
    input  wire [`INST_ADDR_BUS]    id_pc_i,

    // 从指令存储器读出的指令字
    input  wire [`INST_BUS     ]    id_inst_i,

    // 从通用寄存器堆读出的数据 
    input  wire [`REG_BUS      ]    rd1,
    input  wire [`REG_BUS      ]    rd2,
      
    // 送至执行阶段的译码信息
    output wire [`ALUTYPE_BUS  ]    id_alutype_o,
    output wire [`ALUOP_BUS    ]    id_aluop_o,
    output wire [`REG_ADDR_BUS ]    id_wa_o,
    output wire                     id_wreg_o,
    output wire                     id_whilo_o,
    output wire [`REG_BUS]          id_din_o,
    output wire                     id_mreg_o,   
    output wire                     id_whi_o, //写hi寄存器（mthi）
    output wire                     id_wlo_o, //写lo寄存器（mtlo）
    output wire                     id_sext_o,
    // 送至执行阶段的源操作数1、源操作数2
    output wire [`REG_BUS      ]    id_src1_o,
    output wire [`REG_BUS      ]    id_src2_o,
      
    // 送至读通用寄存器堆端口的使能和地址
    // output wire                     rreg1,
    output wire [`REG_ADDR_BUS ]    ra1,
    // output wire                     rreg2,
    output wire [`REG_ADDR_BUS ]    ra2
    );
    
    // 根据小端模式组织指令字
    wire [`INST_BUS] id_inst = {id_inst_i[7:0], id_inst_i[15:8], id_inst_i[23:16], id_inst_i[31:24]};

    // 提取指令字中各个字段的信息
    wire [5 :0] op   = id_inst[31:26];
    wire [5 :0] func = id_inst[5 : 0];
    wire [4 :0] rd   = id_inst[15:11];
    wire [4 :0] rs   = id_inst[25:21];
    wire [4 :0] rt   = id_inst[20:16];
    wire [4 :0] sa   = id_inst[10: 6];
    wire [15:0] imm  = id_inst[15: 0]; 

    /*-------------------- 第一级译码逻辑：确定当前需要译码的指令 --------------------*/
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
    wire inst_lb    =  op[5]&~op[4]&~op[3]&~op[2]&~op[1]&~op[0];//或1无X
    wire inst_lw    =  op[5]&~op[4]&~op[3]&~op[2]& op[1]& op[0];//或1无X
    wire inst_sb    =  op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0];
    wire inst_sw    =  op[5]&~op[4]& op[3]&~op[2]& op[1]& op[0];

    wire inst_addi = ~op[5]&~op[4]& op[3]&~op[2]&~op[1]&~op[0];
    wire inst_addu = inst_reg& func[5]&~func[4]&~func[3]&~func[2]&~func[1]& func[0];
    wire inst_sub = inst_reg& func[5]&~func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_slti = ~op[5]&~op[4]& op[3]&~op[2]& op[1]&~op[0]; 
    wire inst_sltu = inst_reg& func[5]&~func[4]& func[3]&~func[2]& func[1]& func[0];
    wire inst_multu = inst_reg&~func[5]& func[4]& func[3]&~func[2]&~func[1]& func[0];
    wire inst_andi = ~op[5]&~op[4]& op[3]& op[2]&~op[1]&~op[0]; 
    wire inst_nor = inst_reg& func[5]&~func[4]&~func[3]& func[2]& func[1]& func[0];
    wire inst_or = inst_reg& func[5]&~func[4]&~func[3]& func[2]&~func[1]& func[0];
    wire inst_xor = inst_reg& func[5]&~func[4]&~func[3]& func[2]& func[1]&~func[0];
    wire inst_xori = ~op[5]&~op[4]& op[3]& op[2]& op[1]&~op[0]; 
    wire inst_sllv = inst_reg&~func[5]&~func[4]&~func[3]& func[2]&~func[1]&~func[0];
    wire inst_sra = inst_reg&~func[5]&~func[4]&~func[3]&~func[2]& func[1]& func[0];
    wire inst_srav = inst_reg&~func[5]&~func[4]&~func[3]& func[2]& func[1]& func[0];
    wire inst_srl= inst_reg&~func[5]&~func[4]&~func[3]&~func[2]& func[1]&~func[0];
    wire inst_srlv = inst_reg&~func[5]&~func[4]&~func[3]& func[2]& func[1]&~func[0]; 
    wire inst_mthi = inst_reg&~func[5]& func[4]&~func[3]&~func[2]&~func[1]& func[0];
    wire inst_mtlo = inst_reg&~func[5]& func[4]&~func[3]&~func[2]& func[1]& func[0]; 
    wire inst_lbu =  op[5]&~op[4]&~op[3]& op[2]&~op[1]&~op[0];
    wire inst_lh =  op[5]&~op[4]&~op[3]&~op[2]&~op[1]& op[0];
    wire inst_lhu =  op[5]&~op[4]&~op[3]& op[2]&~op[1]& op[0];
    wire inst_sh =  op[5]&~op[4]& op[3]&~op[2]&~op[1]& op[0];
    /*------------------------------------------------------------------------------*/

    /*-------------------- 第二级译码逻辑：生成具体控制信号 --------------------*/
    // 操作类型alutype
    assign id_alutype_o[2] = inst_sll| inst_sllv | inst_sra | inst_srl |inst_srav | inst_srlv ;
    assign id_alutype_o[1] = inst_and|inst_mfhi|inst_mflo|inst_ori|inst_lui| inst_andi |inst_nor | inst_or | inst_xor | inst_xori ;
    assign id_alutype_o[0] = inst_add|inst_subu|inst_slt|inst_mfhi|inst_mflo|inst_addiu|inst_sltiu|inst_lb | inst_lw | inst_sb | inst_sw|inst_addi | inst_addu | inst_sub | inst_slti | inst_sltu | inst_lbu |inst_lh | inst_lhu | inst_sh;

    // 内部操作码aluop
    assign id_aluop_o[7]   = inst_lb | inst_lw | inst_sb | inst_sw| inst_lbu | inst_lh | inst_lhu | inst_sh ;
    assign id_aluop_o[6]   = 1'b0;
    assign id_aluop_o[5]   = inst_slt | inst_sltiu| inst_slti | inst_sltu | inst_or |inst_xor | 
                             inst_xori | inst_sra | inst_srl | inst_srav | inst_srlv;
    assign id_aluop_o[4]   = inst_and | inst_add | inst_subu | inst_mult | inst_sll |inst_addiu |
                             inst_ori | inst_lb | inst_lw | inst_sb | inst_sw |inst_addi | inst_addu | 
                             inst_sub | inst_multu | inst_andi |inst_nor | inst_sllv | inst_lbu | 
                             inst_lh | inst_lhu | inst_sh;
    assign id_aluop_o[3]   = inst_add | inst_subu | inst_and | inst_mfhi | inst_mflo |inst_ori |
                             inst_addiu | inst_sb | inst_sw| inst_addi | inst_slti |inst_sltu | 
                             inst_andi | inst_nor | inst_sra | inst_srl | inst_srav | inst_srlv |
                             inst_mthi | inst_mtlo | inst_sh ;
    assign id_aluop_o[2]   = inst_slt | inst_and | inst_mult | inst_mfhi | inst_mflo |inst_ori | 
                             inst_lui | inst_sltiu| inst_addu | inst_sub | inst_multu |inst_andi | 
                             inst_nor | inst_srl | inst_srlv | inst_mthi | inst_mtlo |inst_lh | inst_lhu ;
    assign id_aluop_o[1]   = inst_subu |inst_slt|inst_sltiu|inst_lw|inst_sw| inst_addi |inst_addu | 
                             inst_sub | inst_andi | inst_nor | inst_xori | inst_sllv |inst_sra | inst_srav |
                             inst_mthi | inst_mtlo | inst_lhu ;
    assign id_aluop_o[0]   = inst_subu | inst_mflo | inst_sll | inst_addiu | inst_sltiu |inst_ori | 
                             inst_lui| inst_addu | inst_sltu | inst_multu |inst_nor | inst_xor | 
                             inst_srav | inst_srlv | inst_mtlo | inst_lbu | inst_sh ;

                             
    // 写通用寄存器使能信号
    assign id_wreg_o       = inst_and|inst_add|inst_subu|inst_slt|inst_mfhi|inst_mflo|
                             inst_sll|inst_ori|inst_lui|inst_addiu|inst_sltiu|inst_lb|inst_lw|
                             inst_addi |inst_addu | inst_sub | inst_slti | inst_sltu | inst_andi | inst_nor | inst_or |
                             inst_xor | inst_xori | inst_sllv | inst_sra | inst_srl | inst_srav | inst_srlv |
                             inst_lbu | inst_lh | inst_lhu ;

    assign id_whilo_o      = inst_mult| inst_multu;

    wire shift             = inst_sll|inst_sra | inst_srl;
    wire immsel            = inst_ori|inst_lui|inst_addiu|inst_sltiu|inst_lb|inst_lw|inst_sb|inst_sw  | 
                             inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu | inst_lh | inst_lhu | inst_sh;
    wire rtsel             = inst_ori | inst_lui | inst_addiu|inst_sltiu|inst_lb|inst_lw| 
                             inst_addi | inst_slti | inst_andi | inst_xori | inst_lbu | inst_lh | inst_lhu  ;
    wire sext              = inst_addiu | inst_sltiu |inst_sb|inst_sw|inst_lb|inst_lw| inst_addi | inst_slti | 
                              inst_lh |  inst_sh ; 
    wire upper             = inst_lui;
    // 读通用寄存器堆端口1使能信号
    // assign rreg1 = inst_and;
    // // 读通用寄存器堆读端口2使能信号
    // assign rreg2 = inst_and;
    /*------------------------------------------------------------------------------*/
    //存储器到寄存器使能信号
    assign id_mreg_o = inst_lb|inst_lw|inst_lbu | inst_lh | inst_lhu;
    // 读通用寄存器堆端口1的地址为rs字段，读端口2的地址为rt字段
    assign ra1   = rs;
    assign ra2   = rt;
    //获得访存阶段存入数据存储器的数据
    assign id_din_o = rd2;       
    assign id_sext_o = sext;                                
    // 获得待写入目的寄存器的地址（rt或rd）
    assign id_wa_o      = (rtsel == `RT_ENABLE)?rt : rd;
    //只写hi寄存器和lo寄存器的使能
    assign id_whi_o =  inst_mthi;
    assign id_wlo_o =  inst_mtlo;
    //获得访存阶段要存入数据存储器的数据
    // assign id_din_o     =rd2;
    // 获得源操作数1。如果shift信号有效，则源操作数1为移位位数；否则为从读通用寄存器堆端口1获得的数据
    assign id_src1_o = (shift  == `SHIFT_ENABLE   ) ? {27'b0,sa} : rd1;
    // Mux2 shiftmux(shift,rd1,{27'b0,sa},id_src1_o);
    // 获得源操作数2。如果immsel信号有效，则源操作数1为立即数；否则为从读通用寄存器堆端口2获得的数据
    wire [31:0] imm_ext = (upper == `UPPER_ENABLE)? (imm << 16):(sext==`SIGNED_EXT)?{{16{imm[15]}},imm}:{{16{1'b0}},imm};
    assign id_src2_o =  (immsel  == `IMM_ENABLE) ? imm_ext : rd2;    
    // Mux2 immselmux(immsel,imm_ext,rd2,id_src2_o);                 

endmodule
