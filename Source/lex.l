/****************************************************/
/* File: lex.l   Lex specification for SIMPLE */
/****************************************************/

%{
#include "stdio.h"
#include "trans.tab.h"
#include<string.h>
int row=1;
%}
DIGIT [0-9]
LETTER [a-zA-Z]
%%
\n {row++;}
"/*"(.|\n)*"*/"  {            

    int len=strlen(yytext);
    int num=0;
    for(int i=0;i<len;i++)
        if(yytext[i]=='\n')
            num++;
    row+=num;
}
"/*"                        { printf("%4d\t缺少注释\n", row); }
"*/"                        { printf("%4d\t缺少注释\n", row); }
{DIGIT}|[1-9]{DIGIT}+       { return ZHENGSHU;}
{DIGIT}+"."{DIGIT}+         { return SHISHU; }
0[0-7]+                     { return BAJIN; }
0x[0-9A-Fa-f]+                 { return SHILIU; }
{DIGIT}+"."{DIGIT}+"e"(""|"-"){DIGIT}+  { return ZHISHU; }
'.'                        { return ZIFU; }

program     { return PROGRAM; }
var         { return VAR; }
integer     { return INTEGER; }
bool        { return BOOL; }
real        { return REAL; }
char        { return CHAR; }
const       { return CONST; }

begin       { return BEGINN; }
if          { return IF; }
then        { return THEN; }
else        { return ELSE; }
while       { return WHILE; }
do          { return DO; }
repeat      { return REPEAT; }
until       { return UNTIL; }
for         { return FOR; }
to          { return TO; }
of          { return OF; }
input       { return INPUT; }
output      { return OUTPUT; }
not         { return NOT; }
and         { return AND; }
or          { return OR; }
true        { return TRUE; }
false       { return FALSE; }
end         { return END; }
case        { return CASE; }
read        { return READ; }
write       { return WRITE; }

"+"         { return ADD; }
"-"         { return SUB; }
"*"         { return MUL; }
"/"         { return DIV; }
"<"         { return LT; }
">"         { return GT; }
"<="        { return XD; }
">="        { return DD; }
"="         { return DY; }
":="        { return FZ; }
"<>"        { return XORD; }
":"         { return MAOHAO; }
","         { return DOUHAO; }


"//".*      {  }


";"         { return FENHAO; }

"("         { return ZUOXIAO; }
")"         { return YOUXIAO; }
"."         { return DIAN; }
"{"         { return ZUODA; }
"}"         { return YOUDA; }
"["         { return ZUOZHONG; }
"]"         { return YOUZHONG; }


[a-zA-Z][a-zA-Z0-9]*        { strcpy(yylval.str,yytext);return BIAOSHI; }  
[0-9][0-9a-zA-Z\.]+            { printf("%4d\t不能识别的字符：%s\n", row,yytext); }
[\t\x20]+          /*删除多余的空格*/
.           { printf("%4d\t不能识别的字符：%s\n", row,yytext); } 
%%
int yywrap() 
{ return 1; }