`timescale 1ns / 1ps

module receiver #(
	parameter COUNT_WIDTH = 11,
	parameter COUNT_MAX = 11'd434  // 300000000/115200/2 = 1302.0833333333333
) (
	input logic CLK,
	input logic in,
	output logic[7:0] out,
	output logic received

);
	logic[COUNT_WIDTH-1:0] count_half_period = 0;
	logic receiving = 1'b0;
	logic[3:0] one_counter;
	logic[3:0] state = 4'b0000;  /* 0001->0010->receiving->0100->1000 */

	always_comb begin
		if (receiving && state == 4'b1111 && count_half_period == 0) begin
			received <= 1;
		end else begin
			received <= 0;
		end
	end

	always_ff @(posedge CLK) begin
		if (!{receiving, state} && !in) begin
			state <= 4'b0001;
		end

		if (count_half_period == COUNT_MAX) begin
			count_half_period <= 0;
			if (receiving) begin
				if (state == 4'b1111) begin
					receiving <= 0;
					state <= 4'b1000;
				end else begin
					state <= state + 1;
					if (!state[0]) begin
						out[state[3:1]] <= one_counter[3];
					end
				end
			end else begin
				if (state[1]) begin
					receiving <= 1;
					state <= 4'b0000;
				end else if (state[3]) begin
					state <= 4'b0000;
				end else begin
					state[0] <= state[3];
					state[1] <= state[0];
					state[2] <= state[1];
					state[3] <= state[2];
				end
			end
			one_counter <= 4'b0;
		end else if(count_half_period >= COUNT_MAX - 11'd15) begin
			if (receiving && state != 4'b1111) begin
				if (!state[0] && in) begin
				  one_counter <= one_counter + 4'b1;
				end
		  end
			if ({receiving, state}) begin
				count_half_period <= count_half_period + 1;
			end
		end else begin
			if ({receiving, state}) begin
				count_half_period <= count_half_period + 1;
			end
		end
	end
endmodule
