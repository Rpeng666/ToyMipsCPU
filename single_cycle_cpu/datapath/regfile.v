module regfile(rs, rt, rd, rs_data, rt_data, wd, wr, RegDst, clk);
    input [4: 0] rs, rt, rd; // 三个寄存器编号信号
    input[31: 0] wd; // 写入寄存器的值
    input wr; // 决定能否写入寄存器的信号
    input clk; // 时钟信号
    input RegDst; //1:代表写入rt， 0：代表写入rd

    output [31: 0] rs_data, rt_data; // 两个寄存器读出的值

    reg[4: 0] addr;
    reg [31: 0] rf[31: 0];  // 31个32位寄存器

    integer i;
    initial begin
      for (i = 0; i < 32; i = i + 1)
        rf[i] = 0;
    end

  always @(posedge clk) begin
    if (wr)begin 
          addr = (RegDst == 1) ? rt : rd;
          rf[addr] = wd;  // 写入Rd
          // $display("(regfile.v) WRITE MODE rt: %d, rd: %d", rt, rd);
          $display("reg:$%d<=%h",addr, wd);
        end
  end

  assign rs_data = (rs == 0) ? 32'b0: rf[rs];  // 读出数据
  assign rt_data = (rt == 0) ? 32'b0: rf[rt];
  

endmodule