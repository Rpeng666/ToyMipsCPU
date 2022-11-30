module EX_MEM(clk, ext_result, PC_E, RegWr_E, NPCop_E, MemWr_E, zero, rt_data, MemtoReg_E, result, target_E, RegWrDst_E, 
                   ext_result_M, PC_M, RegWr_M, NPCop_M, MemWr_M, zero_M, rt_data_M, MemtoReg_M, result_M, target_M, RegWrDst_M);
    
    input clk, RegWr_E, MemWr_E, zero, MemtoReg_E;
    input [3: 0] NPCop_E;
    input [4: 0] RegWrDst_E;
    input [25: 0] target_E;
    input [31: 0] ext_result, PC_E, rt_data, result;

    output reg RegWr_M, MemWr_M, zero_M, MemtoReg_M;
    output reg[3: 0] NPCop_M;
    output reg[4: 0] RegWrDst_M;
    output reg [25: 0] target_M;
    output reg[31: 0] ext_result_M, PC_M, rt_data_M, result_M;

    always @(posedge clk ) begin
        ext_result_M <= ext_result;
        RegWrDst_M <= RegWrDst_E;
        PC_M <= PC_E;
        RegWr_M <= RegWr_E;
        NPCop_M <= NPCop_E;
        MemWr_M <= MemWr_E;
        zero_M <= zero;
        rt_data_M <= rt_data;
        MemtoReg_M <= MemtoReg_E;
        result_M <= result;
        target_M <= target_E;
    end
endmodule