`include "defines.v"

module memwb_reg (
    input  wire                     cpu_clk_50M,
	input  wire                     cpu_rst_n,

	// 来自访存阶段的信息
	input  wire [`REG_ADDR_BUS  ]   mem_wa,
	input  wire                     mem_wreg,
	input  wire [`REG_BUS       ] 	mem_dreg,
	input  wire                 	mem_whilo,
    input  wire [`DOUBLE_REG_BUS] 	mem_hilo,
	input  wire 					mem_mreg,
	input  wire [`BSEL_BUS		]   mem_dre,
	input  wire                     mem_whi,
	input  wire                     mem_wlo,
	input  wire                     mem_sext,
	// 送至写回阶段的信息 
	output reg  [`REG_ADDR_BUS  ]   wb_wa,
	output reg                      wb_wreg,
	output reg  [`REG_BUS       ]   wb_dreg,
	output reg                  	wb_whilo,
    output reg [`DOUBLE_REG_BUS] 	wb_hilo,
	output reg                      wb_whi,
	output reg                      wb_wlo,
	output reg 						wb_mreg,
	output reg 						wb_sext,
	output reg [`BSEL_BUS		]   wb_dre
    );

    always @(posedge cpu_clk_50M) begin
		// 复位的时候将送至写回阶段的信息清0
		if (cpu_rst_n == `RST_ENABLE) begin
			wb_wa       <= `REG_NOP;
			wb_wreg     <= `WRITE_DISABLE;
			wb_dreg     <= `ZERO_WORD;
			wb_whilo    <= `WRITE_DISABLE;
        	wb_hilo     <= `ZERO_WORD;
			wb_mreg		<= `WRITE_DISABLE;
			wb_dre		<= 4'b0;
			wb_whi      <= `FALSE_V;
			wb_wlo      <= `FALSE_V;
			wb_sext      <= 1'b0;
		end
		// 将来自访存阶段的信息寄存并送至写回阶段
		else begin
			wb_wa 	    <= mem_wa;
			wb_wreg     <= mem_wreg;
			wb_dreg     <= mem_dreg;
			wb_whilo    <= mem_whilo;
        	wb_hilo     <= mem_hilo;
			wb_mreg		<= mem_mreg;
			wb_dre		<= mem_dre;
			wb_whi      <= mem_whi;
			wb_wlo      <= mem_wlo;
			wb_sext      <= mem_sext;
		end
	end

endmodule