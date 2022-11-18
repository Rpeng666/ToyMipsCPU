`include "./datapath/pc.v"
`include "./datapath/im.v"
`include "./datapath/regfile.v"
`include "./datapath/alu.v"
`include "./datapath/dm.v"
`include "./datapath/ext.v"
`include "./datapath/npc.v"
`include "./datapath/mux.v"
`include "./datapath/mid_reg/EX_MEM.v"
`include "./datapath/mid_reg/ID_EX.v"
`include "./datapath/mid_reg/IF_ID.v"
`include "./datapath/mid_reg/MEM_WB.v"


module datapath(clk, rst, op, func, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, NPCop, ExtOp, ALUctr, if_branch);
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
    input clk, rst, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, if_branch;
    input[3:0] ALUctr, NPCop;

    output[5:0] op, func;


    wire [31: 0] instruction_F, instruction_D;
    wire [31:0] PC, NPC, PC_plus_4, PC_W, PC_D, PC_E, PC_M;

    assign op = instruction_D[31: 26];
    assign func = instruction_D[5: 0];

    wire[4: 0] Rs = instruction_D[25: 21];
    wire[4: 0] Rt = instruction_D[20: 16];
    wire[4: 0] Rd = instruction_D[15: 11];
    wire[31: 0] rs_data, rt_data, rt_data_M, rs_data_E, rt_data_E;

    wire zero, zero_M, zero_W;
    wire [4: 0] shamt = instruction_D[10: 6];
    wire [31: 0] data, ext_result, ext_result_M, ext_result_W, result, result_M;
    wire [15: 0] imm16 = instruction_D[15: 0];

    wire [31: 0] dout, wd, wd_W;
    wire [25: 0] target = instruction_D[25: 0];

    wire RegDst_E, RegDst_M, RegDst_W, ALUSrc_E, MemtoReg_E, MemtoReg_M, RegWr_E, MemWr_E, MemWr_M, ExtOp_E, RegWr_M, RegWr_W, if_branch_E;
    wire [3: 0] ALUctr_E, NPCop_E, NPCop_M, NPCop_W;
    wire [4: 0] Rs_E, Rt_E, Rt_M, Rt_W, Rd_E, shamt_E, Rd_M, Rd_W;
    wire [15: 0] imm16_E;
    wire [25: 0] target_E, target_M, target_W;

    
    //----------------取指阶段--------------------------
    pc pc(NPC, PC, rst, clk);

    assign PC_plus_4 = PC + 4;

    im_4k im(PC, instruction_F);
    //-------------------------------------------------
    IF_ID If_Id(clk, instruction_F, PC, 
                     instruction_D, PC_D); // 第一个流水寄存器
    //----------------译码阶段--------------------------

    //-------------------------------------------------
    ID_EX Id_Ex(clk, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, ALUctr, NPCop, Rs, Rt, Rd, shamt, imm16, target, PC_D, rs_data, rt_data, if_branch, 
                     RegDst_E, ALUSrc_E, MemtoReg_E, RegWr_E, MemWr_E, ExtOp_E, ALUctr_E, NPCop_E, Rs_E, Rt_E, Rd_E, shamt_E, imm16_E, target_E, PC_E, rs_data_E, rt_data_E, if_branch_E); // 第二个流水寄存器
    
    //----------------执行阶段--------------------------
    ext SignExt(imm16_E, ext_result, ExtOp_E, if_branch_E);

    mux1 aluMux(rt_data_E, ext_result, data, ALUSrc_E);

    alu alu(rs_data_E, data, zero, result, ALUctr_E, shamt_E);

    //-------------------------------------------------
    EX_MEM Ex_Mem(clk, ext_result, Rd_E, PC_E, RegWr_E, NPCop_E, MemWr_E, zero, rt_data_E, MemtoReg_E, result, RegDst_E, Rt_E, target_E, 
                       ext_result_M, Rd_M, PC_M, RegWr_M, NPCop_M, MemWr_M, zero_M, rt_data_M, MemtoReg_M, result_M, RegDst_M, Rt_M, target_M); // 第三个流水寄存器

    //----------------访存阶段--------------------------
    dm_4k dm(result_M, rt_data_M, MemWr_M, clk, dout);  //这里的result是地址

    mux2 regMux(result_M, dout, wd, MemtoReg_M);

    //-------------------------------------------------
    MEM_WB Mem_Wb(clk, ext_result_M, Rd_M, PC_M, RegWr_M, NPCop_M, zero_M, wd, RegDst_M, Rt_M, target_M, 
                       ext_result_W, Rd_W, PC_W, RegWr_W, NPCop_W, zero_W, wd_W, RegDst_W, Rt_W, target_W); // 第四个流水寄存器

    //----------------写回阶段--------------------------
    regfile regfile(Rs, Rt, Rt_W, Rd_W, rs_data, rt_data, wd_W, RegWr_W, RegDst_W, clk); 

    npc npc(PC_W, NPC, NPCop_W, target_W, ext_result_W, PC_plus_4, zero_W);
endmodule