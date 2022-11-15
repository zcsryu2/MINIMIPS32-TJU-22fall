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
    input  wire                     exe_whi_i,
    input  wire                     exe_wlo_i,
    input  wire                     exe_sext_i,
    input  wire [`REG_BUS ]         ret_addr,

    input  wire [`REG_BUS 	]       hi_i,
    input  wire [`REG_BUS 	]       lo_i,

    // �ӷô�׶λ�õ�HI, LO�Ĵ�����ֵ
    input  wire                     mem2exe_whilo,
    input  wire [`DOUBLE_REG_BUS]   mem2exe_hilo,          

    // ��д�ؽ׶λ�õ�HI, LO�Ĵ�����ֵ
    input  wire                     wb2exe_whilo,
    input  wire [`DOUBLE_REG_BUS]   wb2exe_hilo, 

    // ������ʱ��, ���ڳ�������
    input  wire                     cpu_clk_50M,

    // ִ�н׶η�������ͣ�����ź�
    output wire                     stallreq_exe,

    // �����ô�׶ε���Ϣ
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

    // ֱ�Ӵ�����һ�׶�
    assign exe_aluop_o = exe_aluop_i;
    assign exe_whilo_o = exe_whilo_i;
    assign exe_mreg_o  = exe_mreg_i;
    assign exe_din_o   = exe_din_i;
    assign exe_whi_o   = exe_whi_i;
    assign exe_wlo_o   = exe_wlo_i;
    assign exe_sext_o   = exe_sext_i;
    wire [`REG_BUS       ]      logicres;       // �����߼�����Ľ��
    wire [`REG_BUS       ]      shiftres;       // ������λ����Ľ��
    wire [`REG_BUS       ]      arithres;       // �������������Ľ��
    wire [`DOUBLE_REG_BUS]      mulres;         // ����˷������Ľ��
    wire [`REG_BUS       ]      moveres; 
    wire [`REG_BUS       ]      hi_t;
    wire [`REG_BUS       ]      lo_t;
    wire [`DOUBLE_REG_BUS]      unsigned_mulres;
    reg  [`DOUBLE_REG_BUS]      divres;
    
    // �����ڲ�������aluop�����߼�����
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

    assign hi_t = (mem2exe_whilo == `WRITE_ENABLE) ? mem2exe_hilo[63:32] :
        (wb2exe_whilo == `WRITE_ENABLE) ? wb2exe_hilo[63:32] : hi_i;
    assign lo_t = (mem2exe_whilo == `WRITE_ENABLE) ? mem2exe_hilo[31:0] :
        (wb2exe_whilo == `WRITE_ENABLE) ? wb2exe_hilo[31:0] : lo_i;
    assign moveres = (exe_aluop_i == `MINIMIPS32_MFHI) ? hi_t :
        (exe_aluop_i == `MINIMIPS32_MFLO) ? lo_t : `ZERO_WORD;

    // �����ڲ�������aluop���г˷�����, ������������һ�׶�
    assign mulres = ($signed(exe_src1_i) * $signed(exe_src2_i));
    assign unsigned_mulres = exe_src1_i * exe_src2_i;

    // ��������
    wire signed_div_i;
    wire [`REG_BUS] div_opdata1;
    wire [`REG_BUS] div_opdata2;
    wire div_start;
    reg div_ready = `DIV_NOT_READY;

    assign stallreq_exe = ((exe_aluop_i == `MINIMIPS32_DIV) && (div_ready == `DIV_NOT_READY)) ? `STOP : `NOSTOP;
    assign div_opdata1 = (exe_aluop_i == `MINIMIPS32_DIV) ? exe_src1_i : `ZERO_WORD;
    assign div_opdata2 = (exe_aluop_i == `MINIMIPS32_DIV) ? exe_src2_i : `ZERO_WORD;
    assign div_start = ((exe_aluop_i == `MINIMIPS32_DIV) && (div_ready == `DIV_NOT_READY)) ? `DIV_START : `DIV_STOP;
    assign signed_div_i = (exe_aluop_i == `MINIMIPS32_DIV) ? 1'b1 : 1'b0;

    wire [34:0] div_temp;
    wire [34:0] div_temp0;
    wire [34:0] div_temp1;
    wire [34:0] div_temp2;
    wire [34:0] div_temp3;
    wire [1:0] mul_cnt;

    // ��¼���̷������˼���, ��=16ʱ, ��ʾ���̷�����
    reg [5:0] cnt;

    reg [65:0] dividend;
    reg [1:0] state = `DIV_FREE;
    reg [33:0] divisor;
    reg [31:0] temp_op1;
    reg [31:0] temp_op2;

    wire [33:0] divisor_temp;
    wire [33:0] divisor2;
    wire [33:0] divisor3;

    // dividend��32λ������Ǳ�����, �м���, ��k�ε���������ʱ��, dividend[k:0]���浽���ǵ�ǰ�õ����м���,
    // divend[32:k+1]���浽���Ǳ������л�û�в������������,dividend��32λ��ÿ�ε���ʱ�ı�����
    assign div_temp0 = {1'b0, dividend[63:32]} - {1'b0, `ZERO_WORD}; // ���������뱻������0�����
    assign div_temp1 = {1'b0, dividend[63:32]} - {1'b0, divisor}; // ���������뱻������1�����
    assign div_temp2 = {1'b0, dividend[63:32]} - {1'b0, divisor2}; // ���������뱻������2�����
    assign div_temp3 = {1'b0, dividend[63:32]} - {1'b0, divisor3}; // ���������뱻������3�����

    assign divisor_temp = temp_op2;
    assign divisor2     = divisor_temp << 1;       //����������
	assign divisor3     = divisor2 + divisor;      //����������

    assign div_temp = (div_temp3[34] == 1'b0) ? div_temp3 : 
        (div_temp2[34] == 1'b0) ? div_temp2 : div_temp1;

    assign mul_cnt = (div_temp3[34] == 1'b0) ? 2'b11 :
        (div_temp2[34] == 1'b0) ? 2'b10 : 2'b01;

    always @(posedge cpu_clk_50M) begin
        case(state)
	        `DIV_FREE:begin
                if(div_start == `DIV_START) begin
                    if(div_opdata2 == `ZERO_WORD) begin //����Ϊ0
                        state <= `DIV_BY_ZERO;
                    end
                    else begin
                        state <= `DIV_ON;
                        cnt <= 6'b000000;
                        if((signed_div_i == 1'b1) && (div_opdata1[31] == 1'b1)) begin
                            temp_op1 = ~div_opdata1 + 1;
                        end
                        else begin
                           temp_op1 = div_opdata1;
                        end
                        if((signed_div_i == 1'b1) && (div_opdata2[31] == 1'b1)) begin
                            temp_op2 = ~div_opdata2 + 1;
                        end
                        else begin
                            temp_op2 = div_opdata2;
                        end
                        dividend            <= {`ZERO_WORD, `ZERO_WORD};
                        dividend[31 : 0]    <= temp_op1;
                        divisor             <= temp_op2;
                    end
                end
                else begin
                    div_ready <= `DIV_NOT_READY;
                    divres <= {`ZERO_WORD, `ZERO_WORD};
                end
	        end
	           
	        `DIV_BY_ZERO: begin               //DivByZero
                dividend <= {`ZERO_WORD,`ZERO_WORD};
                state    <= `DIV_END;		 		
		  	end
		  	   
		  	`DIV_ON: begin
		  	    if(cnt != 6'b100010) begin    //cnt��Ϊ16, ��ʾ���̷���û�н���
		  	        if(div_temp[34] == 1'b1)begin
		  	            dividend <= {dividend[63 : 0], 2'b00};
		  	        end
		  	        else begin
		  	            dividend <= {div_temp[31 : 0], dividend[31 : 0], mul_cnt};
		  	        end
		  	        cnt <= cnt + 2;
		  	    end
		  	    else begin   //���̷�����
		  	        if((signed_div_i == 1'b1) && ((div_opdata1[31] ^ div_opdata2[31]) == 1'b1)) begin
		  	            dividend[31:0] <= (~dividend[31 : 0] + 1); // ȡ�����Ĳ���
		  	        end
		  	        if((signed_div_i == 1'b1) && ((div_opdata1[31] ^ dividend[65]) == 1'b1)) begin              
                        dividend[65:34] <= (~dividend[65:34] + 1); // ȡ�����Ĳ���
                    end
                    state <= `DIV_END;
                    cnt <= 6'b000000;
		  	    end
		  	end
		  	`DIV_END: begin
		  	    divres <= {dividend[65:34], dividend[31:0]};
		  	    div_ready <= `DIV_READY;  //�����������
		  	    if(div_start == `DIV_STOP) begin
		  	        state <= `DIV_FREE;
		  	        div_ready <= `DIV_NOT_READY;
		  	        divres  <= {`ZERO_WORD, `ZERO_WORD};
		  	    end
		  	end
	    endcase  
    end

    assign exe_hilo_o = (exe_aluop_i == `MINIMIPS32_MULT) ? mulres :
        (exe_aluop_i == `MINIMIPS32_MULTU) ? unsigned_mulres :
        (exe_aluop_i == `MINIMIPS32_MTHI) ? ({exe_src1_i[31 : 0], 32'b0}) :
        (exe_aluop_i == `MINIMIPS32_MTLO) ? ({32'b0, exe_src1_i[31 : 0]}) :
        (exe_aluop_i == `MINIMIPS32_DIV) ? divres : `ZERO_DWORD;
    
    assign exe_wa_o   = exe_wa_i;
    assign exe_wreg_o = exe_wreg_i;

    // ���ݲ�������alutypeȷ��ִ�н׶����յ����������ȿ����Ǵ�д��Ŀ�ļĴ��������ݣ�Ҳ�����Ƿ������ݴ洢���ĵ�ַ��
    assign exe_wd_o = (exe_alutype_i == `LOGIC    ) ? logicres  :
        (exe_alutype_i == `SHIFT) ? shiftres :
        (exe_alutype_i == `ARITH ) ? arithres :
        (exe_alutype_i == `MOVE) ? moveres :
        (exe_alutype_i == `JUMP )? ret_addr: `ZERO_WORD;

endmodule