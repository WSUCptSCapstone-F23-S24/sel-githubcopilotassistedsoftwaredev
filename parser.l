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
        case BOOLCONST:
            if (strcmp(yylval.tokenData->svalue,"true") == 0) 
                yylval.tokenData->nvalue = 1;
            else
                yylval.tokenData->nvalue = 0; 
            break;
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
COMMENT        \/\/.*
ID             [a-zA-Z][a-zA-Z0-9]*
NUMCONST       [0-9]+
CHARCONST      ['][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\\'\"][']
STRINGCONST    ["][a-zA-Z0-9\%\*\(\)\-\{\}\[\]\:\;\<\>\?\,\/\\]*["]

LPAREN         "("
RPAREN         ")"
LBRACE         "{"
RBRACE         "}"
LBRACKET       "["
RBRACKET       "]"

COMMA          ","
COLON          ":"
SEMICOLON      ";"

IF             "if"
THEN           "then"
ELSE           "else"
WHILE          "while"
DO             "do"
FOR            "for"
TO             "to"
RETURN         "return"
BREAK          "break"

INT            "int"
VOID           "void"
BOOLCONST      "bool"

ADD            "+"
SUBTRACT       "-"
MULTIPLY       "*"
DIVIDE         "/"
MOD            "%"

AND            "and"
OR             "or"
NOT            "not"

EQ             "=="
NEQ            "!="
LT             "<"
LE             "<="
GT             ">"
GE             ">="
ASSIGN         "="

NEWLINE        "\n"
WHITESPACE     [ \t]+ 
ERROR          .


%option noyywrap

%%

{LPAREN}      { return setValue(line, LPAREN, yytext); }
{RPAREN}      { return setValue(line, RPAREN, yytext); }
{LBRACE}      { return setValue(line, LBRACE, yytext); }
{RBRACE}      { return setValue(line, RBRACE, yytext); }
{LBRACKET}    { return setValue(line, LBRACKET, yytext); }
{RBRACKET}    { return setValue(line, RBRACKET, yytext); }

{COMMA}       { return setValue(line, COMMA, yytext); }
{COLON}       { return setValue(line, COLON, yytext); }
{SEMICOLON}   { return setValue(line, SEMICOLON, yytext); }

{IF}          { return setValue(line, IF, yytext); }
{THEN}        { return setValue(line, THEN, yytext); }
{ELSE}        { return setValue(line, ELSE, yytext); }
{WHILE}       { return setValue(line, WHILE, yytext); }
{DO}          { return setValue(line, DO, yytext); }
{FOR}         { return setValue(line, FOR, yytext); }
{TO}          { return setValue(line, TO, yytext); }
{RETURN}      { return setValue(line, RETURN, yytext); }
{BREAK}       { return setValue(line, BREAK, yytext); }

{INT}         { return setValue(line, INT, yytext); }
{VOID}        { return setValue(line, VOID, yytext); }
{BOOLCONST}   { return setValue(line, BOOLCONST, yytext); }

{ADD}         { return setValue(line, ADD, yytext); }
{SUBTRACT}    { return setValue(line, SUBTRACT, yytext); }
{MULTIPLY}    { return setValue(line, MULTIPLY, yytext); }
{DIVIDE}      { return setValue(line, DIVIDE, yytext); }
{MOD}         { return setValue(line, MOD, yytext); }

{AND}         { return setValue(line, AND, yytext); }
{OR}          { return setValue(line, OR, yytext); }
{NOT}         { return setValue(line, NOT, yytext); }

{EQ}          { return setValue(line, EQ, yytext); }
{NEQ}         { return setValue(line, NEQ, yytext); }
{LT}          { return setValue(line, LT, yytext); }
{LE}          { return setValue(line, LE, yytext); }
{GT}          { return setValue(line, GT, yytext); }
{GE}          { return setValue(line, GE, yytext); }
{ASSIGN}      { return setValue(line, ASSIGN, yytext); }

{ID}          { return setValue(line, ID, yytext); }
{NUMCONST}    { return setValue(line, NUMCONST, yytext); }
{CHARCONST}   { return setValue(line, CHARCONST, yytext); }
{STRINGCONST} { return setValue(line, STRINGCONST, yytext); }

{NEWLINE}     { line++; }
{WHITESPACE}  {} // ignore whitespace
{COMMENT}     {} // ignore comments
<<EOF>>       { return setValue(line, EOF, yytext); }
{ERROR}       { fprintf(stderr, "Error(%d): Invalid or misplaced input character: '%s'. Character Ignored.\n", line, yytext); }

%%
