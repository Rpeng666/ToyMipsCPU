module IF_ID(clk, instruction_F, PC, 
                  instruction_D, PC_D, IF_ID_wr, IF_ID_flush);
    input clk, IF_ID_wr, IF_ID_flush;
    input [31: 0] instruction_F, PC;

    output reg [31: 0] PC_D;
    output reg [31: 0] instruction_D;

    always @(posedge clk ) begin
        if(IF_ID_flush) begin
            instruction_D <= 32'bx;
            // PC_D <= 32'bx;
        end
        else if(IF_ID_wr) begin  //满足IF_ID的写使能信号才能写入
            instruction_D <= instruction_F;
            PC_D <= PC;
        end
    end
endmodule