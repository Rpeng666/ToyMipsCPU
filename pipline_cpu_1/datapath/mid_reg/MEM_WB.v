module MEM_WB(clk, ext_result_M, Rd_M, PC_M, RegWr_M, NPCop_M, zero_M, RegDst_M, Rt_M, target_M, MemtoReg_M, result_M, dout, 
                   ext_result_W, Rd_W, PC_W, RegWr_W, NPCop_W, zero_W, RegDst_W, Rt_W, target_W, MemtoReg_W, result_W, dout_W);
    
    input clk, RegWr_M, zero_M, RegDst_M, MemtoReg_M;
    input [3: 0] NPCop_M;
    input [4: 0] Rd_M, Rt_M;
    input [25: 0] target_M;
    input [31: 0] ext_result_M, PC_M, result_M, dout;

    output reg RegWr_W, zero_W, RegDst_W, MemtoReg_W;
    output reg[3: 0] NPCop_W;
    output reg[4: 0] Rd_W, Rt_W;
    output reg[25: 0] target_W;
    output reg[31: 0] ext_result_W, PC_W, result_W, dout_W;

    always @(posedge clk ) begin
        ext_result_W <= ext_result_M;
        Rd_W <= Rd_M;
        PC_W <= PC_M;
        RegWr_W <= RegWr_M;
        NPCop_W <= NPCop_M;
        zero_W <= zero_M;
        RegDst_W <= RegDst_M;
        Rt_W <= Rt_M;
        target_W <= target_M;
        MemtoReg_W <= MemtoReg_M;
        result_W <= result_M;
        dout_W <= dout;
    end
endmodule