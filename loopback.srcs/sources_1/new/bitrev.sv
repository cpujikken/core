`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/12/16 17:28:39
// Design Name: 
// Module Name: bitrev
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


module bitrev(
    input logic[7:0] in,
    output logic[7:0] out
    );
    assign out={in[0:0],in[1:1],in[2:2],in[3:3],in[4:4],in[5:5],in[6:6],in[7:7]};
endmodule
