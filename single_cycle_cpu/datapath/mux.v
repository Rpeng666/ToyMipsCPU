// 判断ALU的第二个输入是来自立即数还是寄存器
module mux1(Rt_data, Ext_result, Data, ALUSrc);
    input [31:0] Rt_data;        // 寄存器的第二个输出
    input [31:0] Ext_result;     // 符号扩展后的值
    input ALUSrc;      // 0：选择寄存器的第二个输出 1：立即数扩展后的值
    output reg [31:0] Data;     // 选择后的值

    always @(*)
    begin
        if (ALUSrc)
            begin
                Data = Ext_result;
                // $display("(MUX.v) select ext_result: %h", Data);
            end
        else  
            begin
                Data = Rt_data;
                // $display("(MUX.v) select Rt_data: %h", Data);
            end       
    end
endmodule

// 控制写入regfile的数据来自ALU还是数据存储器
module mux2(ALUoutput, MEMouput, Data, MemtoReg);
    input [31:0] ALUoutput;        // ALU的输出
    input [31:0] MEMouput;     // 数据存储器的输出
    input MemtoReg;      // 0：选择ALU的输出 1：选择数据存储器的输出
    output reg [31:0] Data;     // 选择后的值

    always @(*)
    begin
        if (MemtoReg)
            begin
                Data = MEMouput;
                // $display("(MUX.v) select ALU_output: %h", Data);
            end
        else  
            begin
                Data = ALUoutput;
                // $display("(MUX.v) select DATAMEM_output: %h", Data);
            end       
    end
endmodule