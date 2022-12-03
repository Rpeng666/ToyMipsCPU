module regfile(rs, rt, RegWrDst_W, rs_data, rt_data, wd, wr, if_overflow, clk);
    input [4: 0] rs, rt, RegWrDst_W; // 三个寄存器编号信号
    input[31: 0] wd; // 写入寄存器的值
    input wr; // 决定能否写入寄存器的信号
    input if_overflow;
    input clk; // 时钟信号
    
    output [31: 0] rs_data, rt_data; // 两个寄存器读出的值

    reg [31: 0] rf[31: 0];  // 31个32位寄存器

    integer i;
    initial begin
      for (i = 0; i < 32; i = i + 1)
        rf[i] = 32'b0;
    end

  always @(posedge clk) begin
    if (wr & ! if_overflow )begin 
          rf[RegWrDst_W] = wd;  // 写入Rd
          // $display("(regfile.v) WRITE MODE rt: %d, rd: %d", rt, rd);
          $display("reg:$%d<=%h", RegWrDst_W, wd);
        end
  end

  assign rs_data = (rs == 0) ? 32'b0: 
                    (rs == RegWrDst_W) ? wd: rf[rs];  // 读出数据,而且解决了同时读写同一个寄存器的问题

  assign rt_data = (rt == 0) ? 32'b0:
                    (rt == RegWrDst_W) ? wd: rf[rt];
endmodule