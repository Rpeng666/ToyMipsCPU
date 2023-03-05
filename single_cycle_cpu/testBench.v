`timescale 1ps/1ps
`include "./mips.v"

module Testbench();
    reg    clk ;
    reg    rst ;
    
    Mips mips(clk, rst);

    initial 
        begin
            $dumpfile("testBench.vcd");
            $dumpvars;
            clk <= 0 ;
            rst <= 1 ;
            #10 rst <= 0 ; 
            #2000 $finish;
        end
            
    integer cnt = 0;
    
    always@(*)
    begin
         #20 clk<=~clk;
         cnt = cnt + 1;
    end
       
    
endmodule