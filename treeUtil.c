#include "treeUtil.h"
#include "treeNode.h"

void printToken(TokenType token, const char* tokenString)
{ switch (token)
    { case IF: 
      case ELSE: 
      case INT: 
      case RETURN: 
      case VOID: 
      case WHILE:
        printf("reserved word: %s\n",tokenString);
        break;
    case ASSIGN: printf("=\n"); break;
    case EQ: printf("==\n"); break;
    case LT: printf("<\n"); break;
    case LTE: printf("<=\n"); break;
    case GT: printf(">\n"); break;
    case GTE: printf(">=\n"); break;
    case NEQ: printf("!=\n"); break;
    case LPAREN: printf("(\n"); break;
    case RPAREN: printf(")\n"); break;
    case LBRACKET: printf("[\n"); break;
    case RBRACKET: printf("]\n"); break;
    case LBRACE: printf("{\n"); break;
    case RBRACE: printf("}\n"); break;
    case SEMI: printf(";\n"); break;
    case COMMA: printf(",\n"); break;
    case PLUS: printf("+\n"); break;
    case MINUS: printf("-\n"); break;
    case TIMES: printf("*\n"); break;
    case OVER: printf("/\n"); break;
    case ENDFILE: printf("EOF\n"); break;
    case NUM:
        printf("NUM, val= %s\n",tokenString);
        break;
    case ID:
        printf("ID, name= %s\n",tokenString);
        break;
    case ERROR:
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

