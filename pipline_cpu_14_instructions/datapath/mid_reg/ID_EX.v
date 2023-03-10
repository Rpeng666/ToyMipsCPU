module ID_EX(clk, ext_result_D, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, ALUctr, NPCop, Rs, Rt, shamt, imm16, target, PC_D, rs_data, rt_data, if_branch, RegWrDst, if_undefined,
                  ext_result, ALUSrc_E, MemtoReg_E, RegWr_E, MemWr_E, ExtOp_E, ALUctr_E, NPCop_E, Rs_E, Rt_E, shamt_E, imm16_E, target_E, PC_E, rs_data_E, rt_data_E, if_branch_E, RegWrDst_E, ID_Ex_flush);
    input clk, if_undefined;
    input ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, if_branch, ID_Ex_flush;
    input[3:0] ALUctr, NPCop;
    input [4: 0] Rs, Rt, RegWrDst;
    input [4: 0] shamt;
    input [15: 0] imm16;
    input [25: 0] target;
    input [31: 0] PC_D, rs_data, rt_data, ext_result_D;

    output reg ALUSrc_E, MemtoReg_E = 1'b0, RegWr_E, MemWr_E, ExtOp_E, if_branch_E;
    output reg[3: 0] ALUctr_E, NPCop_E;
    output reg[4: 0] Rs_E, Rt_E, RegWrDst_E;
    output reg[4: 0] shamt_E;
    output reg[15: 0] imm16_E;
    output reg[25: 0] target_E;
    output reg[31: 0] PC_E, rs_data_E, rt_data_E, ext_result;

    always @(posedge clk ) begin
        if(if_undefined)begin
            ALUSrc_E <= 1'bx;
            MemtoReg_E <= 1'bx;
            RegWr_E <= 1'bx;
            MemWr_E <= 1'bx;
            ExtOp_E <= 1'bx;
            NPCop_E <= 4'bx;
            Rs_E <= 5'bx;
            Rt_E <= 5'bx;
            RegWrDst_E <= 5'bx;
            shamt_E <= 5'bx;
            imm16_E <= 16'bx;
            target_E <= 26'bx;
            rs_data_E <= 32'bx;
            rt_data_E <= 32'bx;
            if_branch_E <= 1'bx;
            ext_result <= 32'bx;
            ALUctr_E <= 4'bx;
            PC_E <= PC_D;
        end
        else if(ID_Ex_flush) begin  // 清空ID_EX寄存器
            ALUSrc_E <= 1'b0;
            MemtoReg_E <= 1'b0;
            RegWr_E <= 1'b0;
            MemWr_E <= 1'b0;
            ExtOp_E <= 1'b0;
            NPCop_E <= 4'b0;
            Rs_E <= 5'b0;
            Rt_E <= 5'b0;
            RegWrDst_E <= 5'b0;
            shamt_E <= 5'b0;
            imm16_E <= 16'b0;
            target_E <= 26'b0;
            rs_data_E <= 32'b0;
            rt_data_E <= 32'b0;
            if_branch_E <= 1'b0;
            ext_result <= 32'b0;
            ALUctr_E <= 4'b0;
            PC_E <= 32'b0;
        end
        else begin      
            ALUSrc_E <= ALUSrc;
            MemtoReg_E <= MemtoReg;
            RegWr_E <= RegWr;
            MemWr_E <= MemWr;
            ExtOp_E <= ExtOp;        
            NPCop_E <= NPCop;
            Rs_E <= Rs;
            Rt_E <= Rt;
            RegWrDst_E <= RegWrDst;
            shamt_E <= shamt;
            imm16_E <= imm16;
            target_E <= target;
            rs_data_E <= rs_data;
            rt_data_E <= rt_data;
            if_branch_E <= if_branch;
            ext_result <= ext_result_D;
            ALUctr_E <= ALUctr;
            PC_E <= PC_D;
        end
    end

endmodule