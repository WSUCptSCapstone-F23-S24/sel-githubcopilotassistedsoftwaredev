%{ 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "scanType.h"
#include "ourgetopt.h"
#include "TreeUtils.h"
#include "treeNodes.h"
extern int yylex();
extern FILE *yyin;
extern int yydebug;
extern int line;

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
// the syntax tree goes here
TreeNode *syntaxTree;
%}
// these types here will appear in the parser.tab.h!!!  So the includes for them
// MUST come before parser.tab.h!  You may have other types in here if you like
%union {
    TokenData *tokenData;
    TreeNode *tree;
}
//// your %token statements defining token classes
//// your %token statements defining token classes
%type <tree> program declList decl varDecl scopedVarDecl varDeclList varDeclInit varDeclId typeSpec funDecl parms parmList parmTypeList parmIdList parmId stmt expStmt compoundStmt localDecls stmtList selectStmt iterStmt iterRange returnStmt breakStmt exp simpleExp andExp unaryRelExp relExp minmaxExp sumExp mulExp unaryExp factor mutable immutable call args argList constant relop  minmaxop sumop mulop unaryop 
%token <tokenData> IF THEN ELSE WHILE DO FOR TO BY RETURN BREAK OR AND NOT STATIC BOOL CHAR INT
%token <tokenData> ID NUMCONST CHARCONST STRINGCONST TRUE FALSE EQ LT PLUS LTEQ GT GTEQ
%token <tokenData> MINUS TIMES OVER LPAREN RPAREN SEMI COMMA COLON ERROR LBRACK RBRACK
%token <tokenData> LCURLY RCURLY PLUSEQ MINUSEQ TIMESEQ DIVEQ PLUSPLUS MINUSMINUS EQEQ NOTEQ
%token <tokenData> SEMIGT SEMILT MOD QUESTION DIVIDE

//%token <tokenData> ...  // terminals and maybe some nonterminals

%%
/* Grammar for C- */

program     : declList
                {  }
            ;
declList    : declList decl { 
                $$ = newDeclNode(VarK, line);
                $$->child[0] = $1;
                }
            | decl
                {
                    $$ = $1;
                }
            ;
decl        : varDecl
                {
                    $$ = $1;
                }
            | funDecl
                {
                    $$ = $1;
                }
            ;
varDecl     : typeSpec varDeclList SEMI 
                {
                    $$ = newDeclNode(VarK, line);
                    $$->child[0] = $1; 
                    $$->child[1] = $2; 
                }
            ;
scopedVarDecl : STATIC typeSpec varDeclList SEMI
                    {
                        $$ = newDeclNode(VarK, line);
                        $$->isStatic = 1; 
                        $$->child[0] = $2; 
                        $$->child[1] = $3; 
                    }
              | typeSpec varDeclList SEMI
                    {
                        $$ = newDeclNode(VarK, line);
                        $$->child[0] = $1; 
                    }
              ;
