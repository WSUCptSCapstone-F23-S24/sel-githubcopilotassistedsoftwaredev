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
    case NUMCONST:
        yylval.tokenData->nvalue = atof(svalue); 
        break;
    case NOTYPE:
        yylval.tokenData->svalue = strdup(svalue);         
        break;
    }
    // return token class
    return tokenClass;
}

%}

%option noyywrap

%%
"quit"|"stop"|"exit"    { return setValue(line, QUIT, yytext); }
[/]{2}[a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/]*[\n]                  ;  // ignore comments
if                                      { return setValue(line, NOTYPE, yytext); }
or                                      { return setValue(line, NOTYPE, yytext); }
and                                     { return setValue(line, NOTYPE, yytext); }
else                                    { return setValue(line, NOTYPE, yytext); }
with                                    { return setValue(line, NOTYPE, yytext); }
int                                     { return setValue(line, NOTYPE, yytext); }
str                                     { return setValue(line, NOTYPE, yytext); }
bool                                  { return setValue(line, NOTYPE, yytext); }
then                                  { return setValue(line, NOTYPE, yytext); }
by                                  { return setValue(line, NOTYPE, yytext); }
do                                  { return setValue(line, NOTYPE, yytext); }
break                                  { return setValue(line, NOTYPE, yytext); }
static                                  { return setValue(line, NOTYPE, yytext); }
char                                  { return setValue(line, NOTYPE, yytext); }
true                                  { return setValue(line, NOTYPE, yytext); }
false                                 { return setValue(line, NOTYPE, yytext); }
for                                 { return setValue(line, NOTYPE, yytext); }
to                                { return setValue(line, NOTYPE, yytext); }
return                                 { return setValue(line, NOTYPE, yytext); }

[=]{2}                                  { return setValue(line, NOTYPE, yytext); }
['][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\\'\"][']                  { return setValue(line, CHARCONST, yytext); }
["][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\]*["]                      { return setValue(line, STRINGCONST, yytext); }
[a-zA-Z][a-zA-Z0-9]*                    { return setValue(line, ID, yytext); }
[0-9]*                                  { return setValue(line, NUMCONST, yytext); }


[\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/]      { return setValue(line, ID, yytext); }
[ \t]                                 ;  // white space
\n                                      { line++; return 0; }
.                       { return setValue(line, NOTYPE, yytext); }
.+                                       { return setValue(line, NOTYPE, yytext); }



[0-9]                   { return setValue(line, NOTYPE, yytext); }
[a-zA-Z]                   { return setValue(line, NOTYPE, yytext); }
[0-9]|[a-zA-Z]  { return setValue(line, NOTYPE, yytext); }


%%

