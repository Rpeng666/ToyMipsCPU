`include "./datapath/pc.v"
`include "./datapath/im.v"
`include "./datapath/regfile.v"
`include "./datapath/alu.v"
`include "./datapath/dm.v"
`include "./datapath/ext.v"
`include "./datapath/npc.v"
`include "./datapath/mux.v"

module datapath(clk, rst, op, func, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, NPCop, ExtOp, ALUctr);
    // op,  // 指令的op段
    // func,  // 指令的func段
    // RegWr,   //寄存器能否写入的信号
    // ALUSrc,   // ALU是否有输入来自立即数
    // RegDst,    // 控制寄存器写入地址
    // MemtoReg,  // 数据存储器能否写入寄存器
    // MemWr,   // 数据存储器能否被写入
    // Branch,    // 是否是分支指令
    // Jump,    // 是否是无条件跳转指令
    // ExtOp,    // 是否符号扩展
    // ALUctr    // 控制ALU功能
    input clk, rst, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp;
    input[3:0] ALUctr, NPCop;

    output[5:0] op, func;


    wire [31: 0] instruction;
    wire [31:0] PC, NPC;

    assign op = instruction[31: 26];
    assign func = instruction[5: 0];

    wire[4:0]  Rs = instruction[25: 21];
    wire[4: 0] Rt = instruction[20: 16];
    wire[4: 0] Rd = instruction[15: 11];
    wire[31: 0] rs_data, rt_data;

    wire Zero;
    wire [4: 0] shamt = instruction[10: 6];
    wire [31: 0] data, ext_result, result;
    wire [15: 0] imm16 = instruction[15: 0];

    wire [31: 0] dout, wd;
    wire [25: 0] target = instruction[25: 0];

    pc pc(NPC, PC, rst, clk);

    im_4k im(PC, instruction);

    ext SignExt(imm16, ext_result, ExtOp);

    mux1 aluMux(rt_data, ext_result, data, ALUSrc);

    alu alu(rs_data, data, zero, result, ALUctr, shamt);

    mux2 regMux(result, dout, wd, MemtoReg);

    regfile regfile(Rs, Rt, Rd, rs_data, rt_data, wd, RegWr, RegDst, clk);

    dm_4k dm(result, rt_data, MemWr, clk, dout);  //这里的result是地址

    npc npc(PC, NPC, NPCop, target, ext_result, zero);
endmodule