module im_4k(pc, dout);
    input [31: 0] pc; // 地址信号
    output reg [31:0] dout; // 要输出的指令

    reg [31:0] im[1023: 0]; //4k个字宽为32位的寄存器

    initial
        $readmemh("code.txt", im, 0, 1023);

    always @(*) begin
        dout = im[pc[11: 2]];  // 由于只支持4k存储，所以使用12位就行
        // $display("(IM.v) pc: %h", pc);
        // $display("(IM.v) instruction: %h", dout);
    end
     
endmodule