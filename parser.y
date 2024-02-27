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
%type <treeNode> parmTypeList matched unmatched exp otherStmts expStmt compoundStmt iterStmt returnStmt breakStmt localDecls
%type <treeNode> stmtList simpleExp iterRange mutable andExp unaryRelExp relExp relop minmaxExp minmaxOp sumExp sumOp mulExp
%type <treeNode> mulOp unaryExp unaryOp factor immutable call args argList constant






//// your %token statements defining token classes
%token LPAREN RPAREN LBRACE RBRACE LBRACKET RBRACKET
%token COMMA COLON SEMICOLON 
%token IF THEN ELSE WHILE DO FOR TO BY RETURN BREAK
%token INT BOOL CHAR STATIC
%token ADD SUBTRACT MULTIPLY DIVIDE MOD QUEST
%token AND OR NOT 
%token EQ NEQ LT LE GT GE ASSIGN MIN MAX
%token ADDEQ SUBEQ MULEQ DIVEQ INC DEC
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
        TreeNode *newNode = newDeclNode(VarK, line);
        newNode->expType = $1->expType;
        newNode->attr.name = $2->attr.name;
        newNode->isArray = $2->isArray;

        if (root == NULL) {
            root = newNode;
        } else {
            addSibling(root, newNode);
        }
        $$ = newNode;
    }
    ;

// 5
scopedVarDecl: STATIC typeSpec varDeclList SEMICOLON
    {
        $$ = new TreeNode();
        $$->nodekind = DeclK;
        $$->subkind.decl = VarK;
        $$->expType = $2->expType;
        $$->attr.name = $3->attr.name;
    }
    | typeSpec varDeclList SEMICOLON
    ;

// 6 
varDeclList: varDeclList COMMA varDeclInit
    | varDeclInit
    {
        $$ = $1;
    }
    ;

// 7
varDeclInit: varDeclId 
    {
        $$ = $1;
        printf("Var: %s of type %s [line: %d]\n", $$->attr.name, getTypeName($$->expType), $$->lineno);
    }
    | varDeclId COLON simpleExp
    {
        $$ = $1;
        printf("Var: %s of type %s [line: %d]\n", $$->attr.name, getTypeName($$->expType), $$->lineno);
    }
    ;

// 8 
varDeclId: ID
    {
        $$ = new TreeNode();
        $$->nodekind = DeclK;
        $$->subkind.decl = VarK;
        $$->expType = $1->expType;
        $$->attr.name = $1->svalue;
    }
    | ID LBRACKET NUMCONST RBRACKET
    {
        $$ = new TreeNode();
        $$->nodekind = DeclK;
        $$->subkind.decl = VarK;
        $$->expType = $1->expType;
        $$->attr.name = $1->svalue;
        $$->isArray = true;
        $$->arraySize = $3->nvalue;
    
    }


// 9
typeSpec: INT
    {
        $$ = new TreeNode();
        $$->nodekind = DeclK;
        $$->subkind.decl = ParamK;
        $$->expType = Integer;
    }
    | BOOL
    {
        $$ = new TreeNode();
        $$->nodekind = DeclK;
        $$->subkind.decl = ParamK;
        $$->expType = Boolean;
    }
    | CHAR
    {
        $$ = new TreeNode();
        $$->nodekind = DeclK;
        $$->subkind.decl = ParamK;
        $$->expType = Char;
    }
    ;

// 10
funcDecl: typeSpec ID LPAREN parms RPAREN stmt
    {
        TreeNode *newNode = newDeclNode(FuncK, $2->linenum);
        newNode->expType = $1->expType;
        newNode->attr.name = $2->svalue;
        $$->nodekind = DeclK;
        $$->child[0] = $4;
        $$->child[1] = $6;

        if (root == NULL) {
            root = newNode;
        } else {
            addSibling(root, newNode);
        }
        $$ = newNode;        
    }
    | ID LPAREN parms RPAREN stmt
    {
        TreeNode *newNode = newDeclNode(FuncK, $1->linenum);
        newNode->expType = Void;
        newNode->attr.name = $1->svalue;
        $$->nodekind = DeclK;
        $$->child[0] = $3;
        $$->child[1] = $5;

        if (root == NULL) {
            root = newNode;
        } else {
            addSibling(root, newNode);
        }
        $$ = newNode;  
    }
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
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = IfK;
        $$->child[0] = $2;
        $$->child[1] = $4;
        $$->child[2] = $6;
    }
    | otherStmts
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
    | compoundStmt
    | iterStmt
    | returnStmt
    | breakStmt
    ;
    
