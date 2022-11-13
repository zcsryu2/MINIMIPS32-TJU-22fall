`timescale 1ns / 1ps
`include "defines.v"
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/11/13 13:13:15
// Design Name: 
// Module Name: scu
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


module scu(
    input   wire                cpu_rst_n,

    input   wire                stallreq_id,    //译码阶段暂停信号
    input   wire                stallreq_exe,   //执行阶段暂停信号
    
    output  wire [`STALL_BUS]   stall  
    );
    
    // 根据译码阶段或执行阶段发出的暂停请求信号，产生流水线暂停信号stall
    assign  stall = (cpu_rst_n == `RST_ENABLE) ? 4'b0000 :
                    (stallreq_exe == `STOP) ? 4'b1111 : 
                    (stallreq_id == `STOP) ? 4'b0111 : 
                    4'b0000; 
    // assign stall = 4'b0000;

endmodule
