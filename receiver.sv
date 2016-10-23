`timescale 1ns / 1ps

module receiver #(parameter T = 2604)(
  input CLK,
  input UART_RX,
  output logic[7:0] data,
  output logic finished
  );
  logic[7:0] data_tmp;
  integer in_cnt,in_pos,in_flag=0;

  always_ff @(posedge CLK)
  begin
    if(in_flag==0) begin
      finished <= 0;
      if(UART_RX==0) begin
        in_flag<=2;
        in_cnt<=-T-1102;
        in_pos<=0;
      end
    end else if (in_flag==2) begin
      if(in_cnt==0) begin
        data_tmp[in_pos]<=UART_RX;
        in_cnt <= in_cnt + 1;
      end else if (in_cnt==10) begin
        in_pos <= in_pos + 1;
        in_cnt <= in_cnt - T + 1;
      end else if (in_cnt==5 && in_pos==7) begin
        in_flag<=3;
        finished <=1;
//        $display("finished bit raised\n");
        data<=data_tmp;
        in_cnt <= in_cnt - T + 1;
      end else begin
        in_cnt<=in_cnt+1;
      end
    end else if (in_flag==3) begin
      in_cnt <= in_cnt+1;
      if(in_cnt==0) begin
        finished<=0;
        in_flag<=0;
        in_pos<=0;
      end
    end else begin
      finished<=0;
      in_cnt<=0;
      in_pos<=0;
      in_flag<=0;
    end
  end
endmodule
