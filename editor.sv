`timescale 1ns / 1ps
module editor(
  input CLK,
  input logic finished,
  input logic[7:0] data,
  output logic[7:0] result
  );
  
  always_ff @(posedge CLK)
  begin
    result<=data;
  end
endmodule
