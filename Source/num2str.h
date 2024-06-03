#ifndef __NUM2STR
#define __NUM2STR
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void num2str(char *num,char *type)
{   
    
    if(strcmp(type,"zhengshu")==0)
    {
        return;
    }
    if(strcmp(type,"shishu")==0||strcmp(type,"zhishu")==0)
    {
        double tmp1=atof(num);
        tmp1*=100;
        int tmp2=tmp1;
        sprintf(num,"%d",tmp2);
        return;
    }
    if(strcmp(type,"shiliu")==0)
    {
        int tmp;
        sscanf(num,"%x",&tmp);
        sprintf(num,"%d",tmp);
        return;
    }
    if(strcmp(type,"bajin")==0)
    {
        int tmp;
        sscanf(num,"%o",&tmp);
        sprintf(num,"%d",tmp);
        return;
    }
    if(strcmp(type,"zifu")==0)
    {
        return;
    }

    else{
        printf("num2str error\n");
    }
    return;
}




#endif