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
%token COMMA COLON SEMICOLON 
%token IF THEN ELSE WHILE DO FOR TO BY RETURN BREAK
%token INT BOOL CHAR STATIC
%token ADD SUBTRACT MULTIPLY DIVIDE MOD QUEST
%token AND OR NOT 
%token EQ NEQ LT LE GT GE ASSIGN MIN MAX
%token ADDEQ SUBEQ MULEQ DIVEQ INC DEC
%token ID NUMCONST CHARCONST STRINGCONST TRUE FALSE




%%

// 1
program: decList
    ;

// 2
decList: decList decl
    | decl
    ;

// 3
decl: varDecl
    | funcDecl
    ;

// 4
varDecl: typeSpec varDeclList SEMICOLON
    ;

// 5
scopedVarDecl: STATIC typeSpec varDeclList SEMICOLON
    | typeSpec varDeclList SEMICOLON
    ;

// 6 
varDeclList: varDeclList COMMA varDeclInit
    | varDeclInit
    ;

// 7
varDeclInit: varDeclId 
    | varDeclId COLON simpleExp
    ;

// 8 
varDeclId: ID
    | ID LBRACKET NUMCONST RBRACKET

// 9
typeSpec: INT
    | BOOL
    | CHAR
    ;

// 10
funcDecl: typeSpec ID LPAREN parms RPAREN stmt
    | ID LPAREN parms RPAREN stmt
    ;

// 11 
parms: parmList 
    | 
    ;

// 12
parmList: parmList SEMICOLON parmTypeList
    | parmTypeList
    ;

// 13
parmTypeList: typeSpec parmIdList
    ;

// 14
parmIdList: parmIdList COMMA parmId 
    | parmId
    ;

// 15
parmId: ID | ID LBRACKET RBRACKET
    ;

// 16
stmt: matched  
    | unmatched
    ;

matched: IF exp THEN matched ELSE matched
    | otherStmts
    ;

unmatched: IF exp THEN stmt
    | IF exp THEN matched ELSE unmatched
    ;

otherStmts: expStmt
    | compoundStmt
    | iterStmt
    | returnStmt
    | breakStmt
    ;
    
// 17
expStmt: exp SEMICOLON
    | SEMICOLON
    ;

// 18
compoundStmt: LBRACE localDecls stmtList RBRACE
    ;

// 19
localDecls: localDecls scopedVarDecl 
    | 
    ;  

// 20
stmtList: stmtList stmt
    | 
    ;

// 22 
iterStmt: WHILE simpleExp DO stmt
    | FOR ID ASSIGN iterRange DO stmt
    ;

// 23
iterRange: simpleExp TO simpleExp
    | simpleExp TO simpleExp BY simpleExp
    ;

// 24
returnStmt: RETURN SEMICOLON
    | RETURN exp SEMICOLON
    ;

// 25
breakStmt: BREAK SEMICOLON
    ;

// 26
exp: mutable ASSIGN exp
    | mutable ADDEQ exp
    | mutable SUBEQ exp
    | mutable MULEQ exp
    | mutable DIVEQ exp
    | mutable INC
    | mutable DEC
    | simpleExp
    ;

// 27
simpleExp: simpleExp OR andExp
    | andExp
    ;

// 28
andExp: andExp AND unaryRelExp
    | unaryRelExp
    ;  

// 29
unaryRelExp: NOT unaryRelExp
    | relExp
    ;

// 30
relExp: minmaxExp relop minmaxExp
    | minmaxExp
    ;

// 31
relop: LE
    | LT
    | GT
    | GE
    | EQ
    | NEQ
    ;

// 32
minmaxExp: minmaxExp minmaxOp sumExp
    | sumExp
    ;

// 33 
minmaxOp: MIN
    | MAX
    ;

// 34
sumExp: sumExp sumOp mulExp
    | mulExp
    ;

// 35
sumOp: ADD
    | SUBTRACT
    ;

// 36
mulExp: mulExp mulOp unaryExp
    | unaryExp
    ;

// 37
mulOp: MULTIPLY
    | DIVIDE
    | MOD
    ;

// 38
unaryExp: unaryOp unaryExp
    | factor
    ;

// 39
unaryOp: SUBTRACT
    | MULTIPLY
    | QUEST
    ;

// 40
factor: immutable
    | mutable
    ;

// 41
mutable: ID
    | ID LBRACKET exp RBRACKET
    ;

// 42
immutable: LPAREN exp RPAREN
    | call
    | constant
    ;

// 43
call: ID LPAREN args RPAREN
    ;

// 44
args: argList
    |
    ;

// 45
argList: argList COMMA exp
    | exp
    ;

// 46
constant: NUMCONST
    | CHARCONST
    | STRINGCONST
    | TRUE
    | FALSE
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
