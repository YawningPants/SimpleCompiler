#ifndef __TABLE
#define __TABLE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct QUATERLIST{						//四元式
	char op[6];
	int arg1;
	int arg2;
	int result;
}QUATERLIST;

typedef struct VARLIST{							//符号表
	char name[20];
	int type;
	int addr;
}VARLIST;

void generatehead(int table_size)
{
    printf("DATA SEGMENT\n\
    TAB DW %d DUP(?)\n\
    Temp db '0000H','$'\n\
    DATA ENDS\n",table_size);

    printf("CODE SEGMENT\n\
    ASSUME CS:CODE,DS:DATA\n\
    \n\
    START:\n\
    MOV AX,DATA\n\
    MOV DS,AX\n");
}

void generateNO(int i,char *res)
{
    sprintf(res,"NO%d",i);
}

void toAX(int arg,const VARLIST *varlist)
{
    char str[20];
    strcpy(str,varlist[arg].name);
    if(str[0]>='0'&&str[0]<='9'||str[0]=='\'')//立即数
    {
        printf("    MOV AX, %s\n",str);
        return;
    }
    if(str[0]=='T')//Tx 中间变量
    {
        int i=arg*2-2;
        printf("    MOV AX, TAB[%d]\n",i);
        return;
    }

    //变量
    int i=arg*2-2;
    printf("    MOV AX, TAB[%d]\n",i);
    return;
}

void generateOP(const QUATERLIST q,const VARLIST *v)
{
    int res_add=q.result*2-2;
    int arg2_add=q.arg2*2-2;
    char arg2_heheda[20];
    if(v[q.arg2].name[0]>='0'&&v[q.arg2].name[0]<='9')//arg2是立即数
        strcpy(arg2_heheda,v[q.arg2].name);
    else   
        sprintf(arg2_heheda,"TAB[%d]",arg2_add);

    char tore[20];
    generateNO(q.result,tore);
    
    if(strcmp(q.op,":=")==0)
    {
        toAX(q.arg1,v);       
        printf("    MOV TAB[%d], AX\n",res_add);
        return;
    }
    if(strcmp(q.op,"jnz")==0)
    {
        toAX(q.arg1,v);
        printf("    CMP AX,0\n\
    JNZ %s\n",tore);
        return;
    }
    if(strcmp(q.op,"j<")==0)
    {
        toAX(q.arg1,v);
        printf("    CMP AX, %s\n\
    JL %s\n",arg2_heheda ,tore);
        return;
    }
    if(strcmp(q.op,"j>")==0)
    {
        toAX(q.arg1,v);
        printf("    CMP AX, %s\n\
    JG %s\n",arg2_heheda,tore);
        return;
    }
    if(strcmp(q.op,"j=")==0)
    {
        toAX(q.arg1,v);
        printf("    CMP AX, %s\n\
    JE %s\n",arg2_heheda,tore);
        return;
    }
    if(strcmp(q.op,"j>=")==0)
    {
        toAX(q.arg1,v);
        printf("    CMP AX, %s\n\
    JGE %s\n",arg2_heheda,tore);
        return;
    }
    if(strcmp(q.op,"j<=")==0)
    {
        toAX(q.arg1,v);
        printf("    CMP AX, %s\n\
    JLE %s\n",arg2_heheda,tore);
        return;
    }
    if(strcmp(q.op,"j<>")==0)
    {
        toAX(q.arg1,v);
        printf("    CMP AX, %s\n\
    JNE %s\n",arg2_heheda,tore);
        return;
    }
    if(strcmp(q.op,"j")==0)
    {
        printf("    JMP %s\n",tore);
        return;
    }

    //转换语句
    if(q.op[1]=='-'&&q.op[2]=='>')
    {
    if(strcmp(q.op,"I->R")==0||strcmp(q.op,"B->R")==0||strcmp(q.op,"C->R")==0)
    {
        toAX(q.arg1,v);
        printf("    MOV BX, 100\n\
    IMUL BX\n\
    MOV TAB[%d], AX\n",res_add);
        return;
    }
    if(strcmp(q.op,"R->I")==0||strcmp(q.op,"R->C")==0)
    {
        toAX(q.arg1,v);
        printf("    MOV BX, 100\n\
    IDIV BX\n\
    MOV TAB[%d], AX\n",res_add);
        return;
    }
    if(strcmp(q.op,"I->B")==0||strcmp(q.op,"C->B")==0||strcmp(q.op,"I->B")==0)
    {
        toAX(q.arg1,v);
        printf("    AND AX, 0001H\n\
    MOV TAB[%d], AX\n",res_add);
        return;
    }

    else
    {
        toAX(q.arg1,v);
        printf("    MOV TAB[%d], AX\n",res_add);
        return;
    }
    return;
    }
    
    //运算语句
    if(strcmp(q.op,"Minus")==0)
    {
        printf("    MOV AX, 0\n\
    SUB AX, TAB[%d]\n\
    MOV TAB[%d], AX\n",q.arg1*2-2,res_add);
        return;
    }
    if(q.op[0]=='B')
    {
        toAX(q.arg1,v);
        if(strcmp(q.op,"BOOL+")==0||strcmp(q.op,"BOOL-")==0)
        {
            printf("    XOR AX, %s\n\
    MOV TAB[%d], AX\n",arg2_heheda,res_add);
            return;
        }
        if(strcmp(q.op,"BOOL*")==0||strcmp(q.op,"BOOL/")==0)
        {
            printf("    AND AX, %s\n\
    MOV TAB[%d], AX\n",arg2_heheda,res_add);
            return;
        }
        return;
    }

    int op_len=strlen(q.op);
    if(q.op[op_len-1]=='+')
    {
        toAX(q.arg1,v);
        printf("    ADD AX, %s\n\
    MOV TAB[%d], AX\n",arg2_heheda,res_add);
        return;
    }
    if(q.op[op_len-1]=='-')
    {
        toAX(q.arg1,v);
        printf("    SUB AX, %s\n\
    MOV TAB[%d], AX\n",arg2_heheda,res_add);
        return;
    }
    if(q.op[op_len-1]=='*')
    {
        toAX(q.arg1,v);
        printf("     MOV BX, %s\n\
    IMUL BX\n\
    MOV TAB[%d], AX\n",arg2_heheda,res_add);
        return;
    }
    if(q.op[op_len-1]=='/')
    {
        toAX(q.arg1,v);
        printf("    MOV BX, %s\n\
    IDIV BX\n\
    MOV TAB[%d], AX\n",arg2_heheda,res_add);
        return;
    }
    if(strcmp(q.op,"Stop")==0)
    {
        return;
    }
    else
    {
        fprintf (stderr, "Table.h: 无法识别的操作符！\n");
    }
    return;
}

