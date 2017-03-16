`timescale 1ns / 1ps
module controller #(
	parameter O_NOP   = 6'b000000,
	parameter O_ADD   = 6'b000001,
	parameter O_SUB   = 6'b000010,
	parameter O_ADDI  = 6'b000011,
	parameter O_HALF  = 6'b000100,
	parameter O_FOUR  = 6'b000101,
	parameter O_J     = 6'b000110,
	parameter O_JZ    = 6'b000111,
	parameter O_FJLT  = 6'b001000,
	parameter O_FADD  = 6'b001001,
	parameter O_FSUB  = 6'b001010,
	parameter O_FMUL  = 6'b001011,
	parameter O_FDIV  = 6'b001100,
	parameter O_FCMP  = 6'b001101,
	parameter O_FJEQ  = 6'b001110,
	parameter O_CMP   = 6'b001111,
//	parameter O_ADDI     = 6'b010000,
	parameter O_LINK  = 6'b010001,
//	parameter O_OUT  = 6'b010010,
	parameter O_JC    = 6'b010011,
//	parameter O_ADDI  = 6'b010100,
	parameter O_MV    = 6'b010101,
	parameter O_NEG1  = 6'b010110,
	parameter O_FNEG1 = 6'b010111,
	parameter O_NEG2  = 6'b011000,
	parameter O_FNEG2 = 6'b011001,
	parameter O_INC   = 6'b011010,
	parameter O_DEC   = 6'b011011,
	parameter O_INC1  = 6'b011100,
	parameter O_DEC1  = 6'b011101,
	parameter O_MVI   = 6'b011110,
	parameter O_LDR   = 6'b011111,

	parameter O_LDD   = 6'b100000,
	parameter O_LDA   = 6'b100001,
	parameter O_SDR   = 6'b100010,
	parameter O_SDD   = 6'b100011,
	parameter O_SDA   = 6'b100100,
	parameter O_FLDR  = 6'b100101,
	parameter O_FLDD  = 6'b100110,
	parameter O_FLDA  = 6'b100111,
	parameter O_FSDR  = 6'b101000,
	parameter O_FSDD  = 6'b101001,
	parameter O_FSDA  = 6'b101010,
//	parameter O_XOR   = 6'b101011,
	parameter O_FMV   = 6'b101100,
	parameter O_SL    = 6'b101101,
	parameter O_SR    = 6'b101110,
	parameter O_RF    = 6'b101111,
	parameter O_RI    = 6'b110000,
	parameter O_PRINT = 6'b110001,
	parameter O_FABS  = 6'b110010,
	parameter O_MUL   = 6'b110011,
	parameter O_DIV   = 6'b110100,
	parameter O_SIP   = 6'b110101,
	parameter O_FIN   = 6'b110110,
  parameter O_CEQ   = 6'b110111,
  parameter O_RC    = 6'b111000,

/*	parameter O_ADDI  = 6'b110111,
	parameter O_ADDI  = 6'b111000,
	parameter O_ADDI  = 6'b111001,
	parameter O_ADDI  = 6'b111010,
	parameter O_ADDI  = 6'b111011,
	parameter O_ADDI  = 6'b111100,
	parameter O_ADDI  = 6'b111101,
	parameter O_ADDI  = 6'b111110,
	parameter O_ADDI  = 6'b111111,*/
	parameter FLLT    = 2'b00,
	parameter FLEQ    = 2'b01,
	parameter FLGT    = 2'b10,

  parameter REG_SP  = 5'd31,
  parameter REG_CL  = 5'd0

)(
	input logic CLK,
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
	output logic LED7,
  input logic is_test
);
	logic in;
	assign in = UART_RX;

  logic[31:0] addr,WD,RD;
  logic[4:0] A1,A2,A3,A1_d;
  logic writeMem;

  logic[31:0] PC;
  logic[31:0] writein_p;
  logic[7:0] state;

  logic signed[31:0] regint[0:31];
  logic[31:0] regf[0:31];
  logic[20:0] lst21;
  logic signed[20:0] lst21_signed;
  logic signed[15:0] lst16_signed;
  logic[25:0] lst26;
  logic[5:0] op;
  logic[3:0] size4;
  logic[5:0] RO;
  always_latch begin
    if(state==8'd2) begin
      op = RD[31:26];
      A1 = RD[25:21];
      A2 = RD[20:16];
      A3 = RD[15:11];
    end
  end
  assign lst21 = RD[20:0];
  assign lst21_signed = RD[20:0];
  assign lst16_signed = RD[15:0];
  assign lst26 = RD[25:0];
  assign size4 = RD[15:12];
  assign RO = RD[11:7];
  memory mm(CLK,addr,writeMem,WD,RD);
  logic input_empty1b,input_empty4b;
  logic[31:0] nextInput4b;
  logic[7:0] nextInput1b;
  logic execPop1b,execPop4b,execOutput;

  logic[7:0] outputData;

  integer RC_counter;
  logic isEOF;
  InputBuffer IBF(CLK,in,SW7,execPop4b,execPop1b,input_empty4b,input_empty1b,nextInput4b,nextInput1b);
  WordOutput WOU(CLK,outputData,execOutput,outFinished,UART_TX);

  logic fadd_ok_1,fadd_ok_2;
  logic[31:0] FADD_IN1, FADD_IN2, FADD_RET;
  logic fadd_ok,fadd_reset;
  assign fadd_ok = (fadd_ok_1 & fadd_ok_2);
  logic fadd_exec,fadd_complete;
  floating_point_0 fadd(
    .s_axis_a_tdata(FADD_IN1),
    .s_axis_a_tready(fadd_ok_1),
    .s_axis_a_tvalid(fadd_exec),
    .s_axis_b_tdata(FADD_IN2),
    .s_axis_b_tready(fadd_ok_2),
    .s_axis_b_tvalid(fadd_exec),
    .m_axis_result_tdata(FADD_RET),
    .m_axis_result_tready(1'b1),
    .m_axis_result_tvalid(fadd_complete),
    .aclk(CLK),
    .aresetn(fadd_reset)
    );

  logic fsub_ok_1,fsub_ok_2;
  logic[31:0] FSUB_IN1, FSUB_IN2, FSUB_RET;
  logic fsub_ok,fsub_reset;
  assign fsub_ok = (fsub_ok_1 & fsub_ok_2);
  logic fsub_exec,fsub_complete;
  floating_point_2 fsub(
    .s_axis_a_tdata(FSUB_IN1),
    .s_axis_a_tready(fsub_ok_1),
    .s_axis_a_tvalid(fsub_exec),
    .s_axis_b_tdata(FSUB_IN2),
    .s_axis_b_tready(fsub_ok_2),
    .s_axis_b_tvalid(fsub_exec),
    .m_axis_result_tdata(FSUB_RET),
    .m_axis_result_tready(1'b1),
    .m_axis_result_tvalid(fsub_complete),
    .aclk(CLK),
    .aresetn(fsub_reset)
    );

  logic fmul_ok_1,fmul_ok_2;
  logic[31:0] FMUL_IN1, FMUL_IN2, FMUL_RET;
  logic fmul_ok,fmul_reset;
  assign fmul_ok = (fmul_ok_1 & fmul_ok_2);
  logic fmul_exec,fmul_complete;
  floating_point_3 fmul(
    .s_axis_a_tdata(FMUL_IN1),
    .s_axis_a_tready(fmul_ok_1),
    .s_axis_a_tvalid(fmul_exec),
    .s_axis_b_tdata(FMUL_IN2),
    .s_axis_b_tready(fmul_ok_2),
    .s_axis_b_tvalid(fmul_exec),
    .m_axis_result_tdata(FMUL_RET),
    .m_axis_result_tready(1'b1),
    .m_axis_result_tvalid(fmul_complete),
    .aclk(CLK),
    .aresetn(fmul_reset)
    );

  logic fdiv_ok_1,fdiv_ok_2;
  logic[31:0] FDIV_IN1, FDIV_IN2, FDIV_RET;
  logic fdiv_ok,fdiv_reset;
  assign fdiv_ok = (fdiv_ok_1 & fdiv_ok_2);
  logic fdiv_exec,fdiv_complete;
  floating_point_4 fdiv(
    .s_axis_a_tdata(FDIV_IN1),
    .s_axis_a_tready(fdiv_ok_1),
    .s_axis_a_tvalid(fdiv_exec),
    .s_axis_b_tdata(FDIV_IN2),
    .s_axis_b_tready(fdiv_ok_2),
    .s_axis_b_tvalid(fdiv_exec),
    .m_axis_result_tdata(FDIV_RET),
    .m_axis_result_tready(1'b1),
    .m_axis_result_tvalid(fdiv_complete),
    .aclk(CLK),
    .aresetn(fdiv_reset)
    );
  logic[31:0] IDIV_DIVISOR,IDIV_DIVIDEND;
  logic[63:0] IDIV_RET;
  logic idiv_exec,idiv_complete,idiv_reset;
  div_gen_0 idiv(
    .s_axis_divisor_tdata(IDIV_DIVISOR),
    .s_axis_divisor_tvalid(idiv_exec),
    .s_axis_dividend_tdata(IDIV_DIVIDEND),
    .s_axis_dividend_tvalid(idiv_exec),
    .m_axis_dout_tdata(IDIV_RET),
    .m_axis_dout_tvalid(idiv_complete),
    .aclk(CLK),
    .aresetn(idiv_reset)
    );
/*
  logic fless_ok_1,fless_ok_2;
  logic[31:0] FLESS_IN1,FLESS_IN2;
  logic[7:0] FLESS_RET;
  logic fless_ok, fless_reset;
  assign fless_ok = (fless_ok_1 & fless_ok_2);
  logic fless_exec, fless_complete;
  floating_point_1 fless(
    .s_axis_a_tdata(FLESS_IN1),
    .s_axis_a_tready(fless_ok_1),
    .s_axis_a_tvalid(fless_exec),
    .s_axis_b_tdata(FLESS_IN2),
    .s_axis_b_tready(fless_ok_2),
    .s_axis_b_tvalid(fless_exec),
    .m_axis_result_tdata(FLESS_RET),
    .m_axis_result_tready(1'b1),
    .m_axis_result_tvalid(fless_complete),
    .aclk(CLK),
    .aresetn(fless_reset)
    );

  logic feq_ok_1,feq_ok_2;
  logic[31:0] FEQ_IN1,FEQ_IN2;
  logic[7:0] FEQ_RET;
  logic feq_ok, feq_reset;
  assign feq_ok = (feq_ok_1 & feq_ok_2);
  logic feq_exec, feq_complete;
  floating_point_5 feq(
    .s_axis_a_tdata(FEQ_IN1),
    .s_axis_a_tready(feq_ok_1),
    .s_axis_a_tvalid(feq_exec),
    .s_axis_b_tdata(FEQ_IN2),
    .s_axis_b_tready(feq_ok_2),
    .s_axis_b_tvalid(feq_exec),
    .m_axis_result_tdata(FEQ_RET),
    .m_axis_result_tready(1'b1),
    .m_axis_result_tvalid(feq_complete),
    .aclk(CLK),
    .aresetn(feq_reset)
    );
    */
  logic[5:0] counter;
  logic zeroFlag;
  logic[1:0] floatCmp;
  logic[31:0] jumpTo;

  logic[15:0] initial_memory_counter;
  logic[31:0] initial_memory[0:65];
  logic[7:0] initial_timer;
  initial begin
  initial_memory[0] <= 32'b00000000000000000000000000011100;initial_memory[1] <= 32'b00111111110001100110011001100110;initial_memory[2] <= 32'b00111111101110011001100110011010;initial_memory[3] <= 32'b01000000001000000000000000000000;initial_memory[4] <= 32'b00111111110011001100110011001101;initial_memory[5] <= 32'b01000000101001100110011001100110;initial_memory[6] <= 32'b01000000001001100110011001100110;initial_memory[7] <= 32'b10011100001000000000000000000100;initial_memory[8] <= 32'b10011100010000000000000000001000;initial_memory[9] <= 32'b00110100001000100000000000000000;initial_memory[10] <= 32'b01100100011000010000000000000000;initial_memory[11] <= 32'b01100100100000100000000000000000;initial_memory[12] <= 32'b00110100011001000000000000000000;initial_memory[13] <= 32'b10011100101000000000000000000100;initial_memory[14] <= 32'b00110100001001010000000000000000;initial_memory[15] <= 32'b11011000000000000000000000000000;
  end
  always_ff @(posedge CLK) begin
    if(SW7) begin
      isEOF <= 1'b0;
      RC_counter <= 0;
      LED2 <= 1'b0;
      LED3 <= 1'b0;
      fadd_reset <= 1'b1;
      fsub_reset <= 1'b1;
      fmul_reset <= 1'b1;
      fdiv_reset <= 1'b1;
      idiv_reset <= 1'b1;
      fadd_exec <= 1'b0;
      fsub_exec <= 1'b0;
      fmul_exec <= 1'b0;
      fdiv_exec <= 1'b0;
      idiv_exec <= 1'b0;
      LED4 <= 1'b0;
      LED5 <= 1'b0;
      LED6 <= 1'b0;
      LED7 <= 1'b0;
      execOutput<=1'b0;
      PC <= 32'b0;
      writein_p<=32'b0;
      state<=8'd10;
      writeMem<=1'b0;
      execPop4b<=1'b0;
      execPop1b<=1'b0;
      addr<=32'b0;
      counter <= 6'b0;
      initial_memory_counter <= 10'd0;
      initial_timer <= 8'd10;
      for(int i = 0; i < 32; i++)
        regint[i]<=32'b0;
    end
    else if(SW6) begin
      if(counter > 6'd0) begin
        counter <= counter - 6'd1;
      end else begin
        writeMem <= 1'b0;
      end
      if(execPop4b == 1'b1) begin
        execPop4b <= 1'b0;
      end
      else begin
        if(is_test) begin
          if(initial_timer == 8'd0) begin
            addr <= writein_p;
            WD <= initial_memory[initial_memory_counter];
            writeMem <= 1'b1;
            writein_p <= writein_p + 32'd4;
            initial_memory_counter <= initial_memory_counter + 10'd1;
            counter <= 6'd1;
            initial_timer <= 8'd5;
          end else begin
            initial_timer <= initial_timer - 8'd1;
          end
        end else if(input_empty4b == 1'b0) begin
          addr <= writein_p;
          WD <= nextInput4b;
          counter <= 6'd1;
          writeMem <= 1'b1;
          execPop4b <= 1'b1;
          writein_p <= writein_p + 32'd4;
        end
      end
    end
    else begin
      if(state==8'd0) begin               // set Instruction address
        addr<=PC;
        state <= 8'd1;
      end else if(state==8'd1) begin      // wait for memory
        state <= 8'd20;
        PC <= PC + 32'd4;
      end else if(state==8'd20) begin
        state <= 8'd2;
      end else if(state == 8'd10) begin //INITIALIZE PROGRAM COUNTER
        addr <= 32'b0;
        writeMem <= 1'b0;
        state <= 8'd11;
      end else if(state == 8'd11) begin //WAIT FOR MEMORY
        state <= 8'd12;
      end else if(state == 8'd12) begin
        state <= 8'd13;
      end else if(state == 8'd13) begin
        state <= 8'd14;

      end else if(state == 8'd14) begin
        PC <= RD;
        state <= 8'd0;
      end else begin
        {LED7,LED6,LED5,LED4,LED3,LED2} <= op;
        if(op==O_NOP) begin
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_ADD) begin
          regint[A1] <= regint[A2] + regint[A3];
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_SUB) begin
          regint[A1] <= regint[A2] - regint[A3];
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_ADDI) begin
          regint[A1] <= regint[A2] + lst16_signed;
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_HALF) begin
          regint[A1] <= {regint[A2][31], regint[A2][31], regint[A2][30:1]};
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_FOUR) begin
          regint[A1] <= {regint[A2][29:0],2'b0};
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_J) begin
          PC <= {6'b0, lst26};
          addr <= {6'b0, lst26};
          state <= 8'd1;
        end else if(op==O_JZ) begin
          if(zeroFlag) begin
            PC <= {6'b0, lst26};
            addr <= {6'b0, lst26};
          end else begin
            addr <= PC;
          end
          state <= 8'd1;
        end else if(op==O_FJLT) begin
          if(floatCmp==FLLT) begin
            PC <= {6'b0, lst26};
            addr <= {6'b0, lst26};
          end else begin
            addr <= PC;
          end
          state <= 8'd1;
        end else if(op==O_FADD) begin
          if(state==8'd2) begin
            fadd_reset <= 1'b0;
            state <= 8'd3;
            FADD_IN1 <= regf[A2];
            FADD_IN2 <= regf[A3];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            fadd_reset <= 1'b1;
            if(fadd_ok) begin
              fadd_exec <= 1'b1;
              state <= 8'd5;
            end
          end else if(state==8'd5) begin
            if(fadd_complete) begin
              regf[A1] <= FADD_RET;
              addr <= PC;
              state <= 8'd1;
              fadd_exec <= 1'b0;
            end
          end
        end else if(op==O_FSUB) begin
          if(state==8'd2) begin
            fsub_reset <= 1'b0;
            state <= 8'd3;
            FSUB_IN1 <= regf[A2];
            FSUB_IN2 <= regf[A3];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            fsub_reset <= 1'b1;
            if(fsub_ok) begin
              fsub_exec <= 1'b1;
              state <= 8'd5;
            end
          end else if(state==8'd5) begin
            if(fsub_complete) begin
              regf[A1] <= FSUB_RET;
              addr <= PC;
              state <= 8'd1;
              fsub_exec <= 1'b0;
            end
          end
        end else if(op==O_FMUL) begin
          if(state==8'd2) begin
            fmul_reset <= 1'b0;
            state <= 8'd3;
            FMUL_IN1 <= regf[A2];
            FMUL_IN2 <= regf[A3];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            fmul_reset <= 1'b1;
            if(fmul_ok) begin
              fmul_exec <= 1'b1;
              state <= 8'd5;
            end
          end else if(state==8'd5) begin
            if(fmul_complete) begin
              regf[A1] <= FMUL_RET;
              addr <= PC;
              state <= 8'd1;
              fmul_exec <= 1'b0;
            end
          end
        end else if(op==O_FDIV) begin
          if(state==8'd2) begin
            fdiv_reset <= 1'b0;
            state <= 8'd3;
            FDIV_IN1 <= regf[A2];
            FDIV_IN2 <= regf[A3];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            fdiv_reset <= 1'b1;
            if(fdiv_ok) begin
              fdiv_exec <= 1'b1;
              state <= 8'd5;
            end
          end else if(state==8'd5) begin
            if(fdiv_complete) begin
              regf[A1] <= FDIV_RET;
              addr <= PC;
              state <= 8'd1;
              fdiv_exec <= 1'b0;
            end
          end
        end else if(op==O_FCMP) begin
        /*
          if(state==8'd2) begin
            fless_reset <= 1'b0;
            state <= 8'd3;
            FLESS_IN1 <= regf[A1];
            FLESS_IN2 <= regf[A2];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            fless_reset <= 1'b1;
            if(fless_ok) begin
              fless_exec <= 1'b1;
              state <= 8'd5;
            end
          end else if(state==8'd5) begin
            if(fless_complete) begin
            fless_exec <= 1'b0;
              if(FLESS_RET[0]) begin
                floatCmp <= FLLT;
                addr <= PC;
                state <= 8'd1;
              end else begin
                state<=8'd6;
                feq_reset <= 1'b0;
                FEQ_IN1 <= regf[A1];
                FEQ_IN2 <= regf[A2];
              end
            end
          end else if(state==8'd6) begin
            state <= 8'd7;
          end else if(state==8'd7) begin
            feq_reset <= 1'b1;
            if(feq_ok) begin
              feq_exec <= 1'b1;
              state <= 8'd8;
            end
          end else if(state==8'd8) begin
            if(feq_complete) begin
              feq_exec <= 1'b0;
              if(FEQ_RET[0]) begin
                floatCmp <= FLEQ;
              end else begin
                floatCmp <= FLGT;
              end
              state <= 8'd1;
              addr <= PC;
            end
          end
          */
          if(regf[A1] == regf[A2] || (regf[A1][30:0] == 31'b0 && regf[A2][30:0] == 31'b0)) begin
            floatCmp <= FLEQ; //EQUAL
          end else begin
            if(regf[A1][31] > regf[A2][31]) begin
              floatCmp <= FLLT; //LESS THAN
            end else if(regf[A1][31] < regf[A2][31]) begin
              floatCmp <= FLGT; //GREATER THAN
            end else if((regf[A1][30:0] < regf[A2][30:0]) ^ (regf[A1][31])) begin
              floatCmp <= FLLT;
            end else begin
              floatCmp <= FLGT;
            end
          end
          state <= 8'd1;
          addr <= PC;

        end else if(op==O_FJEQ) begin
          if(floatCmp == FLEQ) begin
            PC <= {6'b0, lst26};
            addr <= {6'b0, lst26};
          end else begin
            addr <= PC;
          end
          state <= 8'd1;
        end else if(op==O_CMP) begin        //TODO: compare signed?
          if(regint[A1] < regint[A2]) begin
            zeroFlag <= 1'b1;
          end else begin
            zeroFlag <= 1'b0;
          end
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_LINK) begin
          if(state == 8'd2) begin
            addr <= regint[REG_SP] - 32'd4;
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            regint[REG_SP] <= regint[REG_SP] - 32'd4;
            PC <= RD;
            addr <= RD;
            state <= 8'd1;
          end
        end else if(op==O_JC) begin
          if(state == 8'd3) begin
            addr <= regint[REG_CL];
            state <= 8'd3;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            state <= 8'd6;
          end else if(state==8'd6) begin
            PC <= RD;
            addr <= RD;
            state <= 8'd1;
          end
        end else if(op==O_MV) begin
          regint[A1] <= regint[A2];
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_NEG1) begin
          regint[A1] <= -regint[A1];
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_FNEG1) begin
          regf[A1] <= {regf[A1][31] ^ 1, regf[A1][30:0]};
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_NEG2) begin
          regint[A1] <= -regint[A2];
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_FNEG2) begin
          regf[A1] <= {regf[A2][31] ^ 1, regf[A2][30:0]};
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_INC) begin
          regint[A1] <= regint[A1] + 32'b1;
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_DEC) begin
          regint[A1] <= regint[A1] - 32'b1;
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_INC1) begin
          regint[A1] <= regint[A2] + 32'b1;
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_DEC1) begin
          regint[A1] <= regint[A2] - 32'b1;
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_MVI) begin
          regint[A1] <= lst21_signed;
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_LDR) begin
          if(state==8'd2) begin
            addr <= regint[A2] + lst16_signed;
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            regint[A1] <= RD;
            addr <= PC;
            state <= 8'd1;
          end
        end else if(op==O_LDD) begin
          if(state==8'd2) begin
            addr <= regint[A2] + regint[RO] * size4;
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            regint[A1] <= RD;
            addr <= PC;
            state <= 8'd1;
          end
        end else if(op==O_LDA) begin
          if(state==8'd2) begin
            addr <= {11'b0, lst21};
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            regint[A1] <= RD;
            addr <= PC;
            state <= 8'd1;
          end
        end else if(op==O_SDR) begin
          if(state==8'd2) begin
            addr <= regint[A2] + lst16_signed;
            writeMem <= 1'b1;
            WD <= regint[A1];
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            addr <= PC;
            writeMem <= 1'b0;
            state <= 8'd1;
          end
        end else if(op==O_SDD) begin
          if(state==8'd2) begin
            addr <= regint[A2] + regint[RO] * size4;
            state <= 8'd3;
            writeMem <= 1'b1;
            WD <= regint[A1];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            addr <= PC;
            writeMem <= 1'b0;
            state <= 8'd1;
          end
        end else if(op==O_SDA) begin
          if(state==8'd2) begin
            addr <= {11'b0, lst21};
            state <= 8'd3;
            writeMem <= 1'b1;
            WD <= regint[A1];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            addr <= PC;
            writeMem <= 1'b0;
            state <= 8'd1;
          end
        end else if(op==O_FLDR) begin
          if(state==8'd2) begin
            addr <= regint[A2] + lst16_signed;
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            regf[A1] <= RD;
            addr <= PC;
            state <= 8'd1;
          end
        end else if(op==O_FLDD) begin
          if(state==8'd2) begin
            addr <= regint[A2] + regint[RO] * size4;
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            regf[A1] <= RD;
            addr <= PC;
            state <= 8'd1;
          end
        end else if(op==O_FLDA) begin
          if(state==8'd2) begin
            addr <= {11'b0, lst21};
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            regf[A1] <= RD;
            addr <= PC;
            state <= 8'd1;
          end
        end else if(op==O_FSDR) begin
          if(state==8'd2) begin
            addr <= regint[A2] + lst16_signed;
            writeMem <= 1'b1;
            WD <= regf[A1];
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            addr <= PC;
            writeMem <= 1'b0;
            state <= 8'd1;
          end
        end else if(op==O_FSDD) begin
          if(state==8'd2) begin
            addr <= regint[A2] + regint[RO] * size4;
            state <= 8'd3;
            writeMem <= 1'b1;
            WD <= regf[A1];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            addr <= PC;
            writeMem <= 1'b0;
            state <= 8'd1;
          end
        end else if(op==O_FSDA) begin
          if(state==8'd2) begin
            addr <= {11'b0, lst21};
            state <= 8'd3;
            writeMem <= 1'b1;
            WD <= regf[A1];
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            state <= 8'd5;
          end else if(state==8'd5) begin
            addr <= PC;
            writeMem <= 1'b0;
            state <= 8'd1;
          end
        end else if(op==O_FMV) begin
          regf[A1] <= regf[A2];
          state <= 8'd1;
          addr <= PC;
        end else if(op==O_SL) begin
          regint[A1] <= (regint[A2] << regint[A3]);
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_SR) begin
          regint[A1] <= (regint[A2] >> regint[A3]);
          addr <= PC;
          state <= 8'd1;
/*        end else if (op==O_RI) begin
          if(state==8'd2) begin
            if(!input_empty) begin
              regint[A1] <= nextInput;
              execPop <= 1'b1;
              state <= 8'd3;
              if(nextInput == 32'd0)
                zeroFlag <= 1'b1;
              else
                zeroFlag <= 1'b0;
            end
          end else if(state==8'd3) begin
          // if(input_empty == 1'b0) begin
            execPop <= 1'b0;
            state<= 8'd1;
            addr <= PC;
          end
        end else if(op==O_RF) begin
          if(state==8'd2) begin
            if(!input_empty) begin
              regf[A1] <= nextInput;
              execPop <= 1'b1;
              state <= 8'd3;
            end
          end else if(state==8'd3) begin
            execPop <= 1'b0;
            state <= 8'd1;
            addr <= PC;
          end*/
        end else if(op==O_PRINT) begin
          if(state==8'd2) begin
            execOutput<=1'b1;
            state<=8'd3;
            if(RD[0]) outputData <= regf[A1][7:0];//FOR TEMPORARY USE
            else outputData <= regint[A1][7:0];
          end else if(state==8'd3) begin
            execOutput<=1'b0;
            state <= 8'd4;
          end else if(state==8'd4) begin
            if(outFinished) begin
              addr <= PC;
              state<=8'd1;
            end
          end
        end else if(op==O_FABS) begin
          regf[A1] = {1'b0, regf[A2][30:0]};
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_SIP) begin
          if(state == 8'd2) begin
            addr <= regint[REG_SP] - 32'd4;
            state <= 8'd3;
            writeMem <= 1'b1;
            WD <= PC + 32'd4;
          end else if(state == 8'd3) begin
            state <= 8'd4;
          end else if(state == 8'd4) begin
            state <= 8'd5;
          end else if(state == 8'd5) begin
            addr <= PC;
            writeMem <= 1'b0;
            state <= 8'd1;
          end
        end else if(op==O_FIN) begin
          state <= 8'd15;
        end else if(op==O_MUL) begin
          regint[A1] <= regint[A2] * regint[A3];
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_DIV) begin
          if(state==8'd2) begin
            IDIV_DIVISOR <= regint[A3];
            IDIV_DIVIDEND <= regint[A2];
            idiv_reset <= 1'b0;
            state <= 8'd3;
          end else if(state==8'd3) begin
            state <= 8'd4;
          end else if(state==8'd4) begin
            idiv_reset <= 1'b1;
            idiv_exec <= 1'b1;
            state <= 8'd5;
          end else if(state==8'd5) begin
            if(idiv_complete) begin
              regint[A1] <= IDIV_RET[63:32];
              addr <= PC;
              state <= 8'd1;
              idiv_exec <= 1'b0;
            end
          end
        end else if(op==O_CEQ) begin
          if(regint[A1] == regint[A2]) begin
            zeroFlag <= 1'b1;
          end else begin
            zeroFlag <= 1'b0;
          end
          addr <= PC;
          state <= 8'd1;
        end else if(op==O_RC) begin
          if(state==8'd2) begin
            if(!input_empty1b && !isEOF) begin
              regint[A1] <= nextInput1b;
              execPop1b <= 1'b1;
              state <= 8'd3;
            end else begin
              if(isEOF || RC_counter >= 30000000) begin
                regint[A1] <= 255;
                isEOF <= 1'b1;
                state <= 8'd3;
              end
              RC_counter <= RC_counter + 1;
            end
          end else begin
            RC_counter <= 0;
            addr <= PC;
            state <= 8'd1;
            execPop1b <= 1'b0;
          end
/*        end else begin
          addr <= PC;
          state <= 8'd1;
          */
        end
      end
    end
  end
endmodule
