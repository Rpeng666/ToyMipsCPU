module EX_MEM(clk, ext_result, Rd_E, PC_E, RegWr_E, NPCop_E, MemWr_E, zero, rt_data, MemtoReg_E, result, RegDst_E, Rt_E, target_E, 
                   ext_result_M, Rd_M, PC_M, RegWr_M, NPCop_M, MemWr_M, zero_M, rt_data_M, MemtoReg_M, result_M, RegDst_M, Rt_M, target_M);
    
    input clk, RegWr_E, MemWr_E, zero, MemtoReg_E, RegDst_E;
    input [3: 0] NPCop_E;
    input [4: 0] Rd_E, Rt_E;
    input [25: 0] target_E;
    input [31: 0] ext_result, PC_E, rt_data, result;

    output reg RegWr_M, MemWr_M, zero_M, MemtoReg_M, RegDst_M;
    output reg[3: 0] NPCop_M;
    output reg[4: 0] Rd_M, Rt_M;
    output reg [25: 0] target_M;
    output reg[31: 0] ext_result_M, PC_M, rt_data_M, result_M;

    always @(posedge clk ) begin
        ext_result_M <= ext_result;
        Rd_M <= Rd_E;
        PC_M <= PC_E;
        RegWr_M <= RegWr_E;
        NPCop_M <= NPCop_E;
        MemWr_M <= MemWr_E;
        zero_M <= zero;
        rt_data_M <= rt_data;
        MemtoReg_M <= MemtoReg_E;
        result_M <= result;
        RegDst_M <= RegDst_E;
        Rt_M <= Rt_E;
        target_M <= target_E;
    end
endmodule