#include "treeNodes.h"
#include "scanType.h"

#ifndef _UTIL_H_
#define _UTIL_H_
typedef enum 
    /* book-keeping tokens */
   {IF, THEN, ELSE, WHILE, DO, FOR, TO, BY, RETURN, BREAK, OR, AND, NOT, STATIC, BOOL, CHAR, INT,
 ID, NUMCONST, CHARCONST, STRINGCONST, TRUE, FALSE, ASSIGN, EQ, LT, PLUS, LTEQ, GT, GTEQ,
 MINUS, TIMES, OVER, LPAREN, RPAREN, SEMI, COMMA, COLON, ERROR, LBRACK, RBRACK, NOTHING,
 LCURLY, RCURLY, PLUSEQ, MINUSEQ ,TIMESEQ, DIVEQ ,PLUSPLUS ,MINUSMINUS, EQEQ, NOTEQ,
 SEMIGT ,SEMILT, MOD, QUESTION, DIVIDE, END, ENDFILE, NUM
   } TokenType;
extern int lineno; /* source line number for listing */
extern FILE* source; /* source code text file */
extern FILE* listing; /* listing output text file */
extern FILE* code; /* code text file for TM simulator */
typedef enum {StmtK,ExpK} NodeKind;
typedef enum {IfK,RepeatK,AssignK,ReadK,WriteK} StmtKind;
typedef enum {OpK,ConstK,IdK} ExpKind;
typedef enum {Void,Integer,Boolean} ExpType;

#define MAXCHILDREN 3
/* Procedure printToken prints a token 
 * and its lexeme to the listing file
 */
void printToken( TokenType, const char* );

/* Function newStmtNode creates a new statement
 * node for syntax tree construction
 */
TreeNode * newStmtNode(StmtKind);

/* Function newExpNode creates a new expression 
 * node for syntax tree construction
 */
TreeNode * newExpNode(ExpKind);

/* Function copyString allocates and makes a new
 * copy of an existing string
 */
char * copyString( char * );

/* procedure printTree prints a syntax tree to the 
 * listing file using indentation to indicate subtrees
 */
void printTree( TreeNode * );

#endif