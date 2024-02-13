%{ 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "scanType.h"
#include "ourgetopt.h"

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

// 
//  UTILS
// 

//TreeNode *addSibling(TreeNode *t, TreeNode *s)
//{
//        return;
//}


//void setType(TreeNode *t, ExpType type, bool isStatic)
//{
//        return;
//}
%}
// these types here will appear in the parser.tab.h!!!  So the includes for them
// MUST come before parser.tab.h!  You may have other types in here if you like
%union {
    TokenData *tokenData;
    //TreeNode *tree;
}
//// your %token statements defining token classes
%token IF THEN ELSE WHILE DO FOR TO BY RETURN BREAK OR AND NOT STATIC BOOL CHAR INT
%token ID NUMCONST CHARCONST STRINGCONST TRUE FALSE ASSIGN EQ LT PLUS LTEQ GT GTEQ
%token MINUS TIMES OVER LPAREN RPAREN SEMI COMMA COLON ERROR LBRACK RBRACK NOTHING
%token LCURLY RCURLY PLUSEQ MINUSEQ TIMESEQ DIVEQ PLUSPLUS MINUSMINUS EQEQ NOTEQ
%token SEMIGT SEMILT MOD QUESTION DIVIDE END
//%type <tree> ...   // nonterminals
//%token <tokenData> ...  // terminals and maybe some nonterminals

%%
/* Grammar for C- */

program     : declList
            ;
declList    : declList decl
            | decl
            ;
decl        : varDecl
            | funDecl
            ;
varDecl     : typeSpec varDeclList SEMI
            ;
scopedVarDecl : STATIC typeSpec varDeclList SEMI
              | typeSpec varDeclList SEMI
              ;
varDeclList : varDeclList COMMA varDeclInit
            | varDeclInit
            ;
varDeclInit : varDeclId
            | varDeclId COLON simpleExp
            ;
varDeclId   : ID
            | ID LBRACK NUMCONST RBRACK
            ;
typeSpec    : INT
            | BOOL
            | CHAR
            ;
funDecl     : typeSpec ID LPAREN parms RPAREN stmt
            | ID LPAREN parms RPAREN stmt
            ;
parms       : parmList
            | NOTHING
            ;
parmList    : parmList SEMI parmTypeList
            | parmTypeList
            ;
parmTypeList : typeSpec parmIdList
             ;
parmIdList  : parmIdList COMMA parmId 
            | parmId 
            ;
parmId      : ID
            | ID LBRACK RBRACK
            ;
stmt        : expStmt
            | compoundStmt
            | selectStmt
            | iterStmt
            | returnStmt
            | breakStmt
            ;
expStmt     : exp SEMI
            | SEMI
            ;
compoundStmt : LCURLY localDecls stmtList RCURLY
             ;
localDecls  : localDecls scopedVarDecl
            | NOTHING
            ;
stmtList    : stmtList stmt
            | NOTHING
            ;
selectStmt  : IF simpleExp THEN stmt END
            | IF simpleExp THEN stmt ELSE stmt END
            ;
iterStmt    : WHILE simpleExp DO stmt END
            | FOR ID EQ iterRange DO stmt
            ;
iterRange   : simpleExp TO simpleExp
            | simpleExp TO simpleExp BY simpleExp
            ;
returnStmt  : RETURN SEMI
            | RETURN exp SEMI
            ;
breakStmt   : BREAK SEMI
            ;
exp         : mutable EQ exp
            | mutable PLUSEQ exp
            | mutable MINUSEQ exp
            | mutable TIMESEQ exp
            | mutable DIVEQ exp
            | mutable PLUSPLUS
            | mutable MINUSMINUS
            | simpleExp
            ;
simpleExp   : simpleExp OR andExp
            | andExp
            ;
andExp      : andExp AND unaryRelExp
            | unaryRelExp
            ;
unaryRelExp : NOT unaryRelExp
            | relExp 
            ;
relExp      : minmaxExp relop minmaxExp
            | minmaxExp
            ;
relop       : LTEQ
            | LT
            | GT
            | GTEQ
            | EQEQ
            | NOTEQ
            ;
minmaxExp   : minmaxExp minmaxop sumExp
            | sumExp
            ;
minmaxop    : SEMIGT
            | SEMILT
            ;
sumExp      : sumExp sumop mulExp
            | mulExp
            ;
sumop       : PLUS
            | MINUS
            ;
mulExp      : mulExp mulop unaryExp
            | unaryExp
            ;
mulop       : TIMES    
            | DIVIDE    
            | MOD       
            ;
unaryExp    : unaryop unaryExp
            | factor
            ;
unaryop     : MINUS
            | TIMES
            | QUESTION
            ;
factor      : immutable
            | mutable
            ;
mutable     : ID
            | ID LBRACK exp RBRACK
            ;
immutable   : RPAREN exp LPAREN
            | call
            | constant
            ;
call        : ID RPAREN args LPAREN
            ;
args        : argList
            | NOTHING
            ;
argList     : argList COMMA exp
            | exp
            ;
constant    : NUMCONST
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
    extern char *optarg;
    extern int optind;
    int pflg, dflg;
    int errflg;
    yydebug = 0;
    pflg = dflg= 0;
    char *filename;
    
    while (1)
    {
        /// hunt for a string of options
        while ((c = ourGetopt(argc, argv, (char *)"pd")) != EOF)
            switch (c) 
            {
                case 'd': 
                    yydebug=1;
                    break;
                case 'p': 
                    //printSyntaxTree=true;
                    break;
                //default:
                //    usage();
                //    exit(1);
            }


        // pick off a nonoption
        // pick off a nonoption
        if (optind<argc) 
        {
            filename = strdup(argv[optind]);
            optind++;
        }
        else 
        {
            break;
        }
    }

    ////  some of your stuff here
    if (filename != NULL)
    {
        if ((yyin = fopen(filename, "r"))) 
        {
            // file open successful
            yyparse();
            fclose(yyin);
        }
        else 
        {
            // failed to open file
            printf("ERROR: failed to open \'%s\'\n", filename);
            exit(1);
        }         
    }
    else{
        yyparse();
    }
    //if (printSyntaxTree) printTree(stdout, syntaxTree, false, false);
    return 0;
}