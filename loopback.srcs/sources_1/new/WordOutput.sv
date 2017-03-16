`timescale 1ns / 1ps


module WordOutput(
    input logic CLK,
    input logic[7:0] data,
    input logic trigger,
    output logic finished,
    output logic UART_TX
    );
	logic[7:0] processor_to_sender;

	logic sending,start_send;
//  bitrev bitrev_(processor_to_sender,rev);
  sender sender_instance(CLK, processor_to_sender, start_send, UART_TX, sending);
  logic[7:0] counter;
  always_ff @(posedge CLK) begin
    if(trigger) begin
      finished <= 1'b0;
      counter <= 8'd10;
      processor_to_sender <= data;
      start_send <= 1'b1;
    end else begin
      start_send <= 1'b0;
      if(counter) counter <= counter - 8'b1;
      else if(!sending) begin
        finished <= 1'b1;
      end
    end
  end
endmodule
