`timescale 1ns / 1ps
module top_loopback(
	input logic CLK_P,
	input logic CLK_N,
	input logic UART_RX,
	output logic UART_TX
);
	logic start_send;
	logic[7:0] receiver_to_processor;
	logic[7:0] processor_to_sender;


	logic CLK;
	IBUFGDS ibufgds(.I(CLK_P), .IB(CLK_N), .O(CLK));

	logic in;
	always_ff @(posedge CLK)
	begin
	 in = UART_RX;
	end
	receiver receiver_instance(CLK, in, receiver_to_processor, start_send);
	editor editor_instance(CLK,finished,receiver_to_processor,processor_to_sender);
	sender sender_instance(CLK, processor_to_sender, start_send, UART_TX);

endmodule