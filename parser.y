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
%token <tokenData> NUMBER ID BOOLFALSE BOOLTRUE QUIT CHARCONST NUMCONST STRINGCONST NOTYPE
%type <tokenData> token

%%
tokenlist: tokenlist token
         | token
         ;

//// put all your tokens here and individual actions 
//// DO NOT DO THE C- GRAMMAR (this is a test program) 
//// the grammar for assignment 1 is super simple
token: NUMBER { printf("Line %d Token: NUMBER Value: %f\n", $1->linenum, $1->nvalue); }
     | ID { printf("Line %d Token: ID Value: %s\n", $1->linenum, $1->svalue); }
     | BOOLFALSE { printf("Line %d Token: BOOLFALSE\n", $1->linenum); }
     | BOOLTRUE { printf("Line %d Token: BOOLTRUE\n", $1->linenum); }
     | QUIT { printf("Line %d Token: QUIT\n", $1->linenum); exit(0); }
     | CHARCONST { printf("Line %d Token: CHARCONST Value: %c\n", $1->linenum, $1->cvalue); }
     | NUMCONST { printf("Line %d Token: NUMCONST Value: %d\n", $1->linenum, $1->nvalue); }
     | STRINGCONST { printf("Line %d Token: STRINGCONST Value: %s\n", $1->linenum, $1->svalue); }
     | NOTYPE { printf("Line %d Token: %s\n", $1->linenum, $1->svalue); }
     ;
%%

//// any functions for main here

int main(int argc, char *argv[]) 
{
    ////  some of your stuff here
    //yydebug = 1;
    while(1)
        yyparse(); // Start the parsing process

    return 0;
}
