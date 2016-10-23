
`timescale 1ns / 1ps
module sender #(parameter T = 2604)(
  input CLK,
  input logic[7:0] data_in,
  input logic finished,
  output logic UART_TX
  );
  integer out_cnt,out_pos,out_flag=0;
  logic[9:0] data;
  
  logic sending = 1'b0;
  
  always_comb begin
    if (sending==1'b0) begin
      UART_TX <= 1'b1;
    end else begin
      UART_TX <= data[out_pos];
    end
  end

  always_ff @(posedge CLK)
  begin
    if(out_flag==0 && finished==1) begin
      out_flag<=1;
      out_cnt<=0;
      out_pos<=0;
      data<={1'b1,data_in,1'b0};
      sending <= 1'b1;
    end else if(out_flag==1) begin
      if (out_cnt==T) begin
        if(out_pos == 9) begin
          sending <= 1'b0;
          out_flag<=0;
        end else begin
          out_pos <= out_pos + 1;
          out_cnt<=1;
        end
      end else begin
         out_cnt<=out_cnt + 1;
      end
    end else begin
      out_cnt<=0;
      out_pos<=0;
      out_flag<=0;
    end
  end
endmodule