// 17
expStmt: exp SEMICOLON
    {
        $$ = $1;
    }
    | SEMICOLON
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = NullK;
    }
    ;

// 18
compoundStmt: LBRACE localDecls stmtList RBRACE
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = CompoundK;
        $$->child[0] = $2;
        $$->child[1] = $3;
    }
    ;

// 19
localDecls: localDecls scopedVarDecl 
    {
        $$ = $1;
        $$->sibling = $2;
    }
    |
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = NullK;
    }
    ;  

// 20
stmtList: stmtList stmt
    {
        $$ = $1;
        $$->sibling = $2;
    }
    |
    {  
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = NullK;
    } 
    ;

// 22 
iterStmt: WHILE simpleExp DO stmt
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = WhileK;
        $$->child[0] = $2;
        $$->child[1] = $4;
    }
    | FOR ID ASSIGN iterRange DO stmt
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = LoopK;
        $$->child[0] = NULL;
        $$->child[1] = $4;
        $$->child[2] = $6;
    }
    ;

// 23
iterRange: simpleExp TO simpleExp
    | simpleExp TO simpleExp BY simpleExp
    ;

// 24
returnStmt: RETURN SEMICOLON
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = ReturnK;
    }
    | RETURN exp SEMICOLON
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = ReturnK;
        $$->child[0] = $2;
    }
    ;

// 25
breakStmt: BREAK SEMICOLON
    {
        $$ = new TreeNode();
        $$->nodekind = StmtK;
        $$->subkind.stmt = BreakK;
    }
    ;

// 26
exp: mutable ASSIGN exp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = AssignK;
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable ADDEQ exp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = ADD;
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable SUBEQ exp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = SUBTRACT;
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable MULEQ exp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = MULTIPLY;
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable DIVEQ exp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = DIVIDE;
        $$->child[0] = $1;
        $$->child[1] = $3;
    }
    | mutable INC
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = INC;
        $$->child[0] = $1;
    }
    | mutable DEC
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = DEC;
        $$->child[0] = $1;
    }
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
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = NOT;
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
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = $2->attr.op;
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
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = LE;
    }
    | LT
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = LT;
    }
    | GT
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = GT;
    }
    | GE
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = GE;
    }
    | EQ
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = EQ;
    }
    | NEQ
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = NEQ;
    }
    ;

// 32
minmaxExp: minmaxExp minmaxOp sumExp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = $2->attr.op;
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
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = MIN;
    }
    | MAX
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = MAX;
    }
    ;

// 34
sumExp: sumExp sumOp mulExp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = $2->attr.op;
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
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = ADD;
    }
    | SUBTRACT
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = SUBTRACT;
    }
    ;

// 36
mulExp: mulExp mulOp unaryExp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = $2->attr.op;
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
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = MULTIPLY;
    }
    | DIVIDE
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = DIVIDE;
    }
    | MOD
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = MOD;
    }
    ;

// 38
unaryExp: unaryOp unaryExp
    | factor
    ;

// 39
unaryOp: SUBTRACT
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = SUBTRACT;
    }
    | MULTIPLY
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = MULTIPLY;
    }
    | QUEST
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = OpK;
        $$->attr.op = QUEST;
    }
    ;

// 40
factor: immutable
    | mutable
    ;

// 41
mutable: ID
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = IdK;
        $$->attr.name = $1->svalue;
    }
    | ID LBRACKET exp RBRACKET
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = ArrIdK;
        $$->attr.name = $1->svalue;
        $$->child[0] = $3;
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
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = ConstantK;
        $$->expType = $1->expType;
        $$->attr.value = $1->attr.value;
    }
    ;

// 43
call: ID LPAREN args RPAREN
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = CallK;
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
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = NullExpK;
    }
    ;

// 45
argList: argList COMMA exp
    {
        $$ = $1;
        $$->child[0] = $3;
    }
    | exp
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = ArgK;
        $$->child[0] = $1;
    }
    ;

// 46
constant: NUMCONST
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = ConstantK;
        $$->expType = Integer;
        $$->attr.value = $1->cvalue;
    }
    | CHARCONST
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = ConstantK;
        $$->expType = Char;
        $$->attr.value = $1->nvalue;
    }
    | STRINGCONST
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = ConstantK;
        $$->expType = String;
        $$->attr.name = $1->svalue;
    }
    | TRUE
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = ConstantK;
        $$->expType = Boolean;
        $$->attr.value = 1;
    }
    | FALSE
    {
        $$ = new TreeNode();
        $$->nodekind = ExpK;
        $$->subkind.exp = ConstantK;
        $$->expType = Boolean;
        $$->attr.value = 0;
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
