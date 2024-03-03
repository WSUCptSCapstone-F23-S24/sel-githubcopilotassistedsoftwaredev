// utilities to build the tree
#include "TreeUtils.h"
#include "parser.tab.h"
/* Procedure printToken prints a token 
 * and its lexeme to the  file
 */
//void printToken(OpKind type, char* token, int lineno)
//{ 
  //printf("%s [line: %d]\n", token, lineno);
  // switch (type)
  // { case IF: printf("if [line: %d]", lineno); break;
  //   case OR: printf("or [line: %d]", lineno); break;
  //   case AND: printf("and [line: %d]", lineno); break;
  //   case ELSE: printf("else [line: %d]", lineno); break;
  //   case INT: printf("int [line: %d]", lineno); break;
  //   case BOOL: printf("bool [line: %d]", lineno); break;
  //   case THEN: printf("then [line: %d]", lineno); break;
  //   case BY: printf("by [line: %d]", lineno); break;
  //   case DO: printf("do [line: %d]", lineno); break;
  //   case BREAK: printf("break [line: %d]", lineno); break;
  //   case STATIC: printf("static [line: %d]", lineno); break;
  //   case CHAR: printf("char [line: %d]", lineno); break;
  //   case TRUE: printf("true [line: %d]", lineno); break;
  //   case FALSE: printf("false [line: %d]", lineno); break;
  //   case FOR: printf("for [line: %d]", lineno); break;
  //   case TO: printf("to [line: %d]", lineno); break;
  //   case RETURN: printf("return [line: %d]", lineno); break;
  //   case NOT: printf("not [line: %d]", lineno); break;
  //   case WHILE: printf("while [line: %d]", lineno); break;
  //   case MOD: printf("%% [line: %d]", lineno); break;
  //   case EQEQ: printf("== [line: %d]", lineno); break;
  //   case NOTEQ: printf("!= [line: %d]", lineno); break;
  //   case EQ: printf("= [line: %d]", lineno); break;
  //   case PLUS: printf("+ [line: %d]", lineno); break;
  //   case PLUSPLUS: printf("++ [line: %d]", lineno); break;
  //   case PLUSEQ: printf("+= [line: %d]", lineno); break;
  //   case MINUS: printf("- [line: %d]", lineno); break;
  //   case MINUSMINUS: printf("-- [line: %d]", lineno); break;
  //   case MINUSEQ: printf("-= [line: %d]", lineno); break;
  //   case TIMES: printf("* [line: %d]", lineno); break;
  //   case TIMESEQ: printf("*= [line: %d]", lineno); break;
  //   case DIVIDE: printf("/ [line: %d]", lineno); break;
  //   case DIVEQ: printf("/= [line: %d]", lineno); break;
  //   case LT: printf("< [line: %d]", lineno); break;
  //   case SEMILT: printf(":<: [line: %d]", lineno); break;
  //   case LTEQ: printf("<= [line: %d]", lineno); break;
  //   case GT: printf("> [line: %d]", lineno); break;
  //   case SEMIGT: printf(":>: [line: %d]", lineno); break;
  //   case GTEQ: printf(">= [line: %d]", lineno); break;
  //   case LPAREN: printf("( [line: %d]", lineno); break;
  //   case RPAREN: printf(") [line: %d]", lineno); break;
  //   case LCURLY: printf("{ [line: %d]", lineno); break;
  //   case RCURLY: printf("} [line: %d]", lineno); break;
  //   case LBRACK: printf("[ [line: %d]", lineno); break;
  //   case RBRACK: printf("] [line: %d]", lineno); break;
  //   case COLON: printf(": [line: %d]", lineno); break;
  //   case SEMI: printf("; [line: %d]", lineno); break;
  //   case QUESTION: printf("? [line: %d]", lineno); break;
  //   case COMMA: printf(". [line: %d]", lineno); break;

  //   case CHARCONST:
  //     printf("CHARCONST: %s [line: %d]\n",token, lineno);
  //     break;
  //   case STRINGCONST:
  //     printf("STRINGCONST: %s [line: %d]\n",token, lineno);
  //     break;
  //   case ID:
  //     printf("ID, name= %s [line: %d]\n",token, lineno);
  //     break;
  //   case NUMCONST:
  //     printf("NUMCONST, val= %s [line: %d]\n",token, lineno);
  //     break;

  //   default: /* should never happen */
  //     printf("Unknown token: %s [line: %d]\n",token , lineno);
  //}
//}

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind kind, int lineno)
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

TreeNode * newDeclNode(DeclKind kind, int lineno)
{ TreeNode * t = (TreeNode *) malloc(sizeof(TreeNode));
  int i;
  if (t==NULL)
    printf("Out of memory error at line %d\n",lineno);
  else {
    for (i=0;i<MAXCHILDREN;i++) t->child[i] = NULL;
    t->sibling = NULL;
    t->nodekind = DeclK;
    t->subkind.decl = kind;
    t->lineno = lineno;
  }
  return t;
}

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind kind, int lineno)
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
// char * copyString(char * s)
// { int n;
//   char * t;
//   if (s==NULL) return NULL;
//   n = strlen(s)+1;
//   t = malloc(n);
//   if (t==NULL)
//     printf("Out of memory error at line %d\n",lineno);
//   else strcpy(t,s);
//   return t;
// }

