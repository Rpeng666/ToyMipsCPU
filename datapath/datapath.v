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
`include "./datapath/hazard.v"


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
    wire[4: 0] RegWrDst, RegWrDst_E, RegWrDst_M, RegWrDst_W; //寄存器的写入地址
    assign RegWrDst = (RegDst == 1)? Rt : Rd;
    wire[31: 0] rs_data, rt_data, rt_data_M, rs_data_E, rt_data_E, rs_data_final, rt_data_final;

    wire zero, zero_M, zero_W;
    wire [4: 0] shamt = instruction_D[10: 6];
    wire [31: 0] data, ext_result, ext_result_M, ext_result_W, result, result_M, result_W;
    wire [15: 0] imm16 = instruction_D[15: 0];

    wire [31: 0] dout, dout_W, wd, wd_W;
    wire [25: 0] target = instruction_D[25: 0];

    wire ALUSrc_E, MemtoReg_E, MemtoReg_M, MemtoReg_W, RegWr_E, MemWr_E, MemWr_M, ExtOp_E, RegWr_M, RegWr_W, if_branch_E;
    wire [3: 0] ALUctr_E, NPCop_E, NPCop_M, NPCop_W;
    wire [4: 0] Rs_E, Rt_E, Rt_M, Rt_W, Rd_E, shamt_E, Rd_M, Rd_W;
    wire [15: 0] imm16_E;
    wire [25: 0] target_E, target_M, target_W;
    wire C_L_DE_Rs = 1'b0, C_L_DE_Rt = 1'b0; // 专门检测load指令的数据冒险
    wire PCEnF = 1'b1, IF_ID_wr = 1'b1; //PC模块的写使能信号, IF_ID的写使能信号
    wire ID_Ex_flush = 1'b0; // ID_Ex寄存器的清空信号

    
    //----------------取指阶段--------------------------
    pc pc(NPC, PC, rst, PCEnF, clk);

    assign PC_plus_4 = PC + 4;

    im_4k im(PC, instruction_F);

    //-------------------------------------------------
    IF_ID If_Id(clk, instruction_F, PC, 
                     instruction_D, PC_D, IF_ID_wr); // 第一个流水寄存器
    //----------------译码阶段--------------------------
    Hazard hazard(Rs, Rt, RegWrDst_E, MemtoReg_E,  // 检测load指令的数据冒险
                    PCEnF, IF_ID_wr, ID_Ex_flush);

    //-------------------------------------------------
    ID_EX Id_Ex(clk, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, ALUctr, NPCop, Rs, Rt, shamt, imm16, target, PC_D, rs_data, rt_data, if_branch, RegWrDst,
                     ALUSrc_E, MemtoReg_E, RegWr_E, MemWr_E, ExtOp_E, ALUctr_E, NPCop_E, Rs_E, Rt_E, shamt_E, imm16_E, target_E, PC_E, rs_data_E, rt_data_E, if_branch_E, RegWrDst_E, ID_Ex_flush); // 第二个流水寄存器
    
    //----------------执行阶段--------------------------

    ext SignExt(imm16_E, ext_result, ExtOp_E, if_branch_E);

    wire[1: 0] Forward_RSE;
    assign Forward_RSE = C_R_EM_Rs ? 2'b10 : (C_R_EW_Rs ? 2'b01 : 2'b00); //10:转发Ex的输出， 01：转发Wb的输出，00：保持原样

    wire[1: 0] Forward_RTE;
    assign Forward_RTE = C_R_EM_Rt ? 2'b10 : (C_R_EW_Rt ? 2'b01 : 2'b00); //10:转发Ex的输出， 01：转发Wb的输出，00：保持原样

    mux3 mux3(Forward_RSE, result_M , wd, rs_data_E, rs_data_final);   // Rs的转发, rs_data_final就是判断转发完后最终值
    mux4 mux4(Forward_RTE, result_M, wd, rt_data_E, rt_data_final);   //Rt的转发，rt_data_final就是判断转发完后的最终值

    mux1 aluMux(rt_data_final, ext_result, data, ALUSrc_E);  

    alu alu(rs_data_final, data, zero, result, ALUctr_E, shamt_E);

    //-------------------------------------------------
    EX_MEM Ex_Mem(clk, ext_result, PC_E, RegWr_E, NPCop_E, MemWr_E, zero, rt_data_E, MemtoReg_E, result, target_E, RegWrDst_E, 
                       ext_result_M, PC_M, RegWr_M, NPCop_M, MemWr_M, zero_M, rt_data_M, MemtoReg_M, result_M, target_M, RegWrDst_M); // 第三个流水寄存器

    //----------------访存阶段--------------------------
    wire C_R_EM_Rs, C_R_EM_Rt; //C:检测条件，R：R型指令造成的数据冒险，EM: Ex到Mem
    assign C_R_EM_Rs = (Rs_E != 0) & (Rs_E == RegWrDst_M) & RegWr_M;  // 判断Ex阶段的要写入的值会不会和Ex阶段要读入Rs的值发生冒险
    assign C_R_EM_Rt = (Rt_E != 0) & (Rt_E == RegWrDst_M) & RegWr_M;
    

    dm_4k dm(result_M, rt_data_M, MemWr_M, clk, dout);  //这里的result是地址

    //-------------------------------------------------
    MEM_WB Mem_Wb(clk, ext_result_M, PC_M, RegWr_M, NPCop_M, zero_M, target_M, MemtoReg_M, result_M, dout, RegWrDst_M,
                       ext_result_W, PC_W, RegWr_W, NPCop_W, zero_W, target_W, MemtoReg_W, result_W, dout_W, RegWrDst_W); // 第四个流水寄存器

    //----------------写回阶段--------------------------
    wire C_R_EW_Rs, C_R_EW_Rt; //C:检测条件，R：R型指令造成的数据冒险，EW: Ex到Wb
    assign C_R_EW_Rs = (Rs_E != 0) & (Rs_E == RegWrDst_W) & RegWr_W;   // 判断Wb阶段的要写入的值会不会和Ex阶段要读入Rs的值发生冒险
    assign C_R_EW_Rt = (Rt_E != 0) & (Rt_E == RegWrDst_W) & RegWr_W;


    mux2 regMux(result_W, dout_W, wd, MemtoReg_W);

    regfile regfile(Rs, Rt, RegWrDst_W, rs_data, rt_data, wd, RegWr_W, clk);

    npc npc(PC_W, NPC, NPCop_W, target_W, ext_result_W, PC_plus_4, zero_M);  // 这个地方和多拉贡的不同，他是在访存阶段就把信号传近来了，我这是等到了写回阶段再传给NPC
endmodule