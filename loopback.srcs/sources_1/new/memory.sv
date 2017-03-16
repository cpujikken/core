`timescale 1ns / 1ps

// x clock
module memory(
    input logic CLK,
    input logic[31:0] addr,
    input logic writeMem,
    input logic[31:0] writeWord,
    output logic[31:0] val
    );
    /*
    blk_mem_gen_1 memwiz(
      .addra(addr[11:2]),
      .clka(CLK),
      .dina(writeWord),
      .douta(val),
      .ena(1'b1),
      .wea(writeMem)
      );*/
    blk_mem_gen_0 memwiz(
      .addra(addr[19:2]),
      .clka(CLK),
      .dina(writeWord),
      .douta(val),
      .ena(1'b1),
      .wea(writeMem)
      );
/*
    logic[7:0] mem[0:199];
    initial begin
mem[0] <= 8'b00000000;mem[1] <= 8'b00000000;mem[2] <= 8'b00000000;mem[3] <= 8'b00011100;mem[4] <= 8'b00111111;mem[5] <= 8'b11000110;mem[6] <= 8'b01100110;mem[7] <= 8'b01100110;mem[8] <= 8'b00111111;mem[9] <= 8'b10111001;mem[10] <= 8'b10011001;mem[11] <= 8'b10011010;mem[12] <= 8'b01000000;mem[13] <= 8'b00100000;mem[14] <= 8'b00000000;mem[15] <= 8'b00000000;mem[16] <= 8'b00111111;mem[17] <= 8'b11001100;mem[18] <= 8'b11001100;mem[19] <= 8'b11001101;mem[20] <= 8'b01000000;mem[21] <= 8'b10100110;mem[22] <= 8'b01100110;mem[23] <= 8'b01100110;mem[24] <= 8'b01000000;mem[25] <= 8'b00100110;mem[26] <= 8'b01100110;mem[27] <= 8'b01100110;mem[28] <= 8'b10011100;mem[29] <= 8'b00100000;mem[30] <= 8'b00000000;mem[31] <= 8'b00000100;mem[32] <= 8'b10011100;mem[33] <= 8'b01000000;mem[34] <= 8'b00000000;mem[35] <= 8'b00001000;mem[36] <= 8'b00100100;mem[37] <= 8'b01100010;mem[38] <= 8'b00001000;mem[39] <= 8'b00000000;mem[40] <= 8'b10011100;mem[41] <= 8'b10000000;mem[42] <= 8'b00000000;mem[43] <= 8'b00001100;mem[44] <= 8'b10011100;mem[45] <= 8'b10100000;mem[46] <= 8'b00000000;mem[47] <= 8'b00010000;mem[48] <= 8'b00101100;mem[49] <= 8'b11000100;mem[50] <= 8'b00101000;mem[51] <= 8'b00000000;mem[52] <= 8'b10011100;mem[53] <= 8'b11100000;mem[54] <= 8'b00000000;mem[55] <= 8'b00010100;mem[56] <= 8'b10011101;mem[57] <= 8'b00000000;mem[58] <= 8'b00000000;mem[59] <= 8'b00011000;mem[60] <= 8'b00110001;mem[61] <= 8'b00100111;mem[62] <= 8'b01000000;mem[63] <= 8'b00000000;mem[64] <= 8'b00101001;mem[65] <= 8'b01000010;mem[66] <= 8'b00001000;mem[67] <= 8'b00000000;mem[68] <= 8'b11001001;mem[69] <= 8'b01101010;mem[70] <= 8'b00000000;mem[71] <= 8'b00000000;mem[72] <= 8'b10110001;mem[73] <= 8'b10001010;mem[74] <= 8'b00000000;mem[75] <= 8'b00000000;mem[76] <= 8'b00110101;mem[77] <= 8'b01101100;mem[78] <= 8'b00000000;mem[79] <= 8'b00000000;mem[80] <= 8'b00100000;mem[81] <= 8'b00000000;mem[82] <= 8'b00000000;mem[83] <= 8'b01011000;mem[84] <= 8'b01111001;mem[85] <= 8'b00000000;mem[86] <= 8'b00000000;mem[87] <= 8'b00000100;mem[88] <= 8'b01111001;mem[89] <= 8'b00100000;mem[90] <= 8'b00000000;mem[91] <= 8'b01100100;mem[92] <= 8'b01111001;mem[93] <= 8'b01000000;mem[94] <= 8'b00000000;mem[95] <= 8'b10000000;mem[96] <= 8'b11010001;mem[97] <= 8'b01101010;mem[98] <= 8'b01001000;mem[99] <= 8'b00000000;mem[100] <= 8'b11000100;mem[101] <= 8'b01100000;mem[102] <= 8'b00000000;mem[103] <= 8'b00000001;mem[104] <= 8'b11000100;mem[105] <= 8'b11000000;mem[106] <= 8'b00000000;mem[107] <= 8'b00000001;mem[108] <= 8'b11000101;mem[109] <= 8'b00100000;mem[110] <= 8'b00000000;mem[111] <= 8'b00000001;mem[112] <= 8'b11000101;mem[113] <= 8'b01000000;mem[114] <= 8'b00000000;mem[115] <= 8'b00000001;mem[116] <= 8'b11000101;mem[117] <= 8'b01100000;mem[118] <= 8'b00000000;mem[119] <= 8'b00000001;mem[120] <= 8'b11000101;mem[121] <= 8'b10000000;mem[122] <= 8'b00000000;mem[123] <= 8'b00000001;mem[124] <= 8'b11000101;mem[125] <= 8'b01100000;mem[126] <= 8'b00000000;mem[127] <= 8'b00000000;mem[128] <= 8'b11011000;mem[129] <= 8'b00000000;mem[130] <= 8'b00000000;mem[131] <= 8'b00000000;
    end

//    blk_mem_gen_1 memor(
    always_ff @(posedge CLK) begin
      if(writeMem) begin
        {mem[addr],mem[addr+1],mem[addr+2],mem[addr+3]} <= writeWord;
        val<=writeWord;
      end else begin
        val<={mem[addr],mem[addr+1],mem[addr+2],mem[addr+3]};
      end
    end
    */
endmodule

/*
module memory(
    input logic CLK,
    input logic[31:0] addr,
    input logic writeMem,
    input logic[31:0] writeWord,
    output logic[31:0] val
    );
    logic[7:0] mem[0:100];
    integer some;
    always_ff @(posedge CLK) begin
      if(writeMem) begin
        {mem[addr],mem[addr+1],mem[addr+2],mem[addr+3]} <= writeWord;
        val<=writeWord;
      end else begin
        val<={mem[addr],mem[addr+1],mem[addr+2],mem[addr+3]};
      end
    end
endmodule


*/
