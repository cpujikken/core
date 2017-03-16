module top_loopback(
	input logic CLK_P,
	input logic CLK_N,
	input logic UART_RX,
	input logic SW6,//reading
	input logic SW7,//initialize everything
	input logic SW8,
	input logic SW9,
	input logic SW10,
	output logic UART_TX,
	output logic LED2,
	output logic LED3,
	output logic LED4,
	output logic LED5,
	output logic LED6,
	output logic LED7
);
	logic received,start_send;
	logic[7:0] receiver_to_processor,processor_to_sender;


	logic CLK;
  logic locked;
	clk_wiz_0 clkwiz0(CLK_P,CLK_N, CLK,1'b0,locked);
//	IBUFGDS ibufgds(.I(CLK_P), .IB(CLK_N), .O(CLK));

//	controller cont(CLK,UART_RX,SW6,SW7,SW8,SW9,SW10,UART_TX,
  //  LED2,LED3,LED4,LED5,LED6,LED7,1'b0);

  assign UART_TX = UART_RX;
/*
  logic fin;

	receiver receiver_instance(CLK, UART_RX, receiver_to_processor, start_send);
	assign processor_to_sender = receiver_to_processor;
  sender sender_instance(CLK, processor_to_sender, start_send, UART_TX,fin,LED2,LED3,LED4,LED5,LED6,LED7);
  */
endmodule
