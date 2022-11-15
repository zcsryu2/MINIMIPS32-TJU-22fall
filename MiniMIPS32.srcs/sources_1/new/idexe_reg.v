`include "defines.v"

module idexe_reg (
    input  wire 				  cpu_clk_50M,
    input  wire 				  cpu_rst_n,

    // 来自译码阶段的信息
    input  wire [`ALUTYPE_BUS  ]  id_alutype,
    input  wire [`ALUOP_BUS    ]  id_aluop,
    input  wire [`REG_BUS      ]  id_src1,
    input  wire [`REG_BUS      ]  id_src2,
    input  wire [`REG_ADDR_BUS ]  id_wa,
    input  wire                   id_wreg,
    input  wire [`REG_BUS      ]  id_din,
    input  wire                   id_whilo,
    input  wire                   id_mreg,
    input  wire                   id_whi,
    input  wire                   id_wlo,
    input  wire                   id_sext,
    input  wire [`REG_BUS      ]  id_ret_addr,
    input  wire [`STALL_BUS    ]  stall,
    // 送至执行阶段的信息
    output reg  [`ALUTYPE_BUS  ]  exe_alutype,
    output reg  [`ALUOP_BUS    ]  exe_aluop,
    output reg  [`REG_BUS      ]  exe_src1,
    output reg  [`REG_BUS      ]  exe_src2,
    output reg  [`REG_ADDR_BUS ]  exe_wa,
    output reg                    exe_wreg,
    output reg                    exe_mreg,
    output reg  [`REG_BUS      ]  exe_din,
    output reg                    exe_whilo,
    output reg                    exe_whi,
    output reg                    exe_sext,
    output reg                    exe_wlo,
    output reg  [`REG_BUS      ]  exe_ret_addr
    );

    always @(posedge cpu_clk_50M) begin
        // 复位的时候将送至执行阶段的信息清0
        if (cpu_rst_n == `RST_ENABLE) begin
            exe_alutype 	   <= `NOP;
            exe_aluop 		   <= `MINIMIPS32_SLL;
            exe_src1 		   <= `ZERO_WORD;
            exe_src2 		   <= `ZERO_WORD;
            exe_wa 			   <= `REG_NOP;
            exe_wreg    	   <= `WRITE_DISABLE;
            exe_din            <= `ZERO_WORD;
            exe_whilo          <= `WRITE_DISABLE;
            exe_mreg           <= `FALSE_V;
            exe_whi            <= `FALSE_V;
            exe_wlo            <= `FALSE_V;
            exe_sext           <= 1'b0;
            exe_ret_addr       <= `ZERO_WORD;
        end
        // 将来自译码阶段的信息寄存并送至执行阶段
        else if(stall[2] == `STOP && stall[3] == `NOSTOP) begin
            exe_alutype 	   <= `NOP;
            exe_aluop 		   <= `MINIMIPS32_SLL;
            exe_src1 		   <= `ZERO_WORD;
            exe_src2 		   <= `ZERO_WORD;
            exe_wa 			   <= `REG_NOP;
            exe_wreg    	   <= `WRITE_DISABLE;
            exe_din            <= `ZERO_WORD;
            exe_whilo          <= `WRITE_DISABLE;
            exe_mreg           <= `FALSE_V;
            exe_whi            <= `FALSE_V;
            exe_wlo            <= `FALSE_V;
            exe_sext           <= 1'b0;
            exe_ret_addr       <= `ZERO_WORD;
        end
        else if(stall[2] == `NOSTOP)begin
            exe_alutype 	   <= id_alutype;
            exe_aluop 		   <= id_aluop;
            exe_src1 		   <= id_src1;
            exe_src2 		   <= id_src2;
            exe_wa 			   <= id_wa;
            exe_wreg		   <= id_wreg;
            exe_mreg           <= id_mreg;
            exe_din            <= id_din;
            exe_whilo          <= id_whilo;
            exe_whi            <= id_whi;
            exe_wlo            <= id_wlo;
            exe_sext           <= id_sext;
            exe_ret_addr       <= id_ret_addr;
        end
    end
endmodule