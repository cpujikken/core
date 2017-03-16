`timescale 1ns / 1ps

//1 clock
module register(
    input logic CLK,
    input logic[4:0] in1,
    input logic[4:0] in2,
    input logic[4:0] in3,
    input logic[31:0] inWord,
    input logic regWrite,
    output logic[31:0] out1,
    output logic[31:0] out2
    );
    logic[31:0] regs[32];
    always_ff @(posedge CLK) begin
      if(regWrite) begin
        regs[in3]<=inWord;
      end
      out1 <= regs[in1];
      out2 <= regs[in2];
    end
endmodule
