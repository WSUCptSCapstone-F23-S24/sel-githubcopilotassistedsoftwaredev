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
    case BOOLCONST:
        yylval.tokenData->svalue = strdup(svalue);
        if (strcmp(yylval.tokenData->svalue,"true") == 0) 
            yylval.tokenData->nvalue = 1;
        else
            yylval.tokenData->nvalue = 0; 
        break;
    case NUMCONST:
        yylval.tokenData->nvalue = atof(svalue); 
        break;
    case STRINGCONST:
        yylval.tokenData->svalue = strdup(svalue);
        yylval.tokenData->nvalue = strlen(strdup(svalue))-2;         
        break;
    case CHARCONST:
        yylval.tokenData->cvalue = strdup(svalue)[1];         
        break;
    case KEYWORD:
        yylval.tokenData->cvalue = strdup(svalue)[1];         
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
if                                      { return setValue(line, KEYWORD, yytext); }
or                                      { return setValue(line, KEYWORD, yytext); }
and                                     { return setValue(line, KEYWORD, yytext); }
else                                    { return setValue(line, KEYWORD, yytext); }
with                                    { return setValue(line, KEYWORD, yytext); }
int                                     { return setValue(line, KEYWORD, yytext); }
str                                     { return setValue(line, KEYWORD, yytext); }
bool                                  { return setValue(line, KEYWORD, yytext); }
then                                  { return setValue(line, KEYWORD, yytext); }
by                                  { return setValue(line, KEYWORD, yytext); }
do                                  { return setValue(line, KEYWORD, yytext); }
break                                  { return setValue(line, KEYWORD, yytext); }
static                                  { return setValue(line, KEYWORD, yytext); }
char                                  { return setValue(line, KEYWORD, yytext); }
true                                  { return setValue(line, BOOLCONST, yytext); }
false                                 { return setValue(line, BOOLCONST, yytext); }
for                                 { return setValue(line, KEYWORD, yytext); }
to                                { return setValue(line, KEYWORD, yytext); }
return                                 { return setValue(line, KEYWORD, yytext); }

[=]{2}                                  { return setValue(line, KEYWORD, yytext); }
['][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\\'\"][']                  { return setValue(line, CHARCONST, yytext); }
["][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\]*["]                      { return setValue(line, STRINGCONST, yytext); }
[a-zA-Z][a-zA-Z0-9]*                    { return setValue(line, ID, yytext); }
[0-9]*                                  { return setValue(line, NUMCONST, yytext); }


[\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/]      { return setValue(line, ID, yytext); }
[ \t]                                 ;  // white space
\n                                      { line++; return 0; }
.                       { return setValue(line, yytext[0], yytext); }


%%

