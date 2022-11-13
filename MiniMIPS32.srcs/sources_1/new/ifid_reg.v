`include "defines.v"

module ifid_reg (
	input  wire 						cpu_clk_50M,
	input  wire 						cpu_rst_n,

	// 来自取指阶段的信息  
	input  wire [`INST_ADDR_BUS]       if_pc,
	input  wire [`INST_ADDR_BUS]       if_pc_plus_4,

	// 接收到的暂停信号
	input  wire [`STALL_BUS	   ]       stall,
	
	// 送至译码阶段的信息  
	output reg  [`INST_ADDR_BUS]       id_pc,
	output reg  [`INST_ADDR_BUS]       id_pc_plus_4
	);

	always @(posedge cpu_clk_50M) begin
	    // 复位的时候将送至译码阶段的信息清0
		if (cpu_rst_n == `RST_ENABLE) begin
			id_pc 	<= `PC_INIT&32'h1FFFFFFF;
			id_pc_plus_4 <= `PC_INIT&32'h1FFFFFFF;
		end
		// 将来自取指阶段的信息寄存并送至译码阶段
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