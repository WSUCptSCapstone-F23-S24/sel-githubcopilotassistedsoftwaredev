// utilities to build the tree
#include "TreeUtils.h"
#include "treeNodes.h"
/****************************************************/
/* File: util.c                                     */
/* Utility function implementation                  */
/* for the TINY compiler                            */
/* Compiler Construction: Principles and Practice   */
/* Kenneth C. Louden                                */
/****************************************************/
/* Procedure printToken prints a token 
 * and its lexeme to the  file
 */
void printToken( TokenType token, const char* tokenString )
{ switch (token)
  { case IF:
    case THEN:
    case ELSE:
    case END:
    case ASSIGN: printf(":=\n"); break;
    case LT: printf("<\n"); break;
    case EQ: printf("=\n"); break;
    case LPAREN: printf("(\n"); break;
    case RPAREN: printf(")\n"); break;
    case SEMI: printf(";\n"); break;
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

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    printf("Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = StmtK;
    t->subkind.stmt = kind;
    t->lineno = lineno;
  }
  return t;
}

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind kind)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    printf("Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = ExpK;
    t->subkind.exp = kind;
    t->lineno = lineno;
    t->expType = Void;
  }
  return t;
}

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString(char * s)
{ int n;
  char * t;
  if (s==NULL) return NULL;
  n = strlen(s)+1;
  t = malloc(n);
  if (t==NULL)
    printf("Out of memory error at line %d\n",lineno);
  else strcpy(t,s);
  return t;
}

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(void)
{ int i;
  for (i=0;i<indentno;i++)
    printf(" ");
}

/* procedure printTree prints a syntax tree to the 
 *  file using indentation to indicate subtrees
 */
void printTree( TreeNode * tree )
{ int i;
  INDENT;
  while (tree != NULL) {
    printSpaces();
    if (tree->nodekind==StmtK)
    { switch (tree->subkind.stmt) {
        case IfK:
          printf("If\n");
          break;
        case RepeatK:
          printf("Repeat\n");
          break;
        case AssignK:
          printf("Assign to: %s\n",tree->attr.name);
          break;
        case WriteK:
          printf("Write\n");
          break;
        default:
          printf("Unknown ExpNode kind\n");
          break;
      }
    }
    else if (tree->nodekind==ExpK)
    { switch (tree->subkind.exp) {
        case OpK:
          printf("Op: ");
          printToken(tree->attr.op,"\0");
          break;
        case ConstK:
          printf("Const: %d\n",tree->attr.value);
          break;
        case IdK:
          printf("Id: %s\n",tree->attr.name);
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