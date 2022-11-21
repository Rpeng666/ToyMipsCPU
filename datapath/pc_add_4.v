module pc_add_4 (PC, pc_add_4);
    input    [31: 0] PC;
    output   [31: 0] pc_add_4;

    assign pc_add_4 = PC + 4;

endmodule 