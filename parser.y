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
extern int yylex();
void yyerror(const char *msg) {
    fprintf(stderr, "Error(PARSER): Invalid or misplace input character: '%s'. Character Ignored.\n", msg);
}

%}
//// your %union statement
%union {
    TokenData *tokenData;
}
//// your %token statements defining token classes
%token <tokenData> NUMBER ID BOOLCONST QUIT CHARCONST NUMCONST STRINGCONST KEYWORD SYMBOL
%type <tokenData> token

%%
tokenlist: tokenlist token
         | token
         ;

//// put all your tokens here and individual actions 
//// DO NOT DO THE C- GRAMMAR (this is a test program) 
//// the grammar for assignment 1 is super simple
token: ID { printf("Line %d Token: ID Value: %s\n", $1->linenum, $1->svalue); }
     | BOOLCONST { printf("Line %d Token: BOOLCONST Value: %d Input: %s\n", $1->linenum, $1->nvalue, $1->svalue); }
     | QUIT { printf("Line %d Token: QUIT\n", $1->linenum); exit(0); }
     | CHARCONST { printf("Line %d Token: CHARCONST Value: %c\n", $1->linenum, $1->cvalue); }
     | NUMCONST { printf("Line %d Token: NUMCONST Value: %d  Input: %d\n", $1->linenum, $1->nvalue, $1->nvalue); }
     | STRINGCONST { printf("Line %d Token: STRINGCONST Value: %s Len: %d Input: %s\n", $1->linenum, $1->svalue, $1->nvalue, $1->svalue); }
     | KEYWORD { printf("Line %d Token: %s\n", $1->linenum, $1->svalue); }
     | SYMBOL { printf("Line %d Token: %s\n", $1->linenum, $1->svalue); }
     ;
%%

//// any functions for main here

int main(int argc, char *argv[]) 
{
    ////  some of your stuff here
    if (argc > 1) {
        if ((yyin = fopen(argv[1], "r"))) {
            // file open successful
        }
        else {
            // failed to open file
            printf("ERROR: failed to open \'%s\'\n", argv[1]);
            exit(1);
        }
    }
    //yydebug = 1;
    yyparse();

    return 0;
}
