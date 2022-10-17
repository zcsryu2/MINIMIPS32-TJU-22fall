`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/10/17 20:20:55
// Design Name: 
// Module Name: Mux2
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

module Mux2 #(parameter WIDTH = 32)(
    input  sel,
    input  [(WIDTH-1):0] in0, in1,
    output [(WIDTH-1):0] out
    );

    assign out = (sel) ? in1 : in0;

endmodule
