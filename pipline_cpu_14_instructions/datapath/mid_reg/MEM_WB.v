module MEM_WB(clk, ext_result_M, PC_M, RegWr_M, NPCop_M, zero_M, target_M, MemtoReg_M, result_M, dout, RegWrDst_M, wd_M, if_overflow_M, 
                   ext_result_W, PC_W, RegWr_W, NPCop_W, zero_W, target_W, MemtoReg_W, result_W, dout_W, RegWrDst_W, wd, if_overflow_W);
    
    input clk, RegWr_M, zero_M, MemtoReg_M, if_overflow_M;
    input [3: 0] NPCop_M;
    input [4: 0] RegWrDst_M;
    input [25: 0] target_M;
    input [31: 0] ext_result_M, PC_M, result_M, dout, wd_M;

    output reg RegWr_W, zero_W, MemtoReg_W, if_overflow_W;
    output reg[3: 0] NPCop_W;
    output reg[4: 0] RegWrDst_W;
    output reg[25: 0] target_W;
    output reg[31: 0] ext_result_W, PC_W, result_W, dout_W, wd;

    always @(posedge clk ) begin
        ext_result_W <= ext_result_M;
        RegWrDst_W <= RegWrDst_M;
        PC_W <= PC_M;
        RegWr_W <= RegWr_M;
        NPCop_W <= NPCop_M;
        zero_W <= zero_M;
        target_W <= target_M;
        MemtoReg_W <= MemtoReg_M;
        result_W <= result_M;
        dout_W <= dout;
        wd <= wd_M;
        if_overflow_W <= if_overflow_M;
    end
endmodule