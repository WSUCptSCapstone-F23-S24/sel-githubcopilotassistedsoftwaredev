%{
#include <stdlib.h>
// must come before calc.tab.h because it refers to this datatype
#include "scanType.h"     // shared token value struct
#include "calc.tab.h"     // token defs

// extern void yyerror(const char *msg);
//char *lastToken=(char *)"";
static int line=1;

static int setValue(int linenum, int tokenClass, char *svalue)
{
    // create and handle default data storage
    yylval.tokenData = new TokenData;
    yylval.tokenData->tokenclass = tokenClass;
    yylval.tokenData->linenum = linenum;
    yylval.tokenData->tokenstr = strdup(svalue);

    // handle special conversions
    switch (tokenClass) {
    case NUMBER:
        yylval.tokenData->numValue = atof(svalue); 
        break;
    case ID:
         yylval.tokenData->idValue = svalue[0] - 'a';         
         break;
    }

    // return token class
    return tokenClass;
}

%}

%option noyywrap

%%
"quit"|"stop"|"exit"    { return setValue(line, QUIT, yytext); }
"pi"                    { return setValue(line, NUMBER, (char *)"3.14159265358979323846264338"); }
[0-9]+|[0-9]*\.[0-9]+   { return setValue(line, NUMBER, yytext); }
[a-z]                   { return setValue(line, ID, yytext); }
[ \t]                   ;  // white space
\n                      { line++; return setValue(line, yytext[0], yytext); }
.                       { return setValue(line, yytext[0], yytext); }
%%