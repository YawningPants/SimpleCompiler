%{
#include "lex.yy.c"
#include "num2str.h"
#include "Table.h"
#include "Table.h"
#include <stdio.h>
#include <math.h>
#define MAXMEMBER 100

int Entry(char *name);                        //如果符号表里没有放入符号表
int FillType(int first,int type);             //符号表中first之后的类型都是type
int NewTemp();                                 //产生Tx的随机变量并输入符号表
int Merge(int p,int q);                       //找到q的result是0然后将result改为p
void BackPatch(int p,int t);               //回填
int GEN(char* op,int a1,int a2,int re);               
void OutputQ();                               //输出四元式 
void OutputIList();                           //输出符号表
int yyparse();

int NXQ=1;
int VarCount=0;

extern int row;

struct QUATERLIST QuaterList[MAXMEMBER];    //四元式

struct VARLIST VarList[MAXMEMBER];          //符号表

%}

%union
{
    int NO;
    struct { int TC,FC;} _BExpr;
    struct { int QUAD,CH;} _WBD;
    struct { int type,place;} _Expr;
    char str[20];
}

%start chengxu

%token ZHENGSHU
%token SHISHU
%token BAJIN
%token SHILIU
%token ZHISHU
%token ZIFU

%token PROGRAM
%token VAR
%token INTEGER
%token BOOL
%token REAL
%token CHAR
%token CONST

%token BEGINN
%token IF
%token THEN
%token ELSE
%token WHILE
%token DO
%token REPEAT
%token UNTIL
%token FOR
%token TO
%token OF
%token INPUT
%token OUTPUT
%token NOT
%token AND
%token OR
%token TRUE
%token FALSE
%token END
%token CASE
%token READ
%token WRITE

%token ADD
%token SUB
%token MUL
%token DIV
%token LT
%token GT
%token XD
%token DD
%token DY
%token FZ
%token XORD
%token MAOHAO
%token DOUHAO

%token FENHAO

%token ZUOXIAO
%token YOUXIAO
%token DIAN
%token ZUODA
%token YOUDA
%token ZUOZHONG
%token YOUZHONG

%token BIAOSHI

/*类型定义*/
%type <str> BIAOSHI
%type <NO> leixing
%type <_Expr> changshu
%type <NO> bianliangdingyi
%type <NO> biaoshifubiao
%type <NO> bianliang
%type <str> buerchangshu
%type <_Expr> biaodashi
%type <_Expr> suanshubiaodashi
%type <_BExpr> buerbiaodashi
%type <_Expr> xiang
%type <_Expr> yinzi
%type <_Expr> suanshuliang
%type <_BExpr> buerxiang
%type <_BExpr> bueryinzi
%type <_BExpr> buerliang
%type <str> guanxifu
%type <NO> changliangshuoming
%type <NO> bianliangshuoming
%type <NO> changshudingyi
%type <NO> zhixingyuju
%type <NO> jiandanju
%type <NO> fuzhiyuju
%type <NO> jiegouju
%type <NO> fuheju
%type <NO> ifyuju
%type <NO> whileyuju
%type <NO> foryuju
%type <NO> repeatyuju
%type <NO> yujubiao

%type <NO> I_F
%type <NO> I_F_E
%type <_WBD> Wd
%type <NO> W
%type <_WBD> R_U
%type <_WBD> R
%type <_WBD> F_T



%%
/*Sample语言程序的定义*/
chengxu:
    PROGRAM BIAOSHI FENHAO fenchengxu                   {printf("<程序> ::= program <标识符>;<分程序>\n"); printf("\nAnalysis end.\n");}
;
fenchengxu:
    changliangshuoming bianliangshuoming fuheju DIAN    {printf("<分程序> ::= <常量说明><变量说明><复合句>.\n"); GEN("Stop",0,0,0);}
;

/*Sample语言数据类型的定义*/
leixing:
    INTEGER     {$$ = INTEGER;}
|   BOOL        {$$ = BOOL;}
|   CHAR        {$$ = CHAR;}
|   REAL        {$$ = REAL;}
;

/*Sample语言单词的定义*/
changshu:
    ZHENGSHU    {$$.type=INTEGER; char s[20]; strcpy(s,yytext); num2str(s,"zhengshu"); int i=Entry(s); VarList[i].type=INTEGER; $$.place=i;}
