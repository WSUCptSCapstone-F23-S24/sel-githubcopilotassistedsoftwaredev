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
            ;
declList    : declList decl
            | decl
            ;
decl        : varDecl
            | funDecl
            ;
varDecl     : typeSpec varDeclList SEMI 
                {
                    $$ = $2;
                    $$->expType = $1->expType;

                    for (int i = 0; i < MAXCHILDREN; i++)
                    {
                        if ($$->child[i] != NULL)
                        {
                            $$->child[i]->isArray = $$->isArray;
                            $$->child[i]->expType = $1->expType;
                        }
                    }

                    if (syntaxTree == NULL) {
                        syntaxTree = $$;
                    } else {
                        addSibling(syntaxTree, $$);
                    }
                }
            ;
scopedVarDecl : STATIC typeSpec varDeclList SEMI
                    {
                        $$ = $3;
                        $$->expType = $2->expType;
                        $$->varKind = LocalStatic;

                        treeNode* temp = $$->sibling;
                        while (temp != NULL)
                        {
                            temp->expType = $2->expType;
                            temp = temp->sibling;
                        }
                    }
              | typeSpec varDeclList SEMI
                    {
                        $$ = $2;
                        $$->expType = $1->expType;

                        treeNode* temp = $$->sibling;
                        while (temp != NULL)
                        {
                            temp->expType = $1->expType;
                            temp = temp->sibling;
                        }
                    }
              ;
varDeclList : varDeclList COMMA varDeclInit
                {
                    $$ = $1;
                    addSibling($$, $3);
                }
            | varDeclInit
                {
                    $$ = $1;
                }
            ;
varDeclInit : varDeclId
                {
                    $$ = $1;
                }
            | varDeclId COLON simpleExp
                {
                    $$ = $1;
                    $$->child[0] = $3;
                }
            ;
varDeclId   : ID
                {
                    $$ = newDeclNode(VarK, $1->linenum);
                    $$->attr.name = $1->svalue;
                         
                }
            | ID LBRACK NUMCONST RBRACK
                {
                    $$ = newDeclNode(VarK, $1->linenum);
                    $$->attr.name = $1->svalue;
                    $$->isArray = 1;
                }
            ;
typeSpec    : INT 
                {
                    $$ = newDeclNode(ParamK, $1->linenum);
                    $$->expType = Integer;
                }
            | BOOL 
                {
                    $$ = newDeclNode(ParamK, $1->linenum);
                    $$->expType = Boolean;
                }
            | CHAR 
                {
                    $$ = newDeclNode(ParamK, $1->linenum);
                    $$->expType = Char;
                }
            ;
funDecl     : typeSpec ID LPAREN parms RPAREN stmt
                {
                    $$ = newDeclNode(FuncK, $2->linenum);
                    $$->expType = $1->expType;
                    $$->attr.name = $2->svalue;
                    $$->child[0] = $4;
                    $$->child[1] = $6; 

                    if (syntaxTree == NULL) {
                        syntaxTree = $$;
                    } else {
                        addSibling(syntaxTree, $$);
                    }    
                }
            | ID LPAREN parms RPAREN stmt
                {
                    $$ = newDeclNode(FuncK, $1->linenum);
                    $$->expType = Void;
                    $$->attr.name = $1->svalue;
                    $$->child[0] = $3;
                    $$->child[1] = $5;
                    if (syntaxTree == NULL) {
                        syntaxTree = $$;
                    } else {
                        addSibling(syntaxTree, $$);
                    }
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
                    addSibling($1, $3);
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
                        treeNode* temp = $$->sibling;
                        while (temp != NULL)
                        {
                            temp->expType = $1->expType;
                            temp = temp->sibling;
                        }
                    }
             ;
parmIdList  : parmIdList COMMA parmId { addSibling($1, $3); }
            | parmId  { $$ = $1; }
            ;
parmId      : ID 
                {
                    TreeNode *temp = newDeclNode(ParamK, $1->linenum);
                    temp->attr.name = $1->svalue;
                    temp->expType = UndefinedType;
                    $$ = temp;
                }
            | ID LBRACK RBRACK
                {
                    $$ = newDeclNode(ParamK, $1->linenum);
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
                    $$ = NULL;
                }
            ;
compoundStmt : LCURLY localDecls stmtList RCURLY
                {
                    $$ = newStmtNode(CompoundK, $1->linenum);
                    $$->expType = UndefinedType; // For type checking
                    $$->child[0] = $2;
                    $$->child[1] = $3;
                }
             ;
