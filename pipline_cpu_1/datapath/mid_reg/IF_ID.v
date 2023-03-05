module IF_ID(clk, instruction_F, PC, 
                  instruction_D, PC_D);
    input clk;
    input [31: 0] instruction_F, PC;

    output reg [31: 0] instruction_D, PC_D;

    always @(posedge clk ) begin
        instruction_D <= instruction_F;
        PC_D <= PC;
    end
endmodule