%{
#include <stdlib.h>
// must come before parser.tab.h because it refers to this datatype
#include "scanType.h"     // shared token value struct
#include "parser.tab.h"     // token defs

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
        yylval.tokenData->nvalue = atof(svalue); 
        break;
    case ID:
         yylval.tokenData->svalue = strdup(svalue);         
         break;
    case BOOLTRUE:
        yylval.tokenData->nvalue = 1; 
    case BOOLFALSE:
        yylval.tokenData->nvalue = 0; 
    }
    // return token class
    return tokenClass;
}

%}

%option noyywrap

%%
"quit"|"stop"|"exit"    { return setValue(line, QUIT, yytext); }
[/]{2}[a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/]*[\n]                  ;  // ignore comments
if                                      { return setValue(line, yytext[0], yytext); }
or                                      { return setValue(line, yytext[0], yytext); }
and                                     { return setValue(line, yytext[0], yytext); }
else                                    { return setValue(line, yytext[0], yytext); }
with                                    { return setValue(line, yytext[0], yytext); }
int                                     { return setValue(line, yytext[0], yytext); }
str                                     { return setValue(line, yytext[0], yytext); }
bool                                  { return setValue(line, yytext[0], yytext); }
then                                  { return setValue(line, yytext[0], yytext); }
by                                  { return setValue(line, yytext[0], yytext); }
do                                  { return setValue(line, yytext[0], yytext); }
break                                  { return setValue(line, yytext[0], yytext); }
static                                  { return setValue(line, yytext[0], yytext); }
char                                  { return setValue(line, yytext[0], yytext); }
true                                  { return setValue(line, yytext[0], yytext); }
false                                 { return setValue(line, yytext[0], yytext); }
for                                 { return setValue(line, yytext[0], yytext); }
to                                { return setValue(line, yytext[0], yytext); }
return                                 { return setValue(line, yytext[0], yytext); }

[=]{2}                                  { return setValue(line, yytext[0], yytext); }
['][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\\'\"][']                  { return setValue(line, CHARCONST, yytext); }
["][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\]*["]                      { return setValue(line, STRINGCONST, yytext); }
[a-zA-Z][a-zA-Z0-9]*                    { return setValue(line, ID, yytext); }
[0-9]*                                  { return setValue(line, NUMCONST, yytext); }

[\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/]      { return setValue(line, Character, yytext); }
[ \t]                                 ;  // white space
\n                                      { line++; return setValue(line, yytext[0], yytext); }
.+                                       { return setValue(line, yytext[0], yytext); }


[0-9]                   { return setValue(line, Digit, yytext); }
[a-zA-Z]                   { return setValue(line, Letter, yytext); }
[0-9]|[a-zA-Z]  { return setValue(line, Letdig, yytext); }
%%