varDeclList : varDeclList COMMA varDeclInit
                {
                    $$ = newDeclNode(VarK, line);
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | varDeclInit
                {
                    $$ = newDeclNode(VarK, line);
                    $$->child[0] = $1;
                }
            ;
varDeclInit : varDeclId
                {
                    $$ = $1;
                }
            | varDeclId COLON simpleExp
                {
                    $$ = newDeclNode(VarK, line);
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            ;
varDeclId   : ID
                {
                    $$ = newDeclNode(VarK, line);
                    $$->attr.name = $1->svalue;
                         
                }
            | ID LBRACK NUMCONST RBRACK
                {
                    $$ = newDeclNode(VarK, line);
                    $$->attr.name = $1->svalue;
                    $$->isArray = 1;
                }
            ;
typeSpec    : INT 
                {
                    $$ = newDeclNode(VarK, line); // Is this going to be a decl or expr node??
                    $$->subkind.decl = ParamK;
                    $$->expType = Integer; // Not expression but used for type checking.
                }
            | BOOL 
                {
                    $$ = newDeclNode(VarK, line); // Is this going to be a decl or expr node??
                    $$->subkind.decl = ParamK;
                    $$->expType = Boolean; // Not expression but used for type checking.
                }
            | CHAR 
                {
                    $$ = newDeclNode(VarK, line); // Is this going to be a decl or expr node??
                    $$->subkind.decl = ParamK;
                    $$->expType = Char; // Not expression but used for type checking.
                }
            ;
funDecl     : typeSpec ID LPAREN parms RPAREN stmt
                {
                    $$ = newDeclNode(FuncK, line);
                    $$->attr.name = $2->svalue;
                    $$->child[0] = $1; 
                    $$->child[1] = $4; 
                    $$->child[2] = $6; 
                }
            | ID LPAREN parms RPAREN stmt
                {
                    $$ = newDeclNode(FuncK, line);
                    $$->attr.name = $1->svalue;
                    $$->expType = Void;  // Not expression but used for type checking.
                    $$->child[0] = $3; 
                    $$->child[1] = $5; 
                }
            ;
parms       : parmList { $$ = $1; }
            | /* empty */
                {
                    $$ = NULL; 
                }
            ;
parmList    : parmList SEMI parmTypeList
                {
                    $1->sibling = $3;
                }
            | parmTypeList
                {
                    $$ = $1;
                }
            ;
parmTypeList : typeSpec parmIdList
                    {
                        $$ = $2;
                        $2->expType = $1->expType;
                        // what to do now, sibling activities ?
                    }
             ;
parmIdList  : parmIdList COMMA parmId { $1->sibling = $3; }
            | parmId  { $$ = $1; }
            ;
parmId      : ID 
                {
                    $$ = newDeclNode(ParamK, line);
                    $$->attr.name = $1->svalue;
                    $$->expType = UndefinedType;
                }
            | ID LBRACK RBRACK
                {
                    $$ = newDeclNode(ParamK, line)
                    $$->attr.name = $1->svalue;
                    $$->expType = UndefinedType;
                    $$->isArray = 1;
                }
            ;
stmt        : expStmt { $$ = $1; } 
            | compoundStmt { $$ = $1; } 
            | selectStmt { $$ = $1; } 
            | iterStmt { $$ = $1; }
            | returnStmt { $$ = $1; }
            | breakStmt { $$ = $1; }
            ;
expStmt     : exp SEMI { $$ = $1; }
            | SEMI 
                { 
                    $$ = newStmtNode(NullK, line);
                }
            ;
compoundStmt : LCURLY localDecls stmtList RCURLY
                {
                    $$ = newStmtNode(CompoundK, line);
                    $$->expType = UndefinedType; // For type checking
                    $$->child[0] = $2;
                }
             ;
localDecls  : localDecls scopedVarDecl
                {
                    
                }
            | /* empty */
                {
                    //$$ = newDeclNode(VarK, line);
                    //$$.attr.op = Void;  // Could also be undefined ?
                    //$$.subkind.decl = // define the scope ?
                }
            ;
stmtList    : stmtList stmt
                {
                    $$ = $1;
                }
            | /* empty */
                {
                    //$$ = newStmtNode(NullK, line); 
                }
            ;
selectStmt  : IF simpleExp THEN stmt ELSE stmt
                    {
                        $$ = newStmtNode(IfK, line);
                        $$->child[0] = $2; 
                        $$->child[1] = $4; 
                        $$->child[2] = $6; 
                    }
            | IF simpleExp THEN stmt
                    {
                        $$ = newStmtNode(IfK, line);
                        $$->child[0] = $2; 
                        $$->child[1] = $4; 
                    }
            ;
iterStmt    : WHILE simpleExp DO stmt
                {
                    $$ = newStmtNode(WhileK, line);
                    $$->child[0] = $2; 
                    $$->child[1] = $4; 
                }
            | FOR ID EQ iterRange DO stmt
                {
                    $$ = newStmtNode(LoopK, line);
                    $$->attr.name = copyString($2->tokenstr); 
                    $$->child[0] = $4; 
                    $$->child[1] = $6; 
                }
            ;
iterRange   : simpleExp TO simpleExp
                {
                    $$ = newStmtNode(RangeK, line);
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | simpleExp TO simpleExp BY simpleExp
                {
                    $$ = newStmtNode(RangeK, line);
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                    $$->child[2] = $5; 
                }
            ;
returnStmt  : RETURN SEMI
                {
                    $$ = newStmtNode(ReturnK, line);
                }
            | RETURN exp SEMI
                {
                    $$ = newStmtNode(ReturnK, line);
                    $$->child[0] = $2; 
                }
            ;
breakStmt   : BREAK SEMI
                {
                    $$ = newStmtNode(BreakK, line);
                }
            ;
exp         : mutable EQ exp
                {
                    $$ = newExpNode(AssignK, line);
                    $$->attr.op = EQ;   // set token type (same as in bison)
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable PLUSEQ exp // opK
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = PLUSEQ;   // set token type (same as in bison)
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable MINUSEQ exp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = MINUSEQ;   // set token type (same as in bison)
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable TIMESEQ exp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = TIMESEQ;   // set token type (same as in bison)
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable DIVEQ exp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = DIVEQ;   // set token type (same as in bison)
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable PLUSPLUS
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = PLUSPLUS;   // set token type (same as in bison)
                    $$->child[0] = $1; 
                }
            | mutable MINUSMINUS
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = MINUSMINUS;   // set token type (same as in bison)
                    $$->child[0] = $1; 
                }
            | simpleExp { $$ = $1; }
            ;
simpleExp   : simpleExp OR andExp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = OR;   // set token type (same as in bison)
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | andExp
                {
                    $$ = $1;
                }
            ;
andExp      : andExp AND unaryRelExp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = AND;   // set token type (same as in bison)
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | unaryRelExp
                {
                    $$ = $1;
                }
            ;
unaryRelExp : NOT unaryRelExp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = NOT;   // set token type (same as in bison)
                    $$->child[0] = $2;
                }
            | relExp 
                {
                    $$ = $1;
                }
            ;
relExp      : minmaxExp relop minmaxExp
                {
                    $$ = newExpNode($2->subkind.exp, line); 
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | minmaxExp
                {
                    $$ = $1;
                }
            ;
relop       : LTEQ 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = LTEQ;   // set token type (same as in bison)
                }
            | LT 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = LT;   // set token type (same as in bison)
                }
            | GT 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = GT;   // set token type (same as in bison)
                }
            | GTEQ 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = GTEQ;   // set token type (same as in bison)
                }
            | EQEQ 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = EQEQ;   // set token type (same as in bison)
                }
            | NOTEQ 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = NOTEQ;   // set token type (same as in bison)
                }
            ;
