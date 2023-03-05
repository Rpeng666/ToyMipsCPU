`include "./control/controller.v"
`include "./datapath/datapath.v"

module Mips(clk, rst);
    input clk;
    input rst;

    // signal
    wire [5 : 0] op;
    wire [5: 0] func;
    wire RegDst;
    wire ALUSrc;
    wire MemtoReg;
    wire RegWr;
    wire MemWr;
    wire [3: 0] NPCop;
    wire ExtOp;
    wire [3: 0] ALUctr;
    wire if_branch;


    // 根据传入的op，func，rt，生成各种信号并输出
    controller controller(
        op,  // 指令的op段
        func,  // 指令的func段
        RegDst,    // 寄存器写入地址
        ALUSrc,   // ALU是否接受立即数
        MemtoReg,  // 数据存储器能否写入寄存器
        RegWr,   //寄存器能否写入的信号
        MemWr,   // 数据存储器能否被写入
        NPCop, // 判断跳转类型是Jump，Beq还是其他
        ExtOp,    // 是否符号扩展
        ALUctr,    // 控制ALU功能
        if_branch  // 用来判断是否是branch指令的信号，因为branch指令符号扩展稍微有点特殊
        );
        
    datapath datapath(
        clk,
        rst,
        op,       //指令的op段
        func,     // 指令的func段
        RegDst,    // 控制寄存器写入地址
        ALUSrc,   // ALU是否接受立即数 
        MemtoReg,   // 数据存储器能否写入寄存器
        RegWr,     // 寄存器能否写入的信号
        MemWr,     // 数据存储器能否写入的信号
        NPCop, // 判断跳转类型是Jump，Beq还是其他
        ExtOp,    // 是否符号扩展的信号
        ALUctr,    // 控制ALU功能的信号
        if_branch
        );

    
endmodule