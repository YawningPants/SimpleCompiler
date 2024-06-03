bison -d trans.y
flex lex.l
tcc trans.tab.c
trans.tab<in