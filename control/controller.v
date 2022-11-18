module controller(op, func, RegDst, ALUSrc, MemtoReg, RegWr, MemWr, NPCop, ExtOp, ALUctr, if_branch);
    // op,  // 指令的op段
    // func,  // 指令的func段
    // RegDst,    // 寄存器写入地址
    // ALUSrc,   // ALU是否接受立即数
    // MemtoReg,  // 数据存储器能否写入寄存器
    // RegWr,   //寄存器能否写入的信号
    // MemWr,   // 数据存储器能否被写入
    // NPCop, // 判断跳转类型是Jump，Beq还是其他
    // ExtOp,    // 是否符号扩展
    // ALUctr    // 控制ALU功能

    input [5:0]	op, func;
	
	output reg RegDst, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp, if_branch; // if_branch 是专门为branch指令适配的符号扩展信号，主要目的是左移两位
	output reg[3:0]	ALUctr, NPCop;

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

    // 支持的所有ALU运算
    parameter AND   = 4'b0000;
    parameter OR    = 4'b0001;
    parameter ADD   = 4'b0010;
    parameter XOR   = 4'b0011;
    parameter ORI   = 4'b0100;
    parameter ADDIU = 4'b0101;
    parameter SUB   = 4'b0110;
    parameter ADDI  = 4'b0111;
    parameter SLL   = 4'b1000;
    parameter SLT   = 4'b1001;   
    parameter LUI   = 4'b1111;  // 实在没办法处理这个，特殊处理吧

    always @(*) begin
        case(op)
            6'b000000: //  R型指令 
                begin
                    RegDst   = 1'b0;
                    ALUSrc   = 1'b0;
                    MemtoReg = 1'b0; 
                    RegWr    = 1'b1; // 可以写到寄存器
                    MemWr    = 1'b0; // 不需要写存储器
                    NPCop    = ADD4;
                    if_branch = 1'b0;
                    case(func)
                            6'b100000: ALUctr = ADD;
                            6'b100010: ALUctr = SUB;
                            6'b100100: ALUctr = AND;
                            6'b100101: ALUctr = OR;
                            6'b101010: ALUctr = SLT;
                            6'b100110: ALUctr = XOR;
                            6'b000000: ALUctr = SLL;
                    endcase
                end
            
            6'b001001:	//addiu
                begin
                    RegDst   = 1'b1;
                    ALUSrc   = 1'b1;
                    MemtoReg = 1'b0; 
                    RegWr    = 1'b1; // 可以写到寄存器
                    MemWr    = 1'b0; // 不需要写存储器
                    NPCop    = ADD4;
                    ExtOp    = 1'b1;
                    ALUctr	 = ADDIU;				//addiu
                    if_branch = 1'b0;
                end

            6'b001000:	//addi
                begin
                    RegDst   = 1'b1;
                    ALUSrc   = 1'b1;
                    MemtoReg = 1'b0; 
                    RegWr    = 1'b1; // 可以写到寄存器
                    MemWr    = 1'b0; // 不需要写存储器
                    NPCop    = ADD4;
                    ExtOp    = 1'b0;
                    ALUctr	 = ADDI;				//addi
                    if_branch = 1'b0;
                end

            6'b001101:	//ori
                begin
                    RegDst   = 1'b1;
                    ALUSrc   = 1'b1;
                    MemtoReg = 1'b0; 
                    RegWr    = 1'b1; // 可以写到寄存器
                    MemWr    = 1'b0; // 不需要写存储器
                    NPCop    = ADD4;
                    ExtOp    = 1'b0;
                    ALUctr	=	ORI;				//ori
                    if_branch = 1'b0;
                end
            
            6'b001111:	//lui
                begin
                    RegDst   = 1'b1;  // rt作为reg的写入地址
                    ALUSrc   = 1'b1;
                    MemtoReg = 1'b0;  // 用于控制数据存储器能否输出数据到寄存器
                    RegWr    = 1'b1; // 写寄存器
                    MemWr    = 1'b0; // 用于控制数据存储器可否被写入
                    ExtOp    = 1'b1;
                    ALUctr   = LUI ;
                    NPCop    = ADD4;			//lui
                    if_branch = 1'b0;
                end

            6'b100011:	//lw
                begin
                    RegDst   = 1'b1;
                    MemtoReg = 1'b1; 
                    RegWr    = 1'b1; // 可以写到寄存器
                    MemWr    = 1'b0; // 不需要写存储器
                    NPCop    = ADD4;
                    ExtOp    = 1'b1;
                    ALUSrc   = 1'b1;
                    ALUctr   = ADD;
                    NPCop   =  ADD4;	
                    if_branch = 1'b0;
                end

            6'b101011:	//sw
                begin
                    RegDst   = 1'b1;
                    MemtoReg = 1'b0; 
                    RegWr    = 1'b0; // 读寄存器
                    MemWr    = 1'b1; // 不需要写存储器
                    NPCop    = ADD4;
                    ExtOp    = 1'b1;
                    ALUSrc   = 1'b1;
                    ALUctr   = ADD;
                    NPCop   =   ADD4;
                    if_branch = 1'b0;
                end

            6'b000100:	//beq
                begin
                    RegDst   = 1'b0;
                    MemtoReg = 1'b0; 
                    RegWr    = 1'b0; // 读寄存器
                    MemWr    = 1'b0; // 不需要写存储器
                    NPCop    = BEQ;
                    ALUSrc   = 1'b0;
                    ALUctr   = SUB;
                    NPCop    = BEQ;	
                    ExtOp    = 1'b1;
                    if_branch = 1'b1;
                end

            6'b000010:	//jump
                begin
                    RegDst   = 1'b1;
                    MemtoReg = 1'b0; 
                    RegWr    = 1'b0;
                    MemWr    = 1'b0; // 不需要写存储器
                    NPCop   = JUMP;			//Jump
                    if_branch = 1'b0;
                end
        endcase

        // $display("(controller.v) op: %b func: %b", op, func);
        // $display("(controller.v) RegDst: %b, ALUSrc: %b, MemtoReg: %b, RegWr: %b, MemWr: %b, ExtOp: %b", RegDst, ALUSrc, MemtoReg, RegWr, MemWr, ExtOp);
        // $display("(controller.v) ALUctr: %b, NPCop: %b", ALUctr, NPCop);
    end


endmodule