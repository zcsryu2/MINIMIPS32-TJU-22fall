`include "defines.v"

module exemem_reg (
    input  wire 				cpu_clk_50M,
    input  wire 				cpu_rst_n,

    // 来自执行阶段的信息
    input  wire [`ALUOP_BUS   ] exe_aluop,
    input  wire [`REG_ADDR_BUS] exe_wa,
    input  wire                 exe_wreg,
    input  wire [`REG_BUS 	  ] exe_wd,
    input  wire                 exe_whilo,
    input  wire [`DOUBLE_REG_BUS] exe_hilo,
    input  wire                 exe_mreg,
    input  wire [`REG_BUS     ] exe_din,
    input  wire                     exe_whi,
    input  wire                     exe_wlo,
    input  wire                     exe_sext,
    // 送到访存阶段的信息 
    output reg  [`ALUOP_BUS   ] mem_aluop,
    output reg  [`REG_ADDR_BUS] mem_wa,
    output reg                  mem_wreg,
    output reg  [`REG_BUS 	  ] mem_wd,
    output reg                  mem_whilo,
    output reg  [`DOUBLE_REG_BUS] mem_hilo,
    output reg                      mem_whi,
    output reg                      mem_wlo,
    output reg                  mem_mreg,
    output reg                  mem_sext,
    output reg  [`REG_BUS     ] mem_din
    );

    always @(posedge cpu_clk_50M) begin
    if (cpu_rst_n == `RST_ENABLE) begin
        mem_aluop              <= `MINIMIPS32_SLL;
        mem_wa 				   <= `REG_NOP;
        mem_wreg   			   <= `WRITE_DISABLE;
        mem_wd   			   <= `ZERO_WORD;
        mem_whilo              <= `WRITE_DISABLE;
        mem_hilo               <= `ZERO_WORD;
        mem_mreg               <= `WRITE_DISABLE;
        mem_din                <= `ZERO_WORD;
        mem_whi                <= `FALSE_V;
        mem_wlo                <= `FALSE_V;
        mem_sext               <= 1'b0;
    end
    else begin
        mem_aluop              <= exe_aluop;
        mem_wa 				   <= exe_wa;
        mem_wreg 			   <= exe_wreg;
        mem_wd 		    	   <= exe_wd;
        mem_whilo              <= exe_whilo;
        mem_hilo               <= exe_hilo;       
        mem_whi                <= exe_whi;
        mem_wlo                <= exe_wlo;
        mem_mreg               <= exe_mreg;
        mem_din                <= exe_din;
        mem_sext               <= exe_sext;
    end
  end

endmodule