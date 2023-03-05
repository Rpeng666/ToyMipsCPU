# Toy Mips CPU

20级南航计算机组成原理A实验



## 开发环境

- Vscode + verilog 插件

- 轻量化Verilog仿真工具iverilog 和 波形图软件 GTKWave

  

## 仓库结构

```
ToyMipsCPU
├─pipline_cpu_1                   14条指令的流水线CPU（不带冒险和转发）
│  ├─control
│  └─datapath
│      └─mid_reg
├─pipline_cpu_14_instructions     14条指令的流水线CPU（带冒险和转发）
│  ├─control
│  └─datapath
│      └─mid_reg
└─single_cycle_cpu                14条指令的单周期CPU
    ├─control
    └─datapath
```

> pipline_cpu_1 不带转发和冒险，所以实际运行出来的结果是错误的. 仅作为学习流水线的前置知识



## 支持的指令(14条)

add, addi, addiu, sub, and, or, ori, xor, lui, slt, lw, beq, j



## 其他

课设50+条指令写得太烂故不放出，只分享平时实验的代码. 

~~学计组是不可能的，这辈子都不想碰CPU了:sob:~~