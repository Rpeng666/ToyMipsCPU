module IF_ID(clk, instruction_F, PC, 
                  instruction_D, PC_D, IF_ID_wr);
    input clk, IF_ID_wr;
    input [31: 0] instruction_F, PC;

    output reg [31: 0] instruction_D, PC_D;

    always @(posedge clk ) begin
        if(IF_ID_wr) begin  //满足IF_ID的写使能信号才能写入
            instruction_D <= instruction_F;
            PC_D <= PC;
        end
    end
endmodule