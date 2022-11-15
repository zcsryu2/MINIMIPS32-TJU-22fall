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
    input  wire [`REG_BUS ]         ret_addr,

    input  wire [`REG_BUS 	]       hi_i,
    input  wire [`REG_BUS 	]       lo_i,

    // 从访存阶段获得的HI, LO寄存器的值
    input  wire                     mem2exe_whilo,
    input  wire [`DOUBLE_REG_BUS]   mem2exe_hilo,          

    // 从写回阶段获得的HI, LO寄存器的值
    input  wire                     wb2exe_whilo,
    input  wire [`DOUBLE_REG_BUS]   wb2exe_hilo, 

    // 处理器时钟, 用于除法运算
    input  wire                     cpu_clk_50M,

    // 执行阶段发出的暂停请求信号
    output wire                     stallreq_exe,

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
    reg  [`DOUBLE_REG_BUS]      divres;
    
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

    assign hi_t = (mem2exe_whilo == `WRITE_ENABLE) ? mem2exe_hilo[63:32] :
        (wb2exe_whilo == `WRITE_ENABLE) ? wb2exe_hilo[63:32] : hi_i;
    assign lo_t = (mem2exe_whilo == `WRITE_ENABLE) ? mem2exe_hilo[31:0] :
        (wb2exe_whilo == `WRITE_ENABLE) ? wb2exe_hilo[31:0] : lo_i;
    assign moveres = (exe_aluop_i == `MINIMIPS32_MFHI) ? hi_t :
        (exe_aluop_i == `MINIMIPS32_MFLO) ? lo_t : `ZERO_WORD;

    // 根据内部操作码aluop进行乘法运算, 并保存送至下一阶段
    assign mulres = ($signed(exe_src1_i) * $signed(exe_src2_i));
    assign unsigned_mulres = exe_src1_i * exe_src2_i;

    // 除法运算
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

    // 记录试商法进行了几轮, 当=16时, 表示试商法结束
    reg [5:0] cnt;

    reg [65:0] dividend;
    reg [1:0] state = `DIV_FREE;
    reg [33:0] divisor;
    reg [31:0] temp_op1;
    reg [31:0] temp_op2;

    wire [33:0] divisor_temp;
    wire [33:0] divisor2;
    wire [33:0] divisor3;

    // dividend的32位保存的是被除数, 中间结果, 第k次迭代结束的时候, dividend[k:0]保存到就是当前得到的中间结果,
    // divend[32:k+1]保存到就是被除数中还没有参与运算的数据,dividend高32位是每次迭代时的被减数
    assign div_temp0 = {1'b0, dividend[63:32]} - {1'b0, `ZERO_WORD}; // 部分余数与被除数的0倍相减
    assign div_temp1 = {1'b0, dividend[63:32]} - {1'b0, divisor}; // 部分余数与被除数的1倍相减
    assign div_temp2 = {1'b0, dividend[63:32]} - {1'b0, divisor2}; // 部分余数与被除数的2倍相减
    assign div_temp3 = {1'b0, dividend[63:32]} - {1'b0, divisor3}; // 部分余数与被除数的3倍相减

    assign divisor_temp = temp_op2;
    assign divisor2     = divisor_temp << 1;       //除数的两倍
	assign divisor3     = divisor2 + divisor;      //除数的三倍

    assign div_temp = (div_temp3[34] == 1'b0) ? div_temp3 : 
        (div_temp2[34] == 1'b0) ? div_temp2 : div_temp1;

    assign mul_cnt = (div_temp3[34] == 1'b0) ? 2'b11 :
        (div_temp2[34] == 1'b0) ? 2'b10 : 2'b01;

    always @(posedge cpu_clk_50M) begin
        case(state)
	        `DIV_FREE:begin
                if(div_start == `DIV_START) begin
                    if(div_opdata2 == `ZERO_WORD) begin //除数为0
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
		  	    if(cnt != 6'b100010) begin    //cnt不为16, 表示试商法还没有结束
		  	        if(div_temp[34] == 1'b1)begin
		  	            dividend <= {dividend[63 : 0], 2'b00};
		  	        end
		  	        else begin
		  	            dividend <= {div_temp[31 : 0], dividend[31 : 0], mul_cnt};
		  	        end
		  	        cnt <= cnt + 2;
		  	    end
		  	    else begin   //试商法结束
		  	        if((signed_div_i == 1'b1) && ((div_opdata1[31] ^ div_opdata2[31]) == 1'b1)) begin
		  	            dividend[31:0] <= (~dividend[31 : 0] + 1); // 取正数的补码
		  	        end
		  	        if((signed_div_i == 1'b1) && ((div_opdata1[31] ^ dividend[65]) == 1'b1)) begin              
                        dividend[65:34] <= (~dividend[65:34] + 1); // 取正数的补码
                    end
                    state <= `DIV_END;
                    cnt <= 6'b000000;
		  	    end
		  	end
		  	`DIV_END: begin
		  	    divres <= {dividend[65:34], dividend[31:0]};
		  	    div_ready <= `DIV_READY;  //除法运算结束
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

    // 根据操作类型alutype确定执行阶段最终的运算结果（既可能是待写入目的寄存器的数据，也可能是访问数据存储器的地址）
    assign exe_wd_o = (exe_alutype_i == `LOGIC    ) ? logicres  :
        (exe_alutype_i == `SHIFT) ? shiftres :
        (exe_alutype_i == `ARITH ) ? arithres :
        (exe_alutype_i == `MOVE) ? moveres :
        (exe_alutype_i == `JUMP )? ret_addr: `ZERO_WORD;

endmodule