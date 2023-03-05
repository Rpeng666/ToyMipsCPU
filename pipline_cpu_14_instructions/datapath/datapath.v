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
`include "./datapath/Forward.v"


module datapath(clk, rst, op, func, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, NPCop, ExtOp, ALUctr, if_branch, PC_D, if_undefined);
    // op,         // 指令的op段
    // func,       // 指令的func段
    // RegWr,      //寄存器能否写入的信号
    // ALUSrc,     // ALU是否有输入来自立即数
    // RegDst,     // 控制寄存器写入地址
    // MemtoReg,   // 数据存储器能否写入寄存器
    // MemWr,      // 数据存储器能否被写入
    // Branch,     // 是否是分支指令
    // Jump,       // 是否是无条件跳转指令
    // ExtOp,      // 是否符号扩展
    // ALUctr      // 控制ALU功能
    input clk, rst, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, if_branch, if_undefined;
    input[3:0] ALUctr, NPCop;

    output [5:0] op, func;
    output [31: 0] PC_D;

    wire [31: 0] instruction_F, instruction_D;
    wire [31:0] PC, NPC, PC_plus_4, PC_W, PC_D, PC_E, PC_M, PC_F;

    assign op = instruction_D[31: 26];
    assign func = instruction_D[5: 0];

    wire[4: 0] Rs = instruction_D[25: 21];
    wire[4: 0] Rt = instruction_D[20: 16];
    wire[4: 0] Rd = instruction_D[15: 11];
    wire[4: 0] RegWrDst, RegWrDst_E, RegWrDst_M, RegWrDst_W; //寄存器的写入地址
    assign RegWrDst = (RegDst == 1)? Rt : Rd;
    wire[31: 0] rs_data, rt_data, rt_data_M, rs_data_E, rt_data_E, rs_data_final, rt_data_final;

    wire zero_D, zero, zero_M, zero_W;
    wire [4: 0] shamt = instruction_D[10: 6];
    wire [31: 0] data, ext_result_D, ext_result, ext_result_M, ext_result_W, result, result_M, result_W;
    wire [15: 0] imm16 = instruction_D[15: 0];

    wire [31: 0] dout, dout_W, wd, wd_W, wd_M;
    wire [25: 0] target = instruction_D[25: 0];

    wire ALUSrc_E, MemtoReg_E, MemtoReg_M, MemtoReg_W, RegWr_E, MemWr_E, MemWr_M, ExtOp_E, RegWr_M, RegWr_W, if_branch_E;
    wire [3: 0] ALUctr_E, NPCop_E, NPCop_M, NPCop_W;
    wire [4: 0] Rs_E, Rt_E, Rt_M, Rt_W, Rd_E, shamt_E, Rd_M, Rd_W;
    wire [15: 0] imm16_E;
    wire [25: 0] target_E, target_M, target_W;
    wire C_L_DE_Rs, C_L_DE_Rt; // 专门检测load指令的数据冒险
    wire PCEnF, IF_ID_wr; //PC模块的写使能信号, IF_ID的写使能信号
    wire ID_Ex_flush, ID_Ex_flush_lw, ID_Ex_flush_npc; // ID_Ex寄存器的清空信号
    wire IF_ID_flush; // IF_ID寄存器的清空信号

    wire[1: 0] Forward_Rs_E, Forward_Rt_E;
    wire ForwardRs_D, ForwardRt_D;
    wire C_R_EM_Rs, C_R_EM_Rt; //C:检测条件，R：R型指令造成的数据冒险，EM: Ex到Mem
    wire C_R_EW_Rs, C_R_EW_Rt; //C:检测条件，R：R型指令造成的数据冒险，EW: Ex到Wb
    wire C_B_DM_Rs, C_B_DM_Rt, C_B_D;

    wire if_overflow_E, if_overflow_M, if_overflow_W;

    
    //----------------取指阶段--------------------------
    
    mux7 mux7(C_L_DE_Rs, C_L_DE_Rt, C_B_D, PCEnF);  // 控制PC模块能否写入

    pc pc(NPC, PC, rst, PCEnF, PC_plus_4, clk);

    im_4k im(PC, instruction_F, PC_F); // 其实PC_F是完全没有必要的，但是PC变得太快，导致IF_ID输入的PC是错误的，这里无奈中转一下
                                       
    //-------------------------------------------------
    mux5 mux5(C_L_DE_Rs, C_L_DE_Rt, C_B_D, IF_ID_wr);  // 决定IF_ID能否写入

    mux6 mux6(if_branch, zero_D, IF_ID_flush);  // 决定IF_ID是否要flush

    IF_ID If_Id(clk, instruction_F, PC_F, 
                     instruction_D, PC_D, IF_ID_wr, IF_ID_flush); // 第一个流水寄存器
    //----------------译码阶段--------------------------

    ext SignExt(imm16, ext_result_D, ExtOp, if_branch);
    
    BranchHazard branch_hazard(if_branch, Rs, Rt, RegWrDst_M, RegWr_M, RegWr_E, RegWrDst_E, MemtoReg_E, MemtoReg_M,
                                        C_B_DM_Rs, C_B_DM_Rt, C_B_D); // beq指令的控制冒险

    assign ForwardRs_D = C_B_DM_Rs;  // 决定beq的Rs是否要转发
    assign ForwardRt_D = C_B_DM_Rt;  // 决定beq的Rt是否要转发

    ComputeBranch compute_branch(ForwardRs_D, ForwardRt_D, rs_data, rt_data, result_M, zero_D); //这里算是branch指令前移计算

    //-------------------------------------------------

    ID_EX Id_Ex(clk, ext_result_D, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, ALUctr, NPCop, Rs, Rt, shamt, imm16, target, PC_D, rs_data, rt_data, if_branch, RegWrDst, if_undefined,
                     ext_result, ALUSrc_E, MemtoReg_E, RegWr_E, MemWr_E, ExtOp_E, ALUctr_E, NPCop_E, Rs_E, Rt_E, shamt_E, imm16_E, target_E, PC_E, rs_data_E, rt_data_E, if_branch_E, RegWrDst_E, ID_Ex_flush); // 第二个流水寄存器
    
    //----------------执行阶段--------------------------
    LoadHazard load_hazard(Rs, Rt, RegWrDst_E, MemtoReg_E,    // 检测load指令的数据冒险
                     C_L_DE_Rs, C_L_DE_Rt);

    Forward forward(Rs_E, Rt_E, RegWrDst_W, RegWr_W, RegWrDst_M, RegWr_M, 
                        Forward_Rs_E, Forward_Rt_E);  // 转发模块，实际上牵扯到了Wb和Mem两个阶段都需要转发，随便放在这里吧
    
    mux3 mux3(Forward_Rs_E, result_M, wd, rs_data_E, rs_data_final);   // Rs的转发, rs_data_final就是判断转发完后最终值
    mux4 mux4(Forward_Rt_E, result_M, wd, rt_data_E, rt_data_final);   // Rt的转发，rt_data_final就是判断转发完后的最终值

    mux1 aluMux(rt_data_final, ext_result, data, ALUSrc_E);

    alu alu(rs_data_final, data, zero, result, ALUctr_E, shamt_E, PC_E, if_overflow_E);

    //-------------------------------------------------
    EX_MEM Ex_Mem(clk, ext_result, PC_E, RegWr_E, NPCop_E, MemWr_E, zero, rt_data_E, MemtoReg_E, result, target_E, RegWrDst_E, if_overflow_E, 
                       ext_result_M, PC_M, RegWr_M, NPCop_M, MemWr_M, zero_M, rt_data_M, MemtoReg_M, result_M, target_M, RegWrDst_M, if_overflow_M); // 第三个流水寄存器


    //----------------访存阶段--------------------------
    dm_4k dm(result_M, rt_data_M, MemWr_M, clk, dout, if_overflow_M);  //这里的result是地址,dout是从dm中读出的数据，后面将会写入regfile 

    mux2 regMux(result_M, dout, wd_M, MemtoReg_M);

    //-------------------------------------------------
    MEM_WB Mem_Wb(clk, ext_result_M, PC_M, RegWr_M, NPCop_M, zero_M, target_M, MemtoReg_M, result_M, dout, RegWrDst_M, wd_M, if_overflow_M, 
                       ext_result_W, PC_W, RegWr_W, NPCop_W, zero_W, target_W, MemtoReg_W, result_W, dout_W, RegWrDst_W, wd, if_overflow_W); // 第四个流水寄存器

    //----------------写回阶段--------------------------   
    
    regfile regfile(Rs, Rt, RegWrDst_W, rs_data, rt_data, wd, RegWr_W, if_overflow_W, clk);

    npc npc(PC_D, NPC, NPCop, target, ext_result_D, PC_plus_4, zero_D);  // 等到写回阶段再传给NPC
endmodule