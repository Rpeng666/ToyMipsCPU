module Hazard(rs_D, rt_D, DstE, MemtoReg_E,
                PCEnF, IF_ID_wr, ID_Ex_flush); // 专门用来是否发生load指令的数据冒险
    input [4: 0] rs_D; // IF_ID阶段的rs地址
    input [4: 0] rt_D; // IF_ID阶段的rt地址
    input [4: 0] DstE; // ID_EX阶段的写入寄存器的地址（可能和上面的rs / rt 发生数据冒险）, 其实就是lw指令的rt段
    input  MemtoReg_E; // 决定是否写入regfile

    output reg PCEnF = 1'b1, IF_ID_wr = 1'b1, ID_Ex_flush = 1'b0;  // 相应的PC/IF_ID/ID_EX的处理策略

    reg C_L_DE_Rs, C_L_DE_Rt;

  always @(*) begin
    C_L_DE_Rs = (rs_D == DstE) & MemtoReg_E;  // IF_EX阶段的Rs和ID_EX阶段（load指令）的Rt地址是否会发生数据冒险
    C_L_DE_Rt = (rt_D == DstE) & MemtoReg_E;  // IF_EX阶段的Rt和ID_EX阶段（load指令）的Rt地址是否会发生数据冒险

    PCEnF = !(C_L_DE_Rs | C_L_DE_Rt);  // 判断load指令的数据冒险后PC模块是否要暂停写入
    IF_ID_wr = !(C_L_DE_Rs | C_L_DE_Rt);  // 判断load指令的数据冒险后IF_ID寄存器是否要暂停写入
    ID_Ex_flush = C_L_DE_Rs | C_L_DE_Rt; // 判断load指令的数据冒险后ID_EX是否要刷新清空
  end
endmodule