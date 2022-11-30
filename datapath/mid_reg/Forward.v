module Forward(Rs_E, Rt_E, RegWrDst_W, RegWr_W, RegWrDst_M, RegWr_M, 
                Forward_RSE, Forward_RTE);  // 转发模块
    input[4: 0] Rs_E, Rt_E; // Ex阶段要处理的数据的来源地址Rs, Rt
    input[4: 0] RegWrDst_W; // 写回阶段时候要写入的地址
    input[4: 0] RegWrDst_M; // Ex_Mem阶段的地址，将来会变成RegWrDst_W
    input RegWr_W;    //写回阶段的写使能信号
    input RegWr_M;    // Ex_Mem阶段的写使能信号，将来会变成RegWr_W

    output reg[1: 0] Forward_RSE; //10:转发Ex的输出， 01：转发Wb的输出，00：保持原样
    output reg[1: 0] Forward_RTE; //10:转发Ex的输出， 01：转发Wb的输出，00：保持原样

    reg C_R_EW_Rs, C_R_EW_Rt; //C:检测条件，R：R型指令造成的数据冒险，EW: Ex到Wb
    reg C_R_EM_Rs, C_R_EM_Rt; //C:检测条件，R：R型指令造成的数据冒险，EM: Ex到Mem

  always @(*) begin
    C_R_EW_Rs = (Rs_E != 0) & (Rs_E == RegWrDst_W) & RegWr_W;   // 判断Wb阶段的要写入的值会不会和Ex阶段要读入Rs的值发生冒险
    C_R_EW_Rt = (Rt_E != 0) & (Rt_E == RegWrDst_W) & RegWr_W;

    C_R_EM_Rs = (Rs_E != 0) & (Rs_E == RegWrDst_M) & RegWr_M;  // 判断Ex阶段的要写入的值会不会和Ex阶段要读入Rs的值发生冒险
    C_R_EM_Rt = (Rt_E != 0) & (Rt_E == RegWrDst_M) & RegWr_M;

    Forward_RSE = C_R_EM_Rs ? 2'b10 : (C_R_EW_Rs ? 2'b01 : 2'b00);
    Forward_RTE = C_R_EM_Rt ? 2'b10 : (C_R_EW_Rt ? 2'b01 : 2'b00);
  end

endmodule