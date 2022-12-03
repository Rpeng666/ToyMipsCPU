module im_4k(PC, dout, PC_F);
    input [31: 0] PC; // 地址信号

    output reg [31:0] dout; // 要输出的指令
    output reg [31: 0] PC_F; // 其实这是完全没有必要的，但是PC变得太快，导致IF_ID输入的PC
                            // 是错误的，这里无奈中转一下

    reg [31:0] im[1023: 0]; //4k个字宽为32位的寄存器

    initial
        $readmemh("code.txt", im, 0, 1023);

    always @(*) begin
        dout = im[PC[11: 2]];  // 由于只支持4k存储，所以使用12位就行
        PC_F = PC;
        // $display("(IM.v) pc: %h", pc);
        // $display("(IM.v) instruction: %h", dout);
    end
     
endmodule