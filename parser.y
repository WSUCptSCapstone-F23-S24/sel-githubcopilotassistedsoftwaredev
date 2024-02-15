%{ 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "scanType.h"
#include "ourGetopt.cpp"

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
extern int ourGetopt( int, char **, char*);

%}
//// your %union statement
%union {
    TokenData *tokenData;
}

//// your %token statements defining token classes
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token COMMA COLON SEMICOLON NOTHING
%token IF THEN ELSE WHILE DO FOR TO RETURN BREAK
%token INT VOID BOOLCONST 
%token ADD SUBTRACT MULTIPLY DIVIDE MOD
%token AND OR NOT 
%token EQ NEQ LT LE GT GE ASSIGN
%token ID NUMCONST CHARCONST STRINGCONST
%token END_OF_FILE




%%

//// your grammar rules for C- language
program: declarationList
    ;

declarationList: declarationList declaration
    | declaration
    ;

declaration: varDeclaration
    | funDeclaration
    ;

varDeclaration: typeSpecifier ID SEMICOLON
    | typeSpecifier ID LBRACKET NUMCONST RBRACKET SEMICOLON
    ;

typeSpecifier: INT
    | VOID
    | BOOLCONST
    | STRINGCONST
    | CHARCONST
    ;

funDeclaration: typeSpecifier ID LPAREN params RPAREN compoundStmt
    | ID LPAREN params RPAREN compoundStmt
    ;

params: paramList
    | NOTHING
    ;

paramList: paramList COMMA param
    | param
    ;   

param: typeSpecifier ID
    | typeSpecifier ID LBRACKET RBRACKET
    ;

compoundStmt: LBRACE localDeclarations statementList RBRACE
    ;

localDeclarations: localDeclarations varDeclaration
    | NOTHING
    ; 

statementList: statementList statement
    | NOTHING
    ;

statement: expressionStmt
    | compoundStmt
    | selectionStmt
    | iterationStmt
    | returnStmt
    | breakStmt
    ;   

expressionStmt: expression SEMICOLON
    | SEMICOLON
    ;

selectionStmt: IF LPAREN expression RPAREN statement ELSE statement
    | IF LPAREN expression RPAREN statement
    ;

iterationStmt: WHILE LPAREN expression RPAREN statement
    | FOR LPAREN expressionStmt expressionStmt expression RPAREN statement
    ;

returnStmt: RETURN SEMICOLON
    | RETURN expression SEMICOLON
    ;

breakStmt: BREAK SEMICOLON
    ;

expression: var ASSIGN expression
    | simpleExpression
    ;

var: ID
    | ID LBRACKET expression RBRACKET
    ;

simpleExpression: additiveExpression relop additiveExpression
    | additiveExpression
    ;

relop: LT
    | GT
    | LE
    | GE
    | EQ
    | NEQ
    ;

additiveExpression: additiveExpression addop term
    | term
    ;

addop: ADD
    | SUBTRACT
    ;

term: term mulop factor
    | factor
    ;

mulop: MULTIPLY
    | DIVIDE
    | MOD
    ;

factor: LPAREN expression RPAREN
    | var
    | call
    | NUMCONST
    | CHARCONST
    | BOOLCONST
    | STRINGCONST
    | NOT factor
    | SUBTRACT factor
    ;

call: ID LPAREN args RPAREN
    ;

args: argList
    | NOTHING
    ;

argList: argList COMMA expression
    | expression
    ;





%%

//// any functions for main here


int main(int argc, char *argv[]) 
{
    int c;
    bool printTreeFlag = false;
    
    // parse command line options
    while ((c = ourGetopt(argc, argv, (char *)"pd")) != -1) {
        switch (c) {
        case	'p':
            printTreeFlag = true;
            break;
        case	'd':
            yydebug = 1;
            break;
        }
    }

    // open file or stdin
    if (argc == optind + 1)
    {
        if ((yyin = fopen(argv[optind], "r")))
        {
            // file open successful
            yyparse();
            fclose(yyin);
        }
        else
        {
            // failed to open file
            printf("ERROR: failed to open \'%s\'\n", argv[optind]);
            exit(1);
        }
    }
    else
    {
        yyparse();
    }
    //yydebug = 1;

    if (printTreeFlag) printf("printTreeFlag=True\n");
    else printf("printTreeFlag=False\n");
    
    return 0;
}
