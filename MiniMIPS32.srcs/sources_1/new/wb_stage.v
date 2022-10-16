`include "defines.v"

module wb_stage(

    // 从访存阶段获得的信息
	input  wire [`REG_ADDR_BUS  ] wb_wa_i,
	input  wire                   wb_wreg_i,
	input  wire [`REG_BUS       ] wb_dreg_i,
    input  wire                   wb_whilo_i,
    input  wire [`DOUBLE_REG_BUS] wb_hilo_i,

    // 写回目的寄存器的数据
    output wire [`REG_ADDR_BUS  ] wb_wa_o,
	output wire                   wb_wreg_o,
    output wire [`WORD_BUS      ] wb_wd_o,
    output wire                   wb_whilo_o,
    output wire [`DOUBLE_REG_BUS] wb_hilo_o
    );

    assign wb_wa_o      = wb_wa_i;
    assign wb_wreg_o    = wb_wreg_i;
    assign wb_wd_o      = wb_dreg_i;
    assign wb_whilo_o   = wb_whilo_i;
    assign wb_hilo_o    = wb_hilo_i;
    
endmodule
