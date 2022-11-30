module pc(npc, pc, rst, PCEnF, clk);

  input clk, rst, PCEnF; // 时钟信号，复位信号
  input [31: 0] npc; // 32位输入，指令的地址
  output reg [31: 0] pc;  // 32位输出，指令的地址

  initial
    begin
        pc = 32'h3000;
    end

  always @(posedge clk or posedge rst) begin
    if (rst)
        begin
          pc = 32'h3000; // 复位信号，将DO设置为0
          // $display("(PC.v) pc: %h", pc);
        end
    else if(PCEnF == 1)  // 满足写使能信号才能写入
        pc = npc;
  end

endmodule