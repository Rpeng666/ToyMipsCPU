module LoadHazard(rs_D, rt_D, DstE, MemtoReg_E,
                C_L_DE_Rs, C_L_DE_Rt); // 专门用来解决是否发生load指令的数据冒险
    input [4: 0] rs_D; // IF_ID阶段的rs地址
    input [4: 0] rt_D; // IF_ID阶段的rt地址
    input [4: 0] DstE; // ID_EX阶段的写入寄存器的地址（可能和上面的rs / rt 发生数据冒险）, 其实就是lw指令的rt段
    input  MemtoReg_E; // 决定是否写入regfile

    output reg C_L_DE_Rs, C_L_DE_Rt;  // 相应的PC / IF_ID / ID_EX的处理策略

  always @(*) begin
    C_L_DE_Rs <= (rs_D == DstE) & MemtoReg_E;  // IF_EX阶段的Rs和ID_EX阶段（load指令）的Rt地址是否会发生数据冒险
    C_L_DE_Rt <= (rt_D == DstE) & MemtoReg_E;  // IF_EX阶段的Rt和ID_EX阶段（load指令）的Rt地址是否会发生数据冒险

  end
endmodule


module BranchHazard(if_branch, rs_D, rt_D, RegWrDst_M, RegWr_M, RegWr_E, RegWrDst_E, MemtoReg_E, MemtoReg_M,
                      C_B_DM_Rs, C_B_DM_Rt, C_B_D);  //beq的控制冒险
    input [4: 0] rs_D, rt_D;  //beq译码时候用的rs， rt
    input[4: 0] RegWrDst_M, RegWrDst_E;   //Ex_Mem阶段中将来要写入RegFile的地址
    input if_branch, RegWr_M, RegWr_E, MemtoReg_E, MemtoReg_M;

    output reg C_B_DM_Rs, C_B_DM_Rt, C_B_D;
    
    parameter JUMP = 4'b0000;
    parameter BEQ  = 4'b0010;

  always @(*) begin
    C_B_DM_Rs = (rs_D == RegWrDst_M) & RegWr_M;  // beq指令在译码的时候，后面Mem阶段是否和它的rs有数据冒险
    C_B_DM_Rt = (rt_D == RegWrDst_M) & RegWr_M;  // beq指令在译码的时候，后面Mem阶段是否和它的rt有数据冒险

    C_B_D = (if_branch & RegWr_E & (rs_D == RegWrDst_E | rt_D == RegWrDst_E)) |  
            (if_branch & MemtoReg_E & (rs_D == RegWrDst_E | rt_D == RegWrDst_E)) | // 判断有无lw-beq和lw-xxxx-beq之类的指令
            (if_branch & MemtoReg_M & (rs_D == RegWrDst_M | rt_D == RegWrDst_M));
    
  end
endmodule

 module ComputeBranch(ForwardRs_D, ForwardRt_D, rs_data, rt_data, result_M, zero_D);  
    input ForwardRs_D, ForwardRt_D;
    input [31: 0] rs_data, rt_data, result_M;

    output reg zero_D;

    reg[31: 0] A, B;

  always @(*) begin
      if(ForwardRs_D) A = result_M;
      else A = rs_data;

      if(ForwardRt_D) B = result_M;
      else B = rt_data;

      zero_D = (A == B);
  end

 endmodule