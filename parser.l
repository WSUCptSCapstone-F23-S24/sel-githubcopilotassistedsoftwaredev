%{
#include <stdlib.h> 
#include <ctype.h>
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
        if(strcmp(svalue, "==") == 0)
            yylval.tokenData->svalue = strdup("eq");
        else if(strcmp(svalue, "+=") == 0)
            yylval.tokenData->svalue = strdup("addass");
        else
            yylval.tokenData->svalue = strdup(svalue);
        for(char *p = yylval.tokenData->svalue; *p; p++) {
            *p = toupper((unsigned char)*p);
        }
        break;
    case SYMBOL:
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
[/]{2}[a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/ \t]*[\n]                  {line++;}  // ignore comments
"if"|"or"|"and"|"else"|"with"|"int"|"str"|"bool"|"then"|"by"|"do"|"break"  { return setValue(line, KEYWORD, yytext); }
"static"|"char"|"true"|"false"|"for"|"to"|"return"|"str"|[=]{2}|"+="    { return setValue(line, KEYWORD, yytext); }
['][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\\'\"][']                  { return setValue(line, CHARCONST, yytext); }
["][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\]*["]                      { return setValue(line, STRINGCONST, yytext); }
[a-zA-Z][a-zA-Z0-9]*                    { return setValue(line, ID, yytext); }
[0-9]+                                  { return setValue(line, NUMCONST, yytext); }


[\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/]      { return setValue(line, SYMBOL, yytext); }
[ \t]                                 ;  // white space
\n                                      { line++;}
. { fprintf(stderr, "Error(%d): Invalid or misplace input character: '%s'. Character Ignored.\n", line, yytext); }
<<EOF>> {return EOF;}


%%