minmaxExp   : minmaxExp minmaxop sumExp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = $2->attr.op; 
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | sumExp { $$ = $1; }
            ;
minmaxop    : SEMIGT 
                {
                    // MIN 
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = SEMIGT;
                }
            | SEMILT 
                {
                    // MAX
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = SEMILT;
                }
            ;
sumExp      : sumExp sumop mulExp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = $2->attr.op;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | mulExp { $$ = $1; }
            ;
sumop       : PLUS
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = PLUS;
                }
            | MINUS
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = MINUS;
                }
            ;
mulExp      : mulExp mulop unaryExp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = TIMES;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | unaryExp { $$ = $1; }
            ;
mulop       : TIMES 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = TIMES;
                }
            | DIVIDE
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = DIVIDE;
                }
            | MOD
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = MOD;
                }
            ;
unaryExp    : unaryop unaryExp
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = $1->attr.op;
                    $$->child[0] = $2;
                }
            | factor { $$ = $1; }
            ;
unaryop     : MINUS 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = MINUS;
                }
            | TIMES 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = TIMES;
                }
            | QUESTION 
                {
                    $$ = newExpNode(OpK, line);
                    $$->attr.op = QUESTION;
                }
            ;
factor      : immutable { $$ = $1; }
            | mutable { $$ = $1; }
            ;
mutable     : ID
                {
                    $$ = newExpNode(IdK, line);
                    $$->attr.name = $1->svalue;
                }
            | ID LBRACK exp RBRACK
                {
                    $$ = newExpNode(IdK, line);
                    $$->isArray = 1;
                    $$->attr.name = $1->svalue;
                    $$->child[0] = $3; 
                }
            ;
immutable   : LPAREN exp RPAREN
                {
                    $$ = $2; 
                }
            | call
                {
                    $$ = $1; 
                }
            | constant
                {
                    $$ = newExpNode(ConstantK, line);   
                }
            ;
call        : ID LPAREN args RPAREN
                {
                    $$ = newExpNode(CallK, line);
                    $$->attr.name = $1->svalue;
                    $$->child[0] = $3; 
                }
            ;
args        : argList { $$ = $1; }
            | /* empty */
                {
                    $$ = NULL; 
                }
            ;
argList     : argList COMMA exp
                {
                    $$ = $1;  // should this be a decl node ??
                    $$->child[0] = $3;
                }
            | exp
                {
                    $$ = newExpNode(CallK, line); 
                    $$->child[0] = $1;
                }
            ;
constant    : NUMCONST
                {
                    $$ = newExpNode(ConstantK, line);
                    $$->expType = Integer;
                    $$->attr.value = $1->nvalue;
                }
            | CHARCONST
                {
                    $$ = newExpNode(ConstantK, line);
                    $$->expType = Char;
                    $$->attr.cvalue = $1->cvalue;
                }
            | STRINGCONST
                {
                    $$ = newExpNode(ConstantK, line);
                    $$->expType = String;
                    $$->attr.string = $1->svalue;
                }
            | TRUE
                {
                    $$ = newExpNode(ConstantK, line);
                    $$->attr.value = 1; //1 fior true
                    $$->expType = Boolean;
                }
            | FALSE
                {
                    $$ = newExpNode(ConstantK, line);
                    $$->attr.value = 0; //0 for false
                    $$->expType = Boolean;
                }
            ;


%%

//// any functions for main here

int main(int argc, char argv[]) 
{
    int c;
    extern charoptarg;
    extern int optind;
    int pflg, dflg;
    int errflg;
    yydebug = 0;
    pflg = dflg= 0;
    char filename;
    bool printSyntaxTree = false;

    while (1)
    {
        /// hunt for a string of options
        while ((c = ourGetopt(argc, argv, (char)"pd")) != EOF)
            switch (c) 
            {
                case 'd': 
                    yydebug=1;
                    break;
                case 'p': 
                    printSyntaxTree=true;
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
            printf("ERROR: failed to open '%s'\n", filename);
            exit(1);
        }
    }
    else{
        yyparse();
    }
    if (printSyntaxTree) printTree(syntaxTree);
    return 0;
}