 `include "defines.v"

module mem_stage (

    // 从执行阶段获得的信息
    input  wire [`ALUOP_BUS     ]       mem_aluop_i,
    input  wire [`REG_ADDR_BUS  ]       mem_wa_i,
    input  wire                         mem_wreg_i,
    input  wire [`REG_BUS       ]       mem_wd_i,
    input  wire                         mem_whilo_i,
    input  wire [`DOUBLE_REG_BUS]       mem_hilo_i,
    input  wire                         mem_mreg_i,
    input  wire [`REG_BUS     ]         mem_din_i,
    
    // 送至写回阶段的信息
    output wire [`REG_ADDR_BUS  ]       mem_wa_o,
    output wire                         mem_wreg_o,
    output wire [`REG_BUS       ]       mem_dreg_o,
    output wire                         mem_whilo_o,
    output wire [`DOUBLE_REG_BUS]       mem_hilo_o,
    output wire                         mem_mreg_o,
    output wire [`REG_BUS       ]       dre,

    // 送至数据存储器的信号
    output wire                         dce,
    output wire [`INST_ADDR_BUS ]       daddr,
    output wire [`BSEL_BUS      ]       we,
    output wire [`REG_BUS       ]       din
    );

    // 如果当前不是访存指令，则只需要把从执行阶段获得的信息直接输出
    assign mem_wa_o     = mem_wa_i;
    assign mem_wreg_o   = mem_wreg_i;
    assign mem_dreg_o   = mem_wd_i;
    assign mem_whilo_o  = mem_whilo_i;
    assign mem_hilo_o   = mem_hilo_i;

    wire inst_lb = (mem_aluop_i == 8'h90);
    wire inst_lw = (mem_aluop_i == 8'h92);
    wire inst_sb = (mem_aluop_i == 8'h98);
    wire inst_sw = (mem_aluop_i == 8'h9A);

    assign daddr = mem_wd_i;

    assign dre[3] = ((inst_lb & (daddr[1:0] == 2'b00)) | inst_lw);
    assign dre[2] = ((inst_lb & (daddr[1:0] == 2'b01)) | inst_lw);
    assign dre[1] = ((inst_lb & (daddr[1:0] == 2'b10)) | inst_lw);
    assign dre[0] = ((inst_lb & (daddr[1:0] == 2'b11)) | inst_lw);

    assign dre = (inst_lb | inst_lw | inst_sb | inst_sw);

    assign we[3] = ((inst_sb & (daddr[1:0] == 2'b00)) | inst_sw);
    assign we[2] = ((inst_sb & (daddr[1:0] == 2'b01)) | inst_sw);
    assign we[1] = ((inst_sb & (daddr[1:0] == 2'b10)) | inst_sw);
    assign we[0] = ((inst_sb & (daddr[1:0] == 2'b11)) | inst_sw);

    wire [`WORD_BUS] din_reverse = {mem_din_i[7:0], mem_din_i[15:8], mem_din_i[23:16], mem_din_i[31:24]};
    wire [`WORD_BUS] din_byte = {mem_din_i[7:0], mem_din_i[7:0], mem_din_i[7:0], mem_din_i[7:0]};
    assign din = (we == 4'b1111) ? din_reverse : 
        (we == 4'b1000) ? din_reverse : 
        (we == 4'b0100) ? din_byte : 
        (we == 4'b0010) ? din_byte : 
        (we == 4'b0001) ? din_byte : `ZERO_WORD;

endmodule