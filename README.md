# 编译原理:flex与bison--从0到1完成一个sample语言编译器

**博客**

[编译原理:flex与bison--从0到1完成一个编译器(sample语言)〇](https://blog.csdn.net/Yawning_Pants/article/details/120809257?spm=1001.2014.3001.5502)

[编译原理:flex与bison--从0到1完成一个编译器(sample语言)①](https://blog.csdn.net/Yawning_Pants/article/details/120808438?spm=1001.2014.3001.5502)

[编译原理:flex与bison--从0到1完成一个编译器(sample语言)②](https://blog.csdn.net/Yawning_Pants/article/details/124167295?spm=1001.2014.3001.5502)

[编译原理:flex与bison--从0到1完成一个编译器(sample语言)③](https://blog.csdn.net/Yawning_Pants/article/details/139422159?spm=1001.2014.3001.5502)



**简介**

本项目是我的编译原理作业，所实现的编译器包含词法分析，语法分析，语义分析与中间代码生成，目标代码生成共四个阶段，能将sample语言翻译成可执行的汇编语言。项目使用flex与bison工具辅助，通过C语言实现。

本人能力有限，项目有许多不足和值得改进的地方，也请多多指正。如果本项目有帮助，可以给个star。



**文件**

./Source 文件夹<br>
trans.tab.exe是可执行程序<br>
lex.l 词法分析程序<br>
trans.y 语法分析程序<br>
num2str.h 将各类型常数转换为十进制整数<br>
Table.h 生成汇编代码<br>

./Output 文件夹<br>
内有各测试用例的输入文件与输出文件



**运行方法**
控制台进入Source文件夹，
输入 chcp 65001
输入trans.tab<in ，输出语法分析过程，四元式，符号表和汇编语言
（如需更改输入文件，可将输入文件放到此文件夹内，或将内容复制到in文件中输入。）
复制输出的汇编代码部分，输入到asm文件中，使用dosbox运行汇编代码即可输出结果。
