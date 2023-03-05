module ID_EX(clk, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, ALUctr, NPCop, Rs, Rt, Rd, shamt, imm16, target, PC_D, rs_data, rt_data, if_branch, 
                  RegDst_E, ALUSrc_E, MemtoReg_E, RegWr_E, MemWr_E, ExtOp_E, ALUctr_E, NPCop_E, Rs_E, Rt_E, Rd_E, shamt_E, imm16_E, target_E, PC_E, rs_data_E, rt_data_E, if_branch_E);
    input clk;
    input RegDst, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, if_branch;
    input[3:0] ALUctr, NPCop;
    input [4: 0] Rs, Rt, Rd;
    input [4: 0] shamt;
    input [15: 0] imm16;
    input [25: 0] target;
    input [31: 0] PC_D, rs_data, rt_data;

    output reg RegDst_E, ALUSrc_E, MemtoReg_E, RegWr_E, MemWr_E, ExtOp_E, if_branch_E;
    output reg[3: 0] ALUctr_E, NPCop_E;
    output reg[4: 0] Rs_E, Rt_E, Rd_E;
    output reg[4: 0] shamt_E;
    output reg[15: 0] imm16_E;
    output reg[25: 0] target_E;
    output reg[31: 0] PC_E, rs_data_E, rt_data_E;

    always @(posedge clk ) begin
        RegDst_E <= RegDst;
        ALUSrc_E <= ALUSrc;
        MemtoReg_E <= MemtoReg;
        RegWr_E <= RegWr;
        MemWr_E <= MemWr;
        ExtOp_E <= ExtOp;
        ALUctr_E <= ALUctr;
        NPCop_E <= NPCop;
        Rs_E <= Rs;
        Rt_E <= Rt;
        Rd_E <= Rd;
        shamt_E <= shamt;
        imm16_E <= imm16;
        target_E <= target;
        PC_E <= PC_D;
        rs_data_E <= rs_data;
        rt_data_E <= rt_data;
        if_branch_E <= if_branch;
    end

endmodule