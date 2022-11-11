`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/16 15:34:27
// Design Name: 
// Module Name: hilo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module hilo(
    input   wire    cpu_clk_50M,
    input   wire    cpu_rst_n,
    input   wire    we_hi,
    input   wire    we_lo,
    // 写端口
    input   wire            we,
    input   wire[`REG_BUS]  hi_i,
    input   wire[`REG_BUS]  lo_i,

    // 读端口
    output  reg[`REG_BUS]   hi_o,
    output  reg[`REG_BUS]   lo_o
    );

    always @(posedge cpu_clk_50M) begin
        if(cpu_rst_n == `RST_ENABLE) begin
            hi_o <= `ZERO_WORD;
            lo_o <= `ZERO_WORD;
        end
        else if (we == `WRITE_ENABLE) begin
            hi_o <= hi_i;
            lo_o <= lo_i;
        end
        else if(we_hi == `WRITE_ENABLE) begin
            hi_o <= hi_i;
            
        end
        else if(we_lo == `WRITE_ENABLE) begin
           
            lo_o <= lo_i;
        end
        
    end
endmodule
