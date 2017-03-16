`timescale 1ns / 1ps

module InputBuffer(
    input logic CLK,
    input logic in,
    input logic reset,
    input logic pop4b,
    input logic pop1b,
    output logic empty4b,
    output logic empty1b,
    output logic[31:0] top4b,
    output logic[7:0] top1b
    );
  logic[7:0] receiver_to_processor;
  logic received;
  receiver receiver_instance(CLK, in, receiver_to_processor, received);

  logic[7:0] buffer[0:2047];
  integer size;
  logic[10:0] spos,tpos;
  assign empty1b = (size == 0);
  assign empty4b = (size <= 3);
  assign top1b = buffer[spos];
  assign top4b = {buffer[spos], buffer[spos+11'd1], buffer[spos+11'd2], buffer[spos+11'd3]};
  always_ff @(posedge CLK) begin
    if(reset) begin
      spos <= 11'b0;
      tpos <= 11'b0;
      size <= 0;
    end else begin
    //FIX
      if(received) begin
        buffer[tpos] <= receiver_to_processor;
        size <= size + 1;
        tpos <= tpos + 11'b1;
      end
      if(pop1b) begin
        spos <= spos + 11'b1;
        size <= size - 1;
      end
      if(pop4b) begin
        spos <= spos + 11'd4;
        size <= size - 4;
      end
    end
  end
endmodule