void generateoutA(int n)
{
    printf("    MOV CX, %d\n\
    MOV SI, 0\n\
\n\
AGAIN:\n\
    MOV AX,TAB[SI]\n\
    CALL PrintAX\n\
    CALL PRINTHC\n\
    INC SI\n\
    INC SI\n\
    LOOP AGAIN\n",n);
}

void generatepro()
{
    printf("PrintAX proc\n\
    PUSH CX\n\
    PUSH SI\n\
    jmp Next\n\
\n\    
Next:\n\
    mov si,offset Temp+3;保存存储结果的字符串的最后一个字符偏移地址\n\
    xor cx,cx           ;对cX清零\n\
    mov cl,4            ;设置循环次数为4次\n\
\n\
MainPart:\n\
    mov DH,AL           ;将Al的内容传送给DH\n\
\n\
    shr AX,1\n\
    shr AX,1\n\
    shr AX,1\n\
    shr AX,1\n\
                ;上述4句为使AX逻辑右移4位 理论上可以写成 shr AX ,cl(cl设置为4)\n\
                ;但这个地方cl要记录循环次数每次循环会是cl-1所以无法满足正常的移位需要\n\
    and dh,0FH\n\
    add dh,30H\n\
    cmp dh,':'  ;':'的ASCII比9大1 而字母的ASCII码与数字的ASCII码中间隔了7个其它字符\n\
    ja isLetter ;如果为字母则跳转\n\
    jb No       ;如果不是\n\
\n\
isLetter:\n\
    add dh,7H   ;ASCII码加7变为字母\n\
No:\n\
    mov [si],dh ;将字符存入,待存放内容的字符串的对应位置\n\
\n\
    dec si      ;待存放内容的内存地址自减1\n\
loop MainPart\n\
\n\
print:\n\
    mov dx,offset Temp  ;将带打印的字符串的偏移地址存放进dx中\n\
    mov ah,09           ;设置DOS 09号功能\n\
    int 21H         ;功能调用\n\
\n\
    POP SI\n\
    POP CX\n\
\n\
    ret\n\
PrintAX endp\n\
\n\
\n\
PRINTHC proc\n\
    MOV DL, 10\n\
    MOV AH, 2\n\
    INT 21H\n\
    RET\n\
PRINTHC ENDP\n");
}


void generateend()
{
    printf("NO0:\n");
    printf("    MOV AH,4CH\n\
    INT 21H\n");
}

void generateend2()
{
    printf("    CODE ENDS\n\
    END START\n");
}

void generate(const QUATERLIST *q,int nxq,const VARLIST *v,int n)
{
    char no[20];
    int i=0;
    generatehead(n);
    for(i=1;i<nxq;i++)
    {
        generateNO(i,no);
        printf("%s:\n",no);
        generateOP(q[i],v);
    }

    generateoutA(n);
    generateend();
    generatepro();
    generateend2();

}

#endif