%{ 
#include <stdio.h>
#include <stdlib.h>
#include "scanType.h"

#ifdef CPLUSPLUS
extern int yylex();
#endif

void yyerror(const char *msg)
{
      printf("ERROR(PARSER): %s\n", msg);
}

// variable storage
double vars[26];
%}

%union {
    TokenData *tokenData;
    double value;
}

// token specifies the token classes from the scanner
%token <tokenData> NUMBER ID QUIT

// type specifies the token classes used only in the parser
%type <value> expression term varornum statement
%%
statementlist : statement '\n' 
              | statement '\n' statementlist
              ;

statement : ID '=' statement       { vars[$1->idValue] = $3; $$=$3; }  // NOTE assign not expression
      | expression              { printf("ANS: %f\n", $1);  }
          | QUIT                    { exit(0); }
          ;

expression: expression '+' term     { $$ = $1 + $3; }
          | expression '-' term     { $$ = $1 - $3; }
          | term                    { $$ = $1; }
          ;

term : term '*' varornum            { $$ = $1 * $3; }
     | term '/' varornum            { if ($3==0) {
                                      printf("ERROR: Divide %f by zero\n", $1);
                                  }   
                                      else {
                                      $$ = $1 / $3; 
                                  }
                                }
     | varornum                     { $$ = $1; }
     ;

varornum : NUMBER                   { $$ = $1->numValue; }
     | ID                       { $$ = vars[$1->idValue]; }
     | '(' expression ')'       { $$ = $2; }
         | '-' varornum             { $$ = -$2; }  // unary minus
         ;

%%

int main()
{
        int i;
//        yydebug=1;

        for (i=0; i<26; i++) vars[i] = 0.0;
        yyparse();   // call the parser

        return 0;
}
