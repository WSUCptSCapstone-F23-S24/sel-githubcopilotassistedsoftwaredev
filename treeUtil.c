#include "treeUtil.h"
#include "treeNode.h"

void printToken(TokenType token, const char* tokenString)
{ 
    switch (token)
    { 
        case P_IF: 
        case P_ELSE: 
        case P_INT: 
        case P_RETURN: 
        case P_VOID: 
        case P_WHILE:
            printf("reserved word: %s\n",tokenString);
            break;
        case P_ASSIGN: printf("=\n"); break;
        case P_EQ: printf("==\n"); break;
        case P_LT: printf("<\n"); break;
        case P_LTE: printf("<=\n"); break;
        case P_GT: printf(">\n"); break;
        case P_GTE: printf(">=\n"); break;
        case P_NEQ: printf("!=\n"); break;
        case P_LPAREN: printf("(\n"); break;
        case P_RPAREN: printf(")\n"); break;
        case P_LBRACKET: printf("[\n"); break;
        case P_RBRACKET: printf("]\n"); break;
        case P_LBRACE: printf("{\n"); break;
        case P_RBRACE: printf("}\n"); break;
        case P_SEMI: printf(";\n"); break;
        case P_COMMA: printf(",\n"); break;
        case P_PLUS: printf("+\n"); break;
        case P_MINUS: printf("-\n"); break;
        case P_TIMES: printf("*\n"); break;
        case P_OVER: printf("/\n"); break;
        case P_ENDFILE: printf("EOF\n"); break;
        case P_NUM:
            printf("NUM, val= %s\n",tokenString);
            break;
        case P_ID:
            printf("ID, name= %s\n",tokenString);
            break;
        case P_ERROR:
            printf("ERROR: %s\n",tokenString);
            break;
        default: /* should never happen */
            printf("Unknown token: %d\n",token);
    }
}

TreeNode *newDeclNode(DeclKind kind, int lineno)
{
    TreeNode *t = (TreeNode *)malloc(sizeof(TreeNode));
    int i;
    if (t == NULL)
        printf("Out of memory error at line %d\n", lineno);
    else
    {
        for (i = 0; i < MAXCHILDREN; i++)
            t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = DeclK;
        t->subkind.decl = kind;
        t->lineno = lineno;
    }
    return t;
}


TreeNode * newStmtNode(StmtKind kind, int lineno)
{
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t==NULL)
        printf("Out of memory error at line %d\n",lineno);
    else
    {
        for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = StmtK;
        t->subkind.stmt = kind;
        t->lineno = lineno;
    }
    return t;
}

TreeNode * newExpNode(ExpKind kind, int lineno)
{
    TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
    int i;
    if (t==NULL)
        printf("Out of memory error at line %d\n",lineno);
    else
    {
        for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
        t->sibling = NULL;
        t->nodekind = ExpK;
        t->subkind.exp = kind;
        t->lineno = lineno;
        t->expType = (ExpType)kind;
    }
    return t;
}

static int indentno = 0;

#define INDENT indentno+=2
#define UNINDENT indentno-=2

static void printSpaces(int spacing)
{
    int i;
    for (i=0;i<spacing;i++)
        printf(".    ");
}

void printTreeRecursive(TreeNode * tree, int sibling, int child, int spacing)
{
    if (tree==NULL) 
    {
        printf("NULL tree\n");
        return;
    }
    else 
    {
        printSpaces(spacing);
        if (sibling > 0)
        {
            printf("Sibling: %d ", sibling);
        }
        if (child > -1)
        {
            printf("Child: %d ", child);
        }
        switch (tree->nodekind)
        {
            case DeclK:
                printDeclaration(tree);
                break;
            case StmtK:
                printStatement(tree);
                break;
            case ExpK:
                printExpression(tree);
                break;
        }
        //print the node kind and subkind if it is declaration
        

        //print the subkind if it is a statement
        
        printf("[Line : %d]\n", tree->lineno);
    }

    //iterate through children, calling printTreeRecursive
    for (int i = 0; i < MAXCHILDREN; i++)
    {
        if (tree->child[i] != NULL)
        {
            printTreeRecursive(tree->child[i], 0, i, spacing+1);
        }
    }

    if (tree->sibling != NULL)
    {
        //call for sibling
        printTreeRecursive(tree->sibling, sibling + 1, -1, spacing);
    }

}