|   buerchangshu  {$$.type=BOOL; int i=Entry($1); VarList[i].type=BOOL; $$.place=i;}
|   ZIFU        {$$.type=CHAR; char s[20]; strcpy(s,yytext); num2str(s,"zifu");  int i=Entry(s); VarList[i].type=CHAR; $$.place=i;}
|   SHISHU      {$$.type=REAL; char s[20]; strcpy(s,yytext); num2str(s,"shishu");  int i=Entry(s); VarList[i].type=REAL; $$.place=i;}
|   SHILIU      {$$.type=INTEGER; char s[20]; strcpy(s,yytext); num2str(s,"shiliu");  int i=Entry(s); VarList[i].type=INTEGER; $$.place=i;}
|   BAJIN       {$$.type=INTEGER; char s[20]; strcpy(s,yytext); num2str(s,"bajin");  int i=Entry(s); VarList[i].type=INTEGER; $$.place=i;}
|   ZHISHU      {$$.type=REAL; char s[20]; strcpy(s,yytext); num2str(s,"zhishu");  int i=Entry(s); VarList[i].type=REAL; $$.place=i;}
;

buerchangshu:
    TRUE        {strcpy($$,"1");}
|   FALSE       {strcpy($$,"0");}
;

/*Sample语言表达式的定义*/
biaodashi:                      
    suanshubiaodashi            {printf("<表达式> ::= <算术表达式> \n"); $$=$1;}
|   buerbiaodashi               
    {
        printf("<表达式> ::= <布尔表达式>  \n"); 
        $$.type=BOOL;
        int t=Entry("1");
        VarList[t].type=BOOL;
        int f=Entry("0");
        VarList[f].type=BOOL;
        int nt=NewTemp();
        VarList[nt].type=BOOL;
        int q=NXQ;
        BackPatch($1.TC,NXQ);
        BackPatch($1.FC,NXQ+2);
        GEN(":=",t,0,nt);
        GEN("j",0,0,q+4);
        GEN(":=",f,0,nt);
        GEN("j",0,0,q+4);
        $$.place=nt;
    }
;


