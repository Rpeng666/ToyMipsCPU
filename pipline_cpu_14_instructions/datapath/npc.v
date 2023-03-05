module npc(PC, NPC, NPCop, target, ext_result, PC_plus_4, zero_D);
    input [31:0] PC;
    input [25: 0] target;
    input [31 :0] ext_result, PC_plus_4;
    input [3: 0] NPCop;
    input zero_D;

    output reg[31: 0] NPC = 32'h3000;


    // 所有的跳转信号，虽然写的时候只支持两种Jump和Branch
    parameter JUMP = 4'b0000;
    parameter JAL  = 4'b0001;
    parameter BEQ  = 4'b0010;
    parameter BNE  = 4'b0011;
    parameter BGEZ = 4'b0100;
    parameter BGTZ = 4'b0101;
    parameter BLEZ = 4'b0110;
    parameter BLTZ = 4'b0111;
    parameter JR   = 4'b1000;
    parameter JALR = 4'b1000;
    parameter ADD4 = 4'b1111;  // 正常的 pc + 4 的情况

  always @(*) begin
    NPC = PC_plus_4;

    if(NPCop == JUMP) begin
      NPC = {PC[31: 28], target << 2};
    end
    else if(NPCop == BEQ) begin
      NPC = (zero_D == 1) ? (PC + 4 + ext_result) : PC_plus_4;
    end
    // $display("(NPC.v) zero = %h npc = %h", zero, NPC);
  end

endmodule   