void printTree(TreeNode * tree)
{
    printTreeRecursive(tree, 0, -1, 0);
}

void printDeclaration(TreeNode * tree)
{
    switch (tree->subkind.decl)
        {
            case VarK:
                printf("Var: %s ", tree->attr.name);
                if (tree->isArray == true)
                {
                    printf("is array ");
                }
                printf("of type ");
                break;
            case FuncK:
                printf("Func: %s returns type ", tree->attr.name);
                break;
            case ParamK:
                printf("Param: %s ", tree->attr.name);
                if (tree->isArray == true)
                {
                    printf("is array ");
                }
                printf("of type ");
            break;
        }
    printType(tree->expType);
}

void printExpression(TreeNode * tree)
{
    switch (tree->subkind.exp)
    {
        case OpK:
            printf("Op: ");
            break;
        case ConstantK:
            printf("Const ");
            if (tree->isArray)
            {
                printf("is array ");
            }
            printf("of type ");
            printType(tree->expType);
            printf(": ");
            break;
        case IdK:
            printf("Id: %s ", tree->attr.name);
            return;
            break;
        case InitK:
            printf("Init: ");
            break;
        case CallK:
            printf("Call: ");
            break;
        case ArrIdK:
            printf("ArrId: ");
            break;
        case AssignK:
            printf("Assign: ");
            break;
        case ArgK:
            printf("Arg: ");
            break;
        case NullExpK:
            printf("Null: ");
            break;
    }
    if (tree->expType == Integer)
    {
        printf("%d ", tree->attr.value);
    }
    else if (tree->expType == Char)
    {
        printf("'%c' ", tree->attr.cvalue);
    }
    else if (tree->expType == Boolean)
    {
        printf("%d ", tree->attr.value);
    }
    else
    {
        printf("%s ", tree->attr.name);
    }
}

void printStatement(TreeNode * tree)
{
    switch (tree->subkind.stmt)
        {
            case CompoundK:
                printf("Compound ");
                break;
            case ReturnK:
                printf("Return ");
                break;
            case BreakK:
                printf("Break ");
                break;
            case LoopK:
                printf("For ");
                break;
            case WhileK:
                printf("While ");
                break;
            case RangeK:
                printf("Range ");
                break;
        }
}

void printType(ExpType type)
{
    switch (type)
    {
        case Void:
            printf("void ");
            break;
        case Integer:
            printf("int ");
            break;
        case Boolean:
            printf("bool ");
            break;
        case Char:
            printf("char ");
            break;
        case CharInt:
            printf("charint ");
            break;
        case Equal:
            printf("equal ");
            break;
        case UndefinedType:
            printf("undefined ");
            break;
        case String:
            printf("string ");
            break;
    }
}

// add a TreeNode to a list of siblings.
// Adding a NULL to the list is probably a programming error!
TreeNode *addSibling(TreeNode *t, TreeNode *s)
{
    if (s==NULL) {
        printf("ERROR(SYSTEM): never add a NULL to a sibling list.\n");
        exit(1);
    }
    if (t!=NULL) { 
        TreeNode *tmp;

        tmp = t;
        while (tmp->sibling!=NULL) tmp = tmp->sibling;
        tmp->sibling = s; 
        return t;
    }
    return s;
}


// pass the static and type attribute down the sibling list
void setType(TreeNode *t, ExpType type, bool isStatic)
{
    while (t) {
        t->expType = type;
        t->isStatic = isStatic;

        t = t->sibling;
    }
}
