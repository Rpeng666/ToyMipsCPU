module alu (a, b, zero, result, alu_ctrl, shamt, PC_E, if_overflow);
    input [31:0] a,b;  // 两个操作数
    input [3: 0] alu_ctrl;
    input [4: 0] shamt;
    input [31: 0] PC_E;

    output zero;  // 运算的结果是否为0的信号
    output reg if_overflow; // 判断是否溢出
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
    // parameter SLL   = 4'b1000;
    parameter SLT   = 4'b1001;
    parameter LUI   = 4'b1111;  // 16位扩展
    
    always@(*) begin

        if_overflow = 1'b0;

        case(alu_ctrl)
            ADD : begin
                    result = a + b;
                    if(result[30: 0] != result) if_overflow = 1'b1; // 溢出检测
                end

            SUB : result = a - b;

            AND : result = a & b;

            OR  : result = a | b;
 
            SLT : result = (a < b);

            XOR : result = a ^ b;

            LUI : result = (b << 16);  // 对于LUI指令，左移16位
                    
            ADDIU : result = a + b;
        
            ADDI: begin
                    result = a + b;
                    if(result[30: 0] != result) if_overflow = 1'b1; // 溢出检测
                end

            ORI : result = a | b;

            // SLL : result = (a << shamt);
            default: begin
                    if_overflow = 1'b0;
                end
        endcase

        if(if_overflow) $display("overflow:%h", PC_E);

        // $display("(ALU.v) alu_ctrl: %b ,a: %h, b: %h, result: %h ", alu_ctrl, a, b, result);
    end

    assign zero = (result == 0);

endmodule