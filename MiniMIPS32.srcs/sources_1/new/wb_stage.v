`include "defines.v"

module wb_stage(

    // �ӷô�׶λ�õ���Ϣ
	input  wire [`REG_ADDR_BUS  ] wb_wa_i,
	input  wire                   wb_wreg_i,
	input  wire [`REG_BUS       ] wb_dreg_i,
    input  wire                   wb_whilo_i,
    input  wire [`DOUBLE_REG_BUS] wb_hilo_i,
    input  wire                   wb_mreg_i,
    input  wire [`BSEL_BUS      ] wb_dre_i,

    // �����ݴ洢������������
    input  wire [`WORD_BUS      ] dm,

    // д��Ŀ�ļĴ���������
    output wire [`REG_ADDR_BUS  ] wb_wa_o,
	output wire                   wb_wreg_o,
    output wire [`WORD_BUS      ] wb_wd_o,
    output wire                   wb_whilo_o,
    output wire [`DOUBLE_REG_BUS] wb_hilo_o
    );

    assign wb_wa_o      = wb_wa_i;
    assign wb_wreg_o    = wb_wreg_i;
    assign wb_whilo_o   = wb_whilo_i;
    assign wb_hilo_o    = wb_hilo_i;

    wire [`WORD_BUS] data = (wb_dre_i == 4'b1111) ? {dm[7:0], dm[15:8], dm[23:16], dm[31:24]} :
        (wb_dre_i == 4'b1000) ? {{24{dm[31]}}, dm[31:24]} :
        (wb_dre_i == 4'b0100) ? {{24{dm[23]}}, dm[23:16]} :
        (wb_dre_i == 4'b0010) ? {{24{dm[15]}}, dm[15:8]} :
        (wb_dre_i == 4'b0001) ? {{24{dm[7]}}, dm[7:0]} :
        (wb_dre_i == 4'b1100) ? {{16{dm[31]}}, dm[31:16]} :
        (wb_dre_i == 4'b0011) ? {{16{dm[15]}}, dm[15:0]} : `ZERO_WORD;

    assign wb_wd_o = (wb_mreg_i == `MREG_ENABLE) ? data : wb_dreg_i;
    
endmodule