suanshubiaodashi:
    suanshubiaodashi ADD xiang  
    {
        printf("<算术表达式> ::= <算术表达式>+<项>\n");
        int t=NewTemp();
        $$.place=t;
        //$1.type=integer
        if($1.type==INTEGER && $3.type==INTEGER)
        {
            GEN("Int+",$1.place,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("B->I",$3.place,0,u);
            GEN("Int+",$1.place,u,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$3.place,0,u);
            GEN("Int+",$1.place,u,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("I->R",$1.place,0,u);
            GEN("Real+",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        //$1.type=bool
        else if($1.type==BOOL && $3.type==BOOL)
        {
            GEN("Bool+",$1.place,$3.place,t);
            VarList[t].type=BOOL;
            $$.type=BOOL;
        }
        else if($1.type==BOOL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER ;
            GEN("B->I",$1.place,0,u);
            GEN("Int+",u,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==BOOL && $3.type==CHAR)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("B->I",$1.place,0,u);
            GEN("C->I",$3.place,0,v);
            GEN("Int+",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==BOOL && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$1.place,0,u);
            GEN("Real+",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }

        //$1.type=char
        else if($1.type==CHAR && $3.type==CHAR)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("C->I",$3.place,0,v);
            GEN("Int+",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("Int+",u,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==BOOL)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("B->I",$3.place,0,v);
            GEN("Int+",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$1.place,0,u);
            GEN("Real+",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }

        //$1.type=real
        else if($1.type==REAL && $3.type==REAL)
        {
            GEN("Real+",$1.place,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("I->R",$3.place,0,u);
            GEN("Real+",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$3.place,0,u);
            GEN("Real+",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$3.place,0,u);
            GEN("Real+",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
    }
|   suanshubiaodashi SUB xiang  
    {
        printf("<算术表达式> ::= <算术表达式>-<项>\n");
        int t=NewTemp();
        $$.place=t;
        //$1.type=integer
        if($1.type==INTEGER && $3.type==INTEGER)
        {
            GEN("Int-",$1.place,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("B->I",$3.place,0,u);
            GEN("Int-",$1.place,u,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$3.place,0,u);
            GEN("Int-",$1.place,u,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("I->R",$1.place,0,u);
            GEN("Real-",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        //$1.type=bool
        else if($1.type==BOOL && $3.type==BOOL)
        {
            GEN("Bool-",$1.place,$3.place,t);
            VarList[t].type=BOOL;
            $$.type=BOOL;
        }
        else if($1.type==BOOL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("B->I",$1.place,0,u);
            GEN("Int-",u,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==BOOL && $3.type==CHAR)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("B->I",$1.place,0,u);
            GEN("C->I",$3.place,0,v);
            GEN("Int-",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==BOOL && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$1.place,0,u);
            GEN("Real-",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }

        //$1.type=char
        else if($1.type==CHAR && $3.type==CHAR)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("C->I",$3.place,0,v);
            GEN("Int-",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("Int-",u,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==BOOL)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("B->I",$3.place,0,v);
            GEN("Int-",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$1.place,0,u);
            GEN("Real-",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }

        //$1.type=real
        else if($1.type==REAL && $3.type==REAL)
        {
            GEN("Real-",$1.place,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("I->R",$3.place,0,u);
            GEN("Real-",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$3.place,0,u);
            GEN("Real-",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$3.place,0,u);
            GEN("Real-",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }    
    }
|   ADD xiang                   
    {
        printf("<算术表达式> ::= +<项>\n");
        $$=$2;
    }
|   SUB xiang                   
    {
        printf("<算术表达式> ::= -<项>\n");
        int t=NewTemp();
        VarList[t].type=$2.type;
        GEN("Minus",$2.place,0,t);
        $$.place=t;
        $$.type=$2.type;
    }
|   xiang   {   printf("<算术表达式> ::= <项>\n"); $$=$1;    }
;

xiang:
    xiang MUL yinzi             
    {
        printf("<项> ::= <项>*<因子>\n");
        int t=NewTemp();
        $$.place=t;
        //$1.type=integer
        if($1.type==INTEGER && $3.type==INTEGER)
        {
            GEN("Int*",$1.place,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("B->I",$3.place,0,u);
            GEN("Int*",$1.place,u,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$3.place,0,u);
            GEN("Int*",$1.place,u,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("I->R",$1.place,0,u);
            GEN("Real*",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        //$1.type=bool
        else if($1.type==BOOL && $3.type==BOOL)
        {
            GEN("Bool*",$1.place,$3.place,t);
            VarList[t].type=BOOL;
            $$.type=BOOL;
        }
        else if($1.type==BOOL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("B->I",$1.place,0,u);
            GEN("Int*",u,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==BOOL && $3.type==CHAR)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("B->I",$1.place,0,u);
            GEN("C->I",$3.place,0,v);
            GEN("Int*",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==BOOL && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$1.place,0,u);
            GEN("Real*",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }

        //$1.type=char
        else if($1.type==CHAR && $3.type==CHAR)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("C->I",$3.place,0,v);
            GEN("Int*",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("Int*",u,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==BOOL)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("B->I",$3.place,0,v);
            GEN("Int*",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$1.place,0,u);
            GEN("Real*",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }

        //$1.type=real
        else if($1.type==REAL && $3.type==REAL)
        {
            GEN("Real*",$1.place,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("I->R",$3.place,0,u);
            GEN("Real*",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$3.place,0,u);
            GEN("Real*",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$3.place,0,u);
            GEN("Real*",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
    }
|   xiang DIV yinzi             
    {
        printf("<项> ::= <项>/<因子>\n");
        int t=NewTemp();
        $$.place=t;

        //$1.type=integer
        if($1.type==INTEGER && $3.type==INTEGER)
        {
            GEN("Int/",$1.place,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("B->I",$3.place,0,u);
            GEN("Int/",$1.place,u,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$3.place,0,u);
            GEN("Int/",$1.place,u,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==INTEGER && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("I->R",$1.place,0,u);
            GEN("Real/",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        //$1.type=bool
        else if($1.type==BOOL && $3.type==BOOL)
        {
            GEN("Bool/",$1.place,$3.place,t);
            VarList[t].type=BOOL;
            $$.type=BOOL;
        }
        else if($1.type==BOOL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("B->I",$1.place,0,u);
            GEN("Int/",u,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==BOOL && $3.type==CHAR)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("B->I",$1.place,0,u);
            GEN("C->I",$3.place,0,v);
            GEN("Int/",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==BOOL && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$1.place,0,u);
            GEN("Real/",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }

        //$1.type=char
        else if($1.type==CHAR && $3.type==CHAR)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("C->I",$3.place,0,v);
            GEN("Int/",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("Int/",u,$3.place,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==BOOL)
        {
            int u=NewTemp();
            int v=NewTemp();
            VarList[u].type=INTEGER;
            VarList[v].type=INTEGER;
            GEN("C->I",$1.place,0,u);
            GEN("B->I",$3.place,0,v);
            GEN("Int/",u,v,t);
            VarList[t].type=INTEGER;
            $$.type=INTEGER;
        }
        else if($1.type==CHAR && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$1.place,0,u);
            GEN("Real/",u,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }

        //$1.type=real
        else if($1.type==REAL && $3.type==REAL)
        {
            GEN("Real/",$1.place,$3.place,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("I->R",$3.place,0,u);
            GEN("Real/",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$3.place,0,u);
            GEN("Real/",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
        else if($1.type==REAL && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$3.place,0,u);
            GEN("Real/",$1.place,u,t);
            VarList[t].type=REAL;
            $$.type=REAL;
        }
    
    }
|   yinzi                       {printf("<项> ::= <因子>\n");   $$=$1;}
;

yinzi:
    suanshuliang                        {printf("<因子> ::= <算术量>\n"); $$=$1;}
|   ZUOXIAO suanshubiaodashi YOUXIAO    {printf("<因子> ::= (<算术表达式>) \n"); $$=$2;}
;

suanshuliang:
    BIAOSHI                     {printf("标识符算数量\n"); int i=Entry($1); $$.place=i; $$.type=VarList[i].type;}
|   changshu                    {printf("常数算数量\n"); $$=$1;}
;

buerbiaodashi:
    buerbiaodashi OR   {BackPatch($1.FC,NXQ);}     buerxiang  {printf("<布尔表达式> ::= <布尔表达式> or <布尔项>\n");   $$.FC=$4.FC;    $$.TC=Merge($1.TC,$4.TC);}
|   buerxiang                   {printf("<布尔表达式> ::= <布尔项>\n"); $$=$1;}   
;

buerxiang:
    buerxiang AND   {BackPatch($1.TC,NXQ);}    bueryinzi     {printf("<布尔项> ::= <布尔项> and <布尔因子>\n"); $$.TC=$4.TC;    $$.FC=Merge($1.FC,$4.FC);}
|   bueryinzi                   {printf("<布尔项> ::= <布尔因子>\n");   $$=$1;}
;

bueryinzi:
    buerliang                   {printf("<布尔因子> ::= <布尔量> \n");  $$=$1;}
|   NOT bueryinzi               {printf("<布尔因子> ::= not<布尔因子> \n"); $$.TC=$2.FC;    $$.FC=$2.TC;}
;

buerliang:
    ZUOXIAO buerbiaodashi YOUXIAO   {printf("<布尔量> ::= (<布尔表达式>) \n");  $$=$2;}
|   buerchangshu                
    {
        printf("<布尔量> ::= <布尔常数> \n");
        int i=Entry($1);
        $$.TC=NXQ;
        $$.FC=NXQ+1;
        GEN("jnz",i,0,0);
        GEN("j",0,0,0);
    }
|   BIAOSHI                     
    {
        printf("<布尔量> ::= <标识符> \n");
        int i=Entry($1);
        $$.TC=NXQ;
        $$.FC=NXQ+1;
        GEN("jnz",i,0,0);
        GEN("j",0,0,0);
    }
|   ZUOXIAO suanshubiaodashi guanxifu suanshubiaodashi YOUXIAO  
    {
        printf("<布尔量> ::= (<算术表达式><关系符><算术表达式>)\n");
        $$.TC=NXQ;
        $$.FC=NXQ+1;
        GEN($3,$2.place,$4.place,0);
        GEN("j",0,0,0);
    }
;

guanxifu:
    LT                           {printf("<关系符> ::= < \n");  strcpy($$,"j<");}
|   GT                           {printf("<关系符> ::= > \n");  strcpy($$,"j>");}
|   XORD                         {printf("<关系符> ::= <> \n"); strcpy($$,"j<>");}
|   XD                           {printf("<关系符> ::= <= \n"); strcpy($$,"j<=");}
|   DD                           {printf("<关系符> ::= >= \n"); strcpy($$,"j>=");}
|   DY                           {printf("<关系符> ::= = \n");  strcpy($$,"j=");}
;


/* Sample语言语句的定义*/


changliangshuoming:
    CONST changshudingyi FENHAO {printf("<常量说明> ::= const  <常数定义>; \n");}
|                               {printf("<常量说明> ::= e \n");}   
;

changshudingyi:
    changshudingyi FENHAO bianliang FZ changshu        {printf("<常数定义> ::= <常数定义>,<变量>=<常数> \n"); FillType($3,$5.type); GEN(":=",$5.place,0,$3);}   
|   bianliang FZ changshu                              {printf("<常数定义> ::= <变量>=<常数>  \n"); FillType($1,$3.type); GEN(":=",$3.place,0,$1);}
;

bianliangshuoming:
    VAR bianliangdingyi FENHAO                           {printf("<变量说明> ::= var  <变量定义>  \n");}
|                                                   {printf("<变量说明> ::= e  \n");}
;

bianliangdingyi:
    biaoshifubiao MAOHAO leixing                             {printf("<变量定义> ::= <标识符表>:<类型>; \n"); FillType($1,$3);}
|   bianliangdingyi FENHAO biaoshifubiao MAOHAO leixing      {printf("<变量定义> ::= <标识符表>:<类型>;<变量定义>  \n"); FillType($3,$5);}
;

biaoshifubiao:
    bianliang DOUHAO biaoshifubiao    {printf("<标识符表> ::= <变量>, <标识符表>  \n");  $$=$1;}
|   bianliang                         {printf("<标识符表> ::= <变量>   \n");  $$=$1;}
;

zhixingyuju:
    jiandanju           {printf("<执行语句> ::= <简单句>   \n");$$=0;}
|   jiegouju            {printf("<执行语句> ::= <结构句>   \n");$$=$1;BackPatch($1,NXQ);}
;

jiandanju:
    fuzhiyuju FENHAO           {printf("<简单句> ::= <赋值语句>   \n");}
;

fuzhiyuju:
    bianliang FZ biaodashi   
    {
        printf("<赋值语句> ::= <变量>:=<表达式>    \n");
        // int t=NewTemp();
        //$1.type=integer
        if(VarList[$1].type==INTEGER && $3.type==INTEGER)
        {
            GEN(":=",$3.place,0,$1);
        }
        else if(VarList[$1].type==INTEGER && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("B->I",$3.place,0,u);
            GEN(":=",u,0,$1);
        }
        else if(VarList[$1].type==INTEGER && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("C->I",$3.place,0,u);
            GEN(":=",u,0,$1);
        }
        else if(VarList[$1].type==INTEGER && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=INTEGER;
            GEN("R->I",$3.place,0,u);
            GEN(":=",u,0,$1);
        }

        //$1.type=bool
        else if(VarList[$1].type==BOOL && $3.type==BOOL)
        {
            GEN(":=",$3.place,0,$1);
        }
        else if(VarList[$1].type==BOOL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=BOOL;
            GEN("I->B",$3.place,0,u);
            GEN(":=",u,0,$1);
        }
        else if(VarList[$1].type==BOOL && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=BOOL;
            GEN("C->B",$3.place,0,u);
            GEN(":=",u,0,$1);
        }
        else if(VarList[$1].type==BOOL && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=BOOL;
            GEN("R->B",$3.place,0,u);
            GEN(":=",u,0,$1);
        }

        //$1.type=char
        else if(VarList[$1].type==CHAR && $3.type==CHAR)
        {
            GEN(":=",$3.place,0,$1);
        }
        else if(VarList[$1].type==CHAR && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=CHAR;
            GEN("I->C",$3.place,0,u);
            GEN(":=",u,0,$1);
        }
        else if(VarList[$1].type==CHAR && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=CHAR;
            GEN("B->C",$3.place,0,u);
            GEN(":=",u,0,$1);
        }
        else if(VarList[$1].type==CHAR && $3.type==REAL)
        {
            int u=NewTemp();
            VarList[u].type=CHAR;
            GEN("R->C",$3.place,0,u);
            GEN(":=",u,0,$1);
        }

        //$1.type=real
        else if(VarList[$1].type==REAL && $3.type==REAL)
        {
            GEN(":=",$3.place,0,$1);
        }
        else if(VarList[$1].type==REAL && $3.type==INTEGER)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("I->R",$3.place,0,u);
            GEN(":=",$3.place,0,$1);
        }
        else if(VarList[$1].type==REAL && $3.type==BOOL)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("B->R",$3.place,0,u);
            GEN(":=",u,0,$1);
        }
        else if(VarList[$1].type==REAL && $3.type==CHAR)
        {
            int u=NewTemp();
            VarList[u].type=REAL;
            GEN("C->R",$3.place,0,u);
            GEN(":=",u,0,$1);
        }
    }
;

bianliang:
    BIAOSHI                   {printf("<变量> ::= <标识符>    \n"); $$=Entry(yytext);}
;

jiegouju:
    fuheju              {printf("<结构句> ::= <复合句>    \n"); $$=$1;}
|   ifyuju              {printf("<结构句> ::= <if语句>    \n"); $$=$1;}
|   whileyuju           {printf("<结构句> ::= <while语句>    \n"); $$=$1;  }
|   foryuju             {printf("<结构句> ::= <for语句>    \n"); $$=$1;    }
|   repeatyuju          {printf("<结构句> ::= <repeat语句>    \n"); $$=$1; }
;

fuheju:
    BEGINN yujubiao END     {printf("<复合句> ::= begin <语句表> end     \n");$$=0;}
;

yujubiao:
    zhixingyuju  yujubiao     {printf("<语句表> ::= <执行语句>;<语句表>   \n"); $$=$1;  }/**/
|   zhixingyuju               {printf("<语句表> ::= <执行语句>   \n"); $$=$1;   }/**/
;

ifyuju:
    I_F_E zhixingyuju      {printf("<if语句> ::= <I_F_E> <执行语句> \n"); $$=Merge($1,$2);}
|   I_F zhixingyuju                       {printf("<if语句> ::= <I_F> <执行语句> \n"); $$=Merge($1,$2);}
;

I_F_E:  
    I_F zhixingyuju ELSE     {printf("<I_F_E> ::= <I_F> <执行语句> else\n"); int q=NXQ; GEN("j",0,0,0); BackPatch($1,NXQ); $$=Merge($2,q);}

I_F:
    IF buerbiaodashi THEN       {printf("<I_F> ::=  if <布尔表达式> then\n");BackPatch($2.TC,NXQ);$$=$2.FC;}
;



whileyuju:
    Wd DO zhixingyuju              
    {
        printf("<while语句> ::= <WD> do <执行语句>\n");
        GEN("j",0,0,$1.QUAD);
        BackPatch($3,$1.QUAD);
        $$=$1.CH;
    }
;

Wd:
    W buerbiaodashi                {printf("<WD> := <W><布尔表达式>\n");BackPatch($2.TC,NXQ);$$.QUAD=$1;$$.CH=$2.FC;}
;

W: WHILE                            {printf("<W> := while \n"); $$=NXQ;}

foryuju:
    F_T DO zhixingyuju              {printf(" <for语句> ::= <F_T> do  <执行语句>\n"); BackPatch($3,$1.QUAD); GEN("j",0,0,$1.QUAD); $$=$1.CH;}
;

F_T:
    FOR BIAOSHI FZ suanshubiaodashi TO suanshubiaodashi     {
                                                                printf(" <for语句> ::= <F_T> do  <执行语句>\n"); 
                                                                $$.CH=Entry($2); 
                                                                GEN(":=",$4.place,0,$$.CH);
                                                                int q=NXQ;
                                                                $$.QUAD=q+1;
                                                                GEN("j",0,0,q+2);
                                                                int one=Entry("1");
                                                                VarList[one].type=INTEGER;
                                                                GEN("Int+",$$.CH,one,$$.CH);
                                                                GEN("j<=",$$.CH,$6.place,q+4);
                                                                $$.CH=NXQ;
                                                                GEN("j",0,0,0);
                                                            }
;


repeatyuju:
    R_U buerbiaodashi                {printf("<repeat语句> ::=<R_U> <布尔表达式>\n"); BackPatch($2.FC,$1.QUAD);$$=$2.TC;}
;

R_U:
    R zhixingyuju UNTIL              {printf("<R_U> := <R>  <执行语句>  until\n");$$.QUAD=$1.QUAD; BackPatch($2,NXQ);}
;

R:
    REPEAT                           {printf("<R_U> := <R>  <执行语句>  until\n");$$.QUAD=NXQ;}
;




%%


void OutputQ(void)
{
      int i;
      printf("\nQuarterList output:\n");
      for(i=0;i<NXQ;i++)
      {
        printf("NO.%4d ( %8s, ",i,QuaterList[i].op);
        if(QuaterList[i].arg1)
            printf("%6s, ",VarList[QuaterList[i].arg1].name);
        else printf("      , ");
        if(QuaterList[i].arg2)
            printf("%6s, ",VarList[QuaterList[i].arg2].name);
        else printf("      , ");
        if((QuaterList[i].op[0]=='j')||(QuaterList[i].op[0]=='S')) 
            printf("%6d ) \n",QuaterList[i].result);
        else if(QuaterList[i].result)
            printf("%6s )\n",VarList[QuaterList[i].result].name);
        else printf("-\t )\n");
      }
     return;
}


int Entry(char *name)			//找到名位name的变量在符号表中的下标
{
     int i;
     for(i=1;i<=VarCount;i++) 
            if(!strcmp(name,VarList[i].name)) 
                      return i;
     if(++VarCount>MAXMEMBER) 
     {
             printf("Too many Variables!\n");exit(-1);
     }
     strcpy(VarList[VarCount].name,name);
     return VarCount;
}

int FillType(int first,int type)	//在符号表中first往后的元素类型都设为type
{ 
    int i;
    for(i=first;i<=VarCount;i++)
          VarList[i].type=type;
    return i-1;
}

int Merge(int p,int q)
{
   int r;
   if(!q) 
        return p;
   else
   {
       r=q;
       while(QuaterList[r].result)
        r=QuaterList[r].result;
       QuaterList[r].result=p;
   }
   return q;
}

void BackPatch(int p,int t)
{
    printf("*****************BackPatch %d,%d\n",p,t);
     int q=p;
     while(q)
     { 
           int q1=QuaterList[q].result;
           if(q1==q)
           {
               printf("backpatch error %d \n",q);
               break;
           }
           if(q==t)
           {
               printf("backpatch error2 %d \n",q);
               break;
           }
           QuaterList[q].result=t;
           q=q1;
     } 
     return;
}

int GEN(char* op,int a1,int a2,int re)
{
     strcpy(QuaterList[NXQ].op,op);
     QuaterList[NXQ].arg1=a1;
     QuaterList[NXQ].arg2=a2;
     QuaterList[NXQ].result=re;
     NXQ++;
     return NXQ;
}

int NewTemp()	//在符号表中插入Ti
{
     static int no=0;
     char Tname[10];
     sprintf(Tname,"T%o",no++);
     return Entry(Tname);
}

void OutputIList(void)
{
     int i;
     printf(" Addr.\t name \t\t   type\n");
     for(i=1;i<=VarCount;i++)
     {
           printf("%4d\t%6s\t\t",i,VarList[i].name);
            if(VarList[i].type==INTEGER)
                printf(" integer  \n");
            else if(VarList[i].type==BOOL)
                printf(" bool     \n");
            else if(VarList[i].type==CHAR)
                printf(" char     \n");
            else if(VarList[i].type==REAL)
                printf(" real     \n");
            else
                printf("          \n");
      }
      return;
}




int main(void)
{
  /*yydebug = 1;*/    /*bison -d -t*/ /*bison -d -v*/
//   system("chcp 65001");
    yyparse();
    OutputQ();
    OutputIList();
    generate(QuaterList,NXQ,VarList,VarCount);
    return 0;
}

/* Called by yyparse on error.  */
int yyerror (char const *s)
{
  printf("第%3d 行出错\n",row);
  fprintf (stderr, "%s\n", s);
}