localDecls  : localDecls scopedVarDecl
                {
                    if ($1 == NULL)
                    {
                        $$ = $2;
                    }
                    else
                    {
                        $$ = $1;
                        addSibling($1, $2);
                    }
                }
            | /* empty */
                {
                    $$ = NULL;
                }
            ;
stmtList    : stmtList stmt
                {
                    if ($1 == NULL)
                    {
                        $$ = $2;
                    }
                    else
                    {
                        $$ = $1;
                        addSibling($1, $2);
                    }
                }
            | /* empty */
                {
                    //$$ = newStmtNode(NullK, $1->linenum); 
                    $$ = NULL;
                }
            ;
selectStmt  : IF simpleExp THEN stmt ELSE stmt
                    {
                        $$ = newStmtNode(IfK, $1->linenum);
                        $$->child[0] = $2; 
                        $$->child[1] = $4; 
                        $$->child[2] = $6; 
                    }
            | IF simpleExp THEN stmt
                    {
                        $$ = newStmtNode(IfK, $1->linenum);
                        $$->child[0] = $2; 
                        $$->child[1] = $4; 
                    }
            ;
iterStmt    : WHILE simpleExp DO stmt
                {
                    $$ = newStmtNode(WhileK, $1->linenum);
                    $$->child[0] = $2; 
                    $$->child[1] = $4; 
                }
            | FOR ID EQ iterRange DO stmt
                {
                    $$ = newStmtNode(LoopK, $2->linenum);
                    $$->attr.name = $2->svalue;
                    $$->child[0]->expType = Integer;
                    $$->child[0]->attr.name = $2->svalue;
                    $$->child[0] = newDeclNode(VarK, $2->linenum);
                    $$->child[0] = $4; 
                    $$->child[1] = $6; 
                }
            ;
iterRange   : simpleExp TO simpleExp
                {
                    $$ = newStmtNode(RangeK, $2->linenum);
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | simpleExp TO simpleExp BY simpleExp
                {
                    $$ = newStmtNode(RangeK, $2->linenum);
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                    $$->child[2] = $5; 
                }
            ;
returnStmt  : RETURN SEMI
                {
                    $$ = newStmtNode(ReturnK, $1->linenum);
                }
            | RETURN exp SEMI
                {
                    $$ = newStmtNode(ReturnK, $1->linenum);
                    $$->child[0] = $2; 
                }
            ;
breakStmt   : BREAK SEMI
                {
                    $$ = newStmtNode(BreakK, $1->linenum);
                }
            ;
exp         : mutable EQ exp
                {
                    $$ = newExpNode(AssignK, $1->lineno);
                    $$->attr.op = EQ;   // set token type (same as in bison)
                    $$->attr.name = "=";
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable PLUSEQ exp // opK
                {
                    $$ = newExpNode(OpK, $1->lineno);
                    $$->attr.op = PLUSEQ;   // set token type (same as in bison)
                    $$->attr.name = "+=";
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable MINUSEQ exp
                {
                    $$ = newExpNode(OpK, $1->lineno);
                    $$->attr.op = MINUSEQ;   // set token type (same as in bison)
                    $$->attr.name = "-=";
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable TIMESEQ exp
                {
                    $$ = newExpNode(OpK, $1->lineno);
                    $$->attr.op = TIMESEQ;   // set token type (same as in bison)
                    $$->attr.name = "*=";
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable DIVEQ exp
                {
                    $$ = newExpNode(OpK, $1->lineno);
                    $$->attr.op = DIVEQ;   // set token type (same as in bison)
                    $$->attr.name = "/=";
                    $$->child[0] = $1; 
                    $$->child[1] = $3; 
                }
            | mutable PLUSPLUS
                {
                    $$ = newExpNode(OpK, $1->lineno);
                    $$->attr.op = PLUSPLUS;   // set token type (same as in bison)
                    $$->attr.name = "++";
                    $$->child[0] = $1; 
                }
            | mutable MINUSMINUS
                {
                    $$ = newExpNode(OpK, $1->lineno);
                    $$->attr.op = MINUSMINUS;   // set token type (same as in bison)
                    $$->attr.name = "--";
                    $$->child[0] = $1; 
                }
            | simpleExp { $$ = $1; }
            ;
simpleExp   : simpleExp OR andExp
                {
                    $$ = newExpNode(OpK, $3->lineno);
                    $$->attr.op = OR;   // set token type (same as in bison)
                    $$->attr.name = "OR";
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
                    $$ = newExpNode(OpK, $3->lineno);
                    $$->attr.op = AND;   // set token type (same as in bison)
                    $$->attr.name = "AND";
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
                    $$ = newExpNode(OpK, $2->lineno);
                    $$->attr.op = NOT;   // set token type (same as in bison)
                    $$->attr.name = "NOT";
                    $$->child[0] = $2;
                }
            | relExp 
                {
                    $$ = $1;
                }
            ;
relExp      : minmaxExp relop minmaxExp
                {
                    $$ = $2; 
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
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = LTEQ;   // set token type (same as in bison)
                    $$->attr.name = "<=";
                }
            | LT 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = LT;   // set token type (same as in bison)
                    $$->attr.name = "<";
                }
            | GT 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = GT;   // set token type (same as in bison)
                    $$->attr.name = ">";
                }
            | GTEQ 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = GTEQ;   // set token type (same as in bison)
                    $$->attr.name = ">=";
                }
            | EQEQ 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = EQEQ;   // set token type (same as in bison)
                    $$->attr.name = "==";
                }
            | NOTEQ 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = NOTEQ;   // set token type (same as in bison)
                    $$->attr.name = "!=";
                }
            ;
