module alu (a, b, zero, result, alu_ctrl, shamt);
    input [31:0] a,b;  // 两个操作数
    input [3: 0] alu_ctrl;
    input [4: 0] shamt;
    output zero;  // 运算的结果是否为0的信号
    output reg[31:0] result; // 输出运算结果

   // 支持的所有ALU运算
    parameter AND   = 4'b0000;
    parameter OR    = 4'b0001;
    parameter ADD   = 4'b0010;
    parameter XOR   = 4'b0011;
    parameter ORI   = 4'b0100;
    parameter ADDIU = 4'b0101;
    parameter SUB   = 4'b0110;
    parameter ADDI  = 4'b0111;
    parameter SLL   = 4'b1000;
    parameter SLT   = 4'b0111;
    parameter LUI   = 4'b1111;  // 16位扩展
    
    always@(*)
    begin
        case(alu_ctrl)
            ADD : result = a + b;
            SUB : result = a - b;
            AND : result = a & b;
            OR  : result = a | b;
            SLT : result = (a < b);
            XOR : result = a ^ b;
            LUI : result = (b << 16);  // 对于LUI指令，左移16位
            ADDIU : result = a + b;
            ORI : result = a | b;
            SLL : result = (a << shamt);
        endcase
        // $display("(ALU.v) alu_ctrl: %b ,a: %h, b: %h, result: %h ", alu_ctrl, a, b, result);
    end

    assign zero = (result == 0);

endmodule