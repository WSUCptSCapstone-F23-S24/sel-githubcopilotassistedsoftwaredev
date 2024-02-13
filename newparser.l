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
    yylval.tokenData->svalue = strdup(svalue);

    // handle special conversions
    switch (tokenClass) {
    case NUMCONST:
        yylval.tokenData->nvalue = atof(svalue); 
        break;
    case STRINGCONST:
        yylval.tokenData->nvalue = strlen(strdup(svalue))-2;         
        break;
    case CHARCONST:
        yylval.tokenData->cvalue = strdup(svalue)[1];         
        break;
  
    }
    // return token class
    return tokenClass;
}

%}

//rule declarations
newline     \n
whitespace  [ \t]+
comments    [/]{2}[a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/ \t]*[\n]
charconst   ['][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\\'\"][']
numconst    [0-9]+
strconst    ["][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\]*["]
id          [a-zA-Z][a-zA-Z0-9]*


%option noyywrap

%%

{comments}  { line++;}  // ignore comments
"if"        { return setValue(line, IF, yytext); }
"or"        { return setValue(line, OR, yytext); }
"and"       { return setValue(line, AND, yytext); }
"else"      { return setValue(line, ELSE, yytext); }
"with"      { return setValue(line, WITH, yytext); }
"int"       { return setValue(line, INT, yytext); }
"str"       { return setValue(line, STR, yytext); }
"bool"      { return setValue(line, BOOL, yytext); }
"then"      { return setValue(line, THEN, yytext); }
"by"        { return setValue(line, BY, yytext); }
"do"        { return setValue(line, DO, yytext); }
"break"     { return setValue(line, BREAK, yytext); }
"static"    { return setValue(line, STATIC, yytext); }
"char"      { return setValue(line, CHAR, yytext); }
"true"      { return setValue(line, TRUE, yytext); }
"false"     { return setValue(line, FALSE, yytext); }
"for"       { return setValue(line, FOR, yytext); }
"to"        { return setValue(line, TO, yytext); }
"return"    { return setValue(line, RETURN, yytext); }
"until"     { return setValue(line, UNTIL, yytext); }
"not"       { return setValue(line, NOT, yytext); }
{charconst} { return setValue(line, CHARCONST, yytext); }
{strconst}  { return setValue(line, STRINGCONST, yytext); }
{id}        { return setValue(line, ID, yytext); }
{numconst}  { return setValue(line, NUMCONST, yytext); }
"%"         { return setValue(line, MOD, yytext); }{ return setValue(line, ASSIGN, yytext); }
[=]{2}      { return setValue(line, EQEQ, yytext); }
"!="        { return setValue(line, NOTEQ, yytext); }
"="         { return setValue(line, ASSIGN, yytext); }
"+"         { return setValue(line, PLUS, yytext); }
"++"        { return setValue(line, PLUSPLUS, yytext); }
"+="        { return setValue(line, PLUSEQ, yytext); }
"-"         { return setValue(line, MINUS, yytext); }
"--"        { return setValue(line, MINUSMINUS, yytext); }
"-="        { return setValue(line, MINUSEQ, yytext); }
"*"         { return setValue(line, TIMES, yytext); }
"*="        { return setValue(line, TIMESEQ, yytext); }
"/"         { return setValue(line, Divide, yytext); }
"/="        { return setValue(line, DIVEQ, yytext); }
"<"         { return setValue(line, LT, yytext); }
"<="        { return setValue(line, LTEQ, yytext); }
">"         { return setValue(line, GT, yytext); }
">="        { return setValue(line, GTEQ, yytext); }
"("         { return setValue(line, LPAREN, yytext); }{ return setValue(line, ASSIGN, yytext); }
")"         { return setValue(line, RPAREN, yytext); }
"{"         { return setValue(line, LCURLY, yytext); }   
"}"         { return setValue(line, RCURLY, yytext); }
"["         { return setValue(line, LBRACK, yytext); }   
"]"         { return setValue(line, RBRACK, yytext); }
":"         { return setValue(line, COLON, yytext); }
";"         { return setValue(line, SEMI, yytext); }
"?"         { return setValue(line, QUESTION, yytext); }
","         { return setValue(line, COMMA, yytext); }
{newline}   { line++;}
{whitespace};  // white space
. { fprintf(stderr, "Error(%d): Invalid or misplace input character: '%s'. Character Ignored.\n", line, yytext); }
<<EOF>>     {return EOF;}


%%

