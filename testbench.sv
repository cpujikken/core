`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2016/06/10 16:35:24
// Design Name: 
// Module Name: testbench
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


module testbench;
  logic clk;
  logic[7:0] data;
  logic finished;
  logic in,out;
  logic[19:0] test;
  receiver ins1(clk,in,data,finished);
  sender ins2(clk,data,finished,out);
  integer i;
  initial begin
    $display("START\n");
    clk<=0;
    in<=1;
    test<=20'b10101010101010101010;

repeat(100) begin

#100ns
    clk<=!clk;
end

    for(i=0;i<80;++i) begin
      if(i<20) in<=test[i];
      else in<=1;


      repeat(5208) begin
#5ns
        clk <= !clk;
      end
      $displayb(data);
    end
    $displayb(data);
    $finish;
  end
endmodule
