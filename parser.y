%{ 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "scanType.h"

extern int yylex();
extern FILE *yyin;
extern int yydebug;

#define YYERROR_VERBOSE

//// any C/C++ functions you want here that might be used in grammar actions below
//// any C/C++ globals you want here that might be used in grammar actions below

%}

//// your %union statement

//// your %token statements defining token classes

%%
tokenlist     : tokenlist token
              | token 
              ;

token :    //// put first token in language here

//// put all your tokens here and individual actions 
//// DO NOT DO THE C- GRAMMAR (this is a test program) 
//// the grammar for assignment 1 is super simple

%%

//// any functions for main here

int main(int argc, char *argv[]) 
{

////  some of your stuff here

    yyparse();

    return 0;
}
