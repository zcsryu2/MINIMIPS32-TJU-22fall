`include "defines.v"

module ifid_reg (
	input  wire 						cpu_clk_50M,
	input  wire 						cpu_rst_n,

	// ����ȡָ�׶ε���Ϣ  
	input  wire [`INST_ADDR_BUS]       if_pc,
	input  wire [`INST_ADDR_BUS]       if_pc_plus_4,

	// ���յ�����ͣ�ź�
	input  wire [`STALL_BUS	   ]       stall,
	
	// ��������׶ε���Ϣ  
	output reg  [`INST_ADDR_BUS]       id_pc,
	output reg  [`INST_ADDR_BUS]       id_pc_plus_4
	);

	always @(posedge cpu_clk_50M) begin
	    // ��λ��ʱ����������׶ε���Ϣ��0
		if (cpu_rst_n == `RST_ENABLE) begin
			id_pc 	<= `PC_INIT&32'h1FFFFFFF;
			id_pc_plus_4 <= `PC_INIT&32'h1FFFFFFF;
		end
		// ������ȡָ�׶ε���Ϣ�Ĵ沢��������׶�
		else if(stall[1] == `STOP && stall[2] == `NOSTOP) begin
			id_pc	<= `ZERO_WORD;
			id_pc_plus_4 <= `ZERO_WORD;
		end
		else if(stall[1] == `NOSTOP) begin
			id_pc	<= if_pc&32'h1FFFFFFF;	
			id_pc_plus_4 <= if_pc_plus_4&32'h1FFFFFFF;	
		end
	end

endmodule