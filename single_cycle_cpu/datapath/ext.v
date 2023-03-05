module ext(imm, ext_result, ext_op);    // 符号扩展的模块
  input [15: 0] imm;       //需要符号扩展的16位立即数
  output reg [31: 0] ext_result;      // 32位扩展结果
  input ext_op;    // 控制是否进行有符号扩展的信号

  always @(*) begin
    if(ext_op == 1)
        ext_result = {{16{imm[15]}}, imm[15: 0]};
    else
        ext_result = {{16{1'b0}}, imm[15: 0]};
    
    // $display("(ext.v) imm: %h, ext_result: %h", imm, ext_result);
  end
endmodule