module dm_4k(addr, din, we, clk, dout);
    input [31: 0] addr;  // 要读写的数据的地址
    input [31: 0] din; // 要写入数据
    input we; // 写使能信号
    input clk;

    output [31: 0] dout; //读出数据

    reg [31: 0] dm[1023: 0]; // 数据寄存器

    initial
      $readmemh("data.txt", dm, 0 ,1023);

  always @(posedge clk) begin 
    if(we)   // 写入数据
      begin
        dm[addr] = din;
        $display("dm:%d<=%h", addr, din);
      end
    end

  assign dout = dm[addr];   // 读出数据

endmodule