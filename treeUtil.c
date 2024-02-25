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


TreeNode * newStmtNode(StmtKind kind)
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

TreeNode * newExpNode(ExpKind kind)
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
        t->expType = Void;
    }
    return t;
}

char * copyString(char * s)
{
    int n;
    char * t;
    if (s==NULL) return NULL;
    n = strlen(s)+1;
    t = (char *) malloc(n);
    if (t==NULL)
        printf("Out of memory error at line %d\n",lineno);
    else strcpy(t,s);
    return t;
}

static int indentno = 0;

#define INDENT indentno+=2
#define UNINDENT indentno-=2

static void printSpaces(void)
{
    int i;
    for (i=0;i<indentno;i++)
        printf(" ");
}

void printTree(TreeNode * tree)
{
    int i;
    INDENT;
    if (tree==NULL) 
    {
        printf("NULL tree\n");
        return;
    }
    while (tree != NULL)
    {
        printSpaces();
        if (tree->nodekind==StmtK)
        {
            switch (tree->subkind.stmt)
            {
                case IfK:
                    printf("If\n");
                    break;
                case WhileK:
                    printf("While\n");
                    break;
                case AssignK:
                    printf("Assign to: %s\n",tree->attr.name);
                    break;
                case ReturnK:
                    printf("Return\n");
                    break;
                case CallK:
                    printf("Call: %s\n",tree->attr.name);
                    break;
                default:
                    printf("Unknown ExpNode kind\n");
                    break;
            }
        }
        else if (tree->nodekind==ExpK)
        {
            switch (tree->subkind.exp)
            {
                case OpK:
                    printf("Op: ");
                    printToken(tree->attr.op,"\0");
                    break;
                case ConstantK:
                    printf("Const: %d\n",tree->attr.cvalue);
                    break;
                case IdK:
                    printf("Id: %s\n",tree->attr.name);
                    break;
                case ArrIdK:
                    printf("Array Id: %s\n",tree->attr.name);
                    break;
                case CallK:
                    printf("Call: %s\n",tree->attr.name);
                    break;
                default:
                    printf("Unknown ExpNode kind\n");
                    break;
            }
        }
        else printf("Unknown node kind\n");
        for (i=0;i<MAXCHILDREN;i++)
            printTree(tree->child[i]);
        tree = tree->sibling;
    }
    UNINDENT;
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