/* Variable indentno is used by printTree to
 * store current number of spaces to indent
 */
static int indentno = 0;

/* macros to increase/decrease indentation */
#define INDENT indentno+=2
#define UNINDENT indentno-=2

/* printSpaces indents by printing spaces */
static void printSpaces(int indentation)
{ int i;
  for (i=0;i<indentation;i++)
    printf(" ");
}

char * expKindtoString(ExpType expType)
{
  switch(expType)
  {
    case Void: return "void";
    case Integer: return "int";
    case Boolean: return "bool";
    case Char: return "char";
    case CharInt: return "charInt";
    case Equal: return "equal";
    case UndefinedType: return "undefinedType";
    case String: return "string";
  }
}

char * isArraytoString(TreeNode *tree)
{
  if (tree->isArray)
    return strcat(tree->attr.name," is array");
  return tree->attr.name;
}

char *isBooltoString(TreeNode *tree) {
    char *result = (char *)malloc(6); // Cast from void* to char*

    if (result == NULL) {
        // Handle memory allocation failure
        return NULL;
    }
  
    if (tree->expType == 2) {
        if (tree->attr.value == 0) {
            sprintf(result, "false");
        } else {
            sprintf(result, "true");
        }
    } else {
        // Assuming tree->attr.value is an integer. Adjust format if it's not.
        sprintf(result, "%d", tree->attr.value);
    }
    return result;
}

/* procedure printTree prints a syntax tree to the 
 *  file using indentation to indicate subtrees
 */
void printTree( TreeNode * tree, int child, int indentation, int sibling )
{ 
  if (tree == NULL) return;
  printSpaces(indentation);
  if(child >= 0){
    printf("Child: %d  ", (child));
  }
  else if(sibling >= 1){
    printf("Sibling: %d  ", (sibling));
  }
  if (tree->nodekind==StmtK)
  { switch (tree->subkind.stmt) {
      case NullK:
        printf("Null [line: %d]\n", tree->lineno);
        break;
      case ElsifK:
        printf("Else if [line: %d]\n", tree->lineno);
        break;
      case IfK:
        printf("If [line: %d]\n", tree->lineno);
        break;
      case WhileK:
        printf("While [line: %d]\n", tree->lineno);
        break;
      case LoopK:
        printf("Loop [line: %d]\n", tree->lineno);
        break;
      case LoopForeverK:
        printf("Loop Forever [line: %d]\n", tree->lineno);
        break;
      case CompoundK:
        printf("Compound [line: %d]\n", tree->lineno);
        break;
      case RangeK:
        printf("Range [line: %d]\n", tree->lineno);
        break;
      case ReturnK:
        printf("Return [line: %d]\n", tree->lineno);
        break;
      case BreakK:
        printf("Break [line: %d]\n", tree->lineno);;
        break;
      default:
        printf("Unknown ExpNode kind [line: %d]\n", tree->lineno);
        break;
    }
  }
  else if (tree->nodekind==ExpK)
  { switch (tree->subkind.exp) {
    case OpK:
      printf("Op: %s [line: %d]\n", tree->attr.name, tree->lineno);
        //printToken(tree->attr.op, tree->attr.string, tree->lineno);
        break;
      case ConstantK:
        printf("Const: of type %s: %s [line: %d]\n", expKindtoString(tree->expType), isBooltoString(tree), tree->lineno);
        break;
      case IdK:
        printf("Id: %s [line: %d]\n",tree->attr.name, tree->lineno);
        break;
      case AssignK:
        printf("Assign: %s [line: %d]\n",tree->attr.string, tree->lineno);
        break;
      case InitK:
        printf("Init: %s [line: %d]\n",tree->attr.string, tree->lineno);
        break;
      case CallK:
        printf("Call: %s [line: %d]\n",tree->attr.string, tree->lineno);
        break;
      default:
        printf("Unknown ExpNode kind [line: %d]\n", tree->lineno);
        break;
    }
  }
  else if (tree->nodekind==DeclK)
  { switch (tree->subkind.exp) {
      case VarK:
        printf("Var: %s of type %s [line: %d]\n",isArraytoString(tree), expKindtoString(tree->expType), tree->lineno);
        break;
      case FuncK:
        printf("Func: %s returns type %s [line: %d]\n",tree->attr.name, expKindtoString(tree->expType), tree->lineno);
        break;
      case ParamK:
        printf("Param: %s of type %s [line: %d]\n",isArraytoString(tree), expKindtoString(tree->expType), tree->lineno);
        break;
      default:
        printf("Unknown ExpNode kind [line: %d]\n", tree->lineno);
        break;
    }
  }
  else printf("Unknown node kind\n");
  for (int i=0;i<MAXCHILDREN;i++)
  {
    if (tree->child != NULL)
    printTree(tree->child[i], i, indentation+2, 0);
  }

  printTree(tree->sibling, -1, indentation, (sibling + 1));
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