minmaxExp   : minmaxExp minmaxop sumExp
                {
                    $$ = $2; 
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | sumExp { $$ = $1; }
            ;
minmaxop    : SEMIGT 
                {
                    // MIN 
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = SEMIGT;
                    $$->attr.name = "MIN";
                }
            | SEMILT 
                {
                    // MAX
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = SEMILT;
                    $$->attr.name = "MAX";
                }
            ;
sumExp      : sumExp sumop mulExp
                {
                    $$ = $2;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | mulExp { $$ = $1; }
            ;
sumop       : PLUS
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = PLUS;
                    $$->attr.name = "+";
                }
            | MINUS
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = MINUS;
                    $$->attr.name = "-";
                }
            ;
mulExp      : mulExp mulop unaryExp
                {
                    $$ = $2;
                    $$->child[0] = $1;
                    $$->child[1] = $3;
                }
            | unaryExp { $$ = $1; }
            ;
mulop       : TIMES 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = TIMES;
                    $$->attr.name = "*";
                }
            | DIVIDE
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = DIVIDE;
                    $$->attr.name = "/";
                }
            | MOD
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = MOD;
                    $$->attr.name = "%";
                }
            ;
unaryExp    : unaryop unaryExp
                {
                    $$ = $1;
                    $$->child[0] = $2;
                }
            | factor { $$ = $1; }
            ;
unaryop     : MINUS 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = MINUS;
                    $$->attr.name = "-";
                }
            | TIMES 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = TIMES;
                }
            | QUESTION 
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.op = QUESTION;
                    $$->attr.name = "?";
                }
            ;
factor      : immutable 
            | mutable 
            ;
mutable     : ID
                {
                    $$ = newExpNode(IdK, $1->linenum);
                    $$->attr.name = $1->svalue;
                }
            | ID LBRACK exp RBRACK
                {
                    $$ = newExpNode(OpK, $1->linenum);
                    $$->attr.name = "[";
                    $$->child[0] = newExpNode(IdK, $1->linenum);
                    $$->child[0]->attr.name = $1->svalue;
                    $$->child[1] = $3;
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
                    $$ = $1;  
                }
            ;
call        : ID LPAREN args RPAREN
                {
                    $$ = newExpNode(CallK, $1->linenum);
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
                    addSibling($$, $3);
                }
            | exp
                {
                    $$ = $1;
                }
            ;
constant    : NUMCONST
                {
                    $$ = newExpNode(ConstantK, $1->linenum);
                    $$->expType = Integer;
                    $$->attr.value = $1->nvalue;
                }
            | CHARCONST
                {
                    $$ = newExpNode(ConstantK, $1->linenum);
                    $$->expType = Char;
                    $$->attr.cvalue = $1->cvalue;
                }
            | STRINGCONST
                {
                    $$ = newExpNode(ConstantK, $1->linenum);
                    $$->expType = String;
                    $$->attr.string = $1->svalue;
                }
            | TRUE
                {
                    $$ = newExpNode(ConstantK, $1->linenum);
                    $$->attr.value = 1; //1 fior true
                    $$->expType = Boolean;
                }
            | FALSE
                {
                    $$ = newExpNode(ConstantK, $1->linenum);
                    $$->attr.value = 0; //0 for false
                    $$->expType = Boolean;
                }
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
    bool printSyntaxTree = false;
    
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
            printf("ERROR: failed to open \'%s\'\n", filename);
            exit(1);
        }         
    }
    else{
        yyparse();
    }
    if (printSyntaxTree) printTree(syntaxTree);
    return 0;
}