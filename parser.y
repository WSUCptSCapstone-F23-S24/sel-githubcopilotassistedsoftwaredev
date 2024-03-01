%{ 
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "scanType.h"
#include "treeNode.h"
#include "ourGetopt.cpp"
#include "treeUtil.h"

const char* getTypeName(int expType) {
    switch(expType) {
        case Integer: return "Integer";
        case Boolean: return "Boolean";
        case Char: return "Char";
        // Add other cases as needed
        default: return "Unknown";
    }
}


TreeNode *root = NULL;


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
extern int ourGetopt( int, char **, char*);

%}
//// your %union statement
%union {
    TokenData *tokenData;
    TreeNode *treeNode;
}



%type <treeNode> program decList decl varDecl funcDecl typeSpec varDeclList scopedVarDecl varDeclInit varDeclId parms stmt parmList
%type <treeNode> parmId parmIdList
%type <treeNode> parmTypeList matched unmatched exp otherStmts expStmt compoundStmt iterStmt returnStmt breakStmt localDecls
%type <treeNode> stmtList simpleExp iterRange mutable andExp unaryRelExp relExp relop minmaxExp minmaxOp sumExp sumOp mulExp
%type <treeNode> mulOp unaryExp unaryOp factor immutable call args argList constant
//%type <tokenData> LBRACE






//// your %token statements defining token classes
%token <tokenData> LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token <tokenData> COMMA COLON SEMICOLON 
%token <tokenData> IF THEN ELSE WHILE DO FOR TO BY RETURN BREAK
%token <tokenData> INT BOOL CHAR STATIC
%token <tokenData> ADD SUBTRACT MULTIPLY DIVIDE MOD QUEST
%token <tokenData> AND OR NOT 
%token <tokenData> EQ NEQ LT LE GT GE ASSIGN MIN MAX
%token <tokenData> ADDEQ SUBEQ MULEQ DIVEQ INC DEC
%token <tokenData> ID NUMCONST CHARCONST STRINGCONST TRUE FALSE





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
    {
        $$ = newDeclNode(VarK, line);
        $$->expType = $1->expType;
        $$->attr.name = $2->attr.name;
        $$->isArray = $2->isArray;

        if (root == NULL) {
            root = $$;
        } else {
            addSibling(root, $$);
        }
    }
    ;

// 5
scopedVarDecl: STATIC typeSpec varDeclList SEMICOLON
    {
        $$ = $2;
        $$->expType = $2->expType;
        $$->varKind = LocalStatic;

        treeNode* ptr = $$->sibling;
        while (ptr != NULL)
        {
            ptr->expType = $2->expType;
            ptr = ptr->sibling;
        }
    }
    | typeSpec varDeclList SEMICOLON
    {
        $$ = $2;
        $$->expType = $1->expType;

        treeNode* ptr = $$->sibling;
        while (ptr != NULL)
        {
            ptr->expType = $1->expType;
            ptr = ptr->sibling;
        }
    }
    ;

// 6 
varDeclList: varDeclList COMMA varDeclInit
    {
        $1->sibling = $3;
        $$ = $1;
    }
    | varDeclInit
    {
        $$ = $1;
    }
    ;

// 7
varDeclInit: varDeclId 
    {
        $$ = $1;
    }
    | varDeclId COLON simpleExp
    {
        $$ = $1;
    }
    ;

// 8 
varDeclId: ID
    {
        $$ = newDeclNode(VarK, line);
        $$->attr.name = $1->svalue;
    }
    | ID LBRACKET NUMCONST RBRACKET
    {
        $$ = newDeclNode(VarK, line);
        $$->attr.name = $1->svalue;
        $$->isArray = true;
        $$->arraySize = $3->nvalue;
    }


// 9
typeSpec: INT
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

// 10
funcDecl: typeSpec ID LPAREN parms RPAREN stmt
    {
        $$ = newDeclNode(FuncK, $2->linenum);
        $$->expType = $1->expType;
        $$->attr.name = $2->svalue;
        $$->child[0] = $4;
        $$->child[1] = $6; 

        if (root == NULL) {
            root = $$;
        } else {
            addSibling(root, $$);
        }    
    }
    | ID LPAREN parms RPAREN stmt
    {
        $$ = newDeclNode(FuncK, $1->linenum);
        $$->expType = Void;
        $$->attr.name = $1->svalue;
        $$->child[0] = $3;
        $$->child[1] = $5;

        if (root == NULL) {
            root = $$;
        } else {
            addSibling(root, $$);
        }
    }
    ;

// 11 
parms: parmList 
    {
        $$ = $1;
    }
    |
    {
        $$ = NULL;
    }
    ;

// 12
parmList: parmList SEMICOLON parmTypeList
    {
        $1->sibling = $3;
    }
    | parmTypeList
    {
        $$ = $1;
    }
    ;

// 13
parmTypeList: typeSpec parmIdList
    {
        $$ = $2;
        $2->expType = $1->expType;
        treeNode* ptr = $$->sibling;
        while (ptr != NULL)
        {
            ptr->expType = $1->expType;
            ptr = ptr->sibling;
        }
    }
    ;

// 14
parmIdList: parmIdList COMMA parmId 
    {
        $1->sibling = $3;
    }
    | parmId
    {
        $$ = $1;
    }
    ;

// 15
parmId: ID 
    {
        TreeNode *newNode = newDeclNode(ParamK, $1->linenum);
        newNode->attr.name = $1->svalue;
        newNode->expType = UndefinedType;
        newNode->subkind.decl = ParamK;
        $$ = newNode;
    }
    | ID LBRACKET RBRACKET
    {
        TreeNode *newNode = newDeclNode(ParamK, $1->linenum);
        newNode->attr.name = $1->svalue;
        newNode->expType = UndefinedType;
        newNode->subkind.decl = ParamK;
        newNode->isArray = true;
        $$ = newNode;
    }
    ;

// 16
stmt: matched  
    {
        $$ = $1;
    }
    | unmatched
    {
        $$ = $1;
    }
    ;

matched: IF exp THEN matched ELSE matched
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = IfK;
        $$->child[0] = $2;
        $$->child[1] = $4;
        $$->child[2] = $6;
    }
    | otherStmts
    {
        $$ = $1;
    }
    ;

unmatched: IF exp THEN stmt
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = IfK;
        $$->child[0] = $2;
        $$->child[1] = $4;
    }
    | IF exp THEN matched ELSE unmatched
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = IfK;
        $$->child[0] = $2;
        $$->child[1] = $4;
        $$->child[2] = $6;
    }
    ;

otherStmts: expStmt
    {
        $$ = $1;
    }
    | compoundStmt
    {
        $$ = $1;
    }
    | iterStmt
    {
        $$ = $1;
    }
    | returnStmt
    {
        $$ = $1;
    }
    | breakStmt
    {
        $$ = $1;
    }
    ;
    
// 17
expStmt: exp SEMICOLON
    {
        $$ = $1;
    }
    | SEMICOLON
    {
        $$ = NULL;
    }
    ;

// 18
compoundStmt: LBRACE localDecls stmtList RBRACE
    {
        $$ = newStmtNode(CompoundK, $1->linenum);
        $$->expType = UndefinedType;
        $$->child[0] = $2;
        $$->child[1] = $3;
    }
    ;

// 19
localDecls: localDecls scopedVarDecl 
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
    |
    {
        $$ = NULL;
    }
    ;  

// 20
stmtList: stmtList stmt
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
    |
    {  
        $$ = NULL;
    } 
    ;

// 22 
iterStmt: WHILE simpleExp DO stmt
    {
        $$ = newStmtNode(WhileK, $3->linenum);
        $$->child[0] = $2;
        $$->child[1] = $4;
    }
    | FOR ID ASSIGN iterRange DO stmt
    {
        //For node
        $$ = newStmtNode(LoopK, $2->linenum);

        //ID variable node
        $$->child[0] = newDeclNode(VarK, $2->linenum);
        $$->child[0]->expType = Integer;
        $$->child[0]->attr.name = $2->svalue;

        $$->child[1] = $4;
        $$->child[2] = $6;
    }
    ;

// 23
iterRange: simpleExp TO simpleExp
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

// 24
returnStmt: RETURN SEMICOLON
    {
        $$ = newStmtNode(ReturnK, $1->linenum);
    }
    | RETURN exp SEMICOLON
    {
        $$ = newStmtNode(ReturnK, $1->linenum);
        $$->child[0] = $2;
    }
    ;

// 25
breakStmt: BREAK SEMICOLON
    {
        $$ = newStmtNode(BreakK, $1->linenum);
    }
    ;

// 26
exp: mutable ASSIGN exp
    {
        $$ = newExpNode(AssignK, $1->lineno);
        $$->attr.name = "=";
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable ADDEQ exp
    {
        $$ = newExpNode(AssignK, $1->lineno);
        $$->attr.name = "+=";
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable SUBEQ exp
    {
        $$ = newExpNode(AssignK, $1->lineno);
        $$->attr.name = "-=";
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable MULEQ exp
    {
        $$ = newExpNode(AssignK, $1->lineno);
        $$->attr.name = "*=";
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable DIVEQ exp
    {
        $$ = newExpNode(AssignK, $1->lineno);
        $$->attr.name = "/=";
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable INC
    {
        $$ = newExpNode(AssignK, $1->lineno);
        $$->attr.name = "++";
        $$->child[0] = $1;
    }
    | mutable DEC
    {
        $$ = newExpNode(AssignK, $1->lineno);
        $$->attr.name = "--";
        $$->child[0] = $1;
    }
    | simpleExp
    {
        $$ = $1;
    }
    ;

// 27
simpleExp: simpleExp OR andExp
    {
        $$ = newExpNode(OpK, $3->lineno);
        $$->attr.name = "OR";
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | andExp
    {
        $$ = $1;
    }
    ;

// 28
andExp: andExp AND unaryRelExp
    {
        $$ = newExpNode(OpK, $3->lineno);
        $$->attr.name = "AND";
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | unaryRelExp
    {
        $$ = $1;
    }
    ;  

// 29
unaryRelExp: NOT unaryRelExp
    {
        $$ = newExpNode(OpK, $2->lineno);
        $$->attr.name = "NOT";
        $$->child[0] = $2;
    }
    | relExp
    {
        $$ = $1;
    }
    ;

// 30
relExp: minmaxExp relop minmaxExp
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

// 31
relop: LE
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "<=";
    }
    | LT
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "<";
    }
    | GT
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = ">";
    }
    | GE
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = ">=";
    }
    | EQ
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "==";
    }
    | NEQ
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "!=";
    }
    ;

// 32
minmaxExp: minmaxExp minmaxOp sumExp
    {
        $$ = $2;
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | sumExp
    {
        $$ = $1;
    }
    ;

// 33 
minmaxOp: MIN
    {
       $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "MIN";
    }
    | MAX
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "MAX";
    }
    ;

// 34
sumExp: sumExp sumOp mulExp
    {
        $$ = $2;
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mulExp
    {
        $$ = $1;
    }
    ;

// 35
sumOp: ADD
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name="+";
    }
    | SUBTRACT
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "-";
    }
    ;

// 36
mulExp: mulExp mulOp unaryExp
    {
        $$ = $2;
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | unaryExp
    {
        $$ = $1;
    }
    ;

// 37
mulOp: MULTIPLY
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "*";
    }
    | DIVIDE
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "/";
    }
    | MOD
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "%";
    }
    ;

// 38
unaryExp: unaryOp unaryExp
    {
        $$ = $1;
        $$->child[0] = $2;
    }
    | factor
    {
        $$ = $1;
    }
    ;

// 39
unaryOp: SUBTRACT
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "-";
    }
    | MULTIPLY
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "SIZEOF";
    }
    | QUEST
    {
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "?";
    }
    ;

// 40
factor: immutable
    | mutable
    ;

// 41
mutable: ID
    {
        $$ = newExpNode(IdK, $1->linenum);
        $$->attr.name = $1->svalue;
    }
    | ID LBRACKET exp RBRACKET
    {
        //create lbracket op node
        $$ = newExpNode(OpK, $1->linenum);
        $$->attr.name = "[";

        //create child 0 as id
        $$->child[0] = newExpNode(IdK, $1->linenum);
        $$->child[0]->attr.name = $1->svalue;

        //set child 1 to exp
        $$->child[1] = $3;

    }
    ;

// 42
immutable: LPAREN exp RPAREN
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

// 43
call: ID LPAREN args RPAREN
    {
        $$ = newExpNode(CallK, $1->linenum);
        $$->attr.name = $1->svalue;
        $$->child[0] = $3;
    }
    ;

// 44
args: argList
    {
        $$ = $1;
    }
    |
    {
        $$ = NULL;
    }
    ;

// 45
argList: argList COMMA exp
    {
        $$ = $1;
        addSibling($$, $3);
    }
    | exp
    {
        $$ = $1;
    }
    ;

// 46
constant: NUMCONST
    {   
        $$ = newExpNode(ConstantK, $1->linenum);
        $$->attr.value = $1->nvalue;
        $$->expType = Integer;
    }
    | CHARCONST
    {
        $$ = newExpNode(ConstantK, $1->linenum);
        $$->attr.cvalue = $1->cvalue;
        $$->expType = Char;
    }
    | STRINGCONST
    {
        $$ = newExpNode(ConstantK, $1->linenum);
        $$->attr.string = $1->svalue;
        $$->expType = String;
    }
    | TRUE
    {
        $$ = newExpNode(ConstantK, $1->linenum);
        $$->attr.value = 1;
        $$->expType = Boolean;
    }
    | FALSE
    {
        $$ = newExpNode(ConstantK, $1->linenum);
        $$->attr.value = 0;
        $$->expType = Boolean;
    }
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

    if (printTreeFlag) {
        printTree(root);
    }
    
    return 0;
}
