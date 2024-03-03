#ifndef TREE_NODES_H
#define TREE_NODES_H
#include "scanType.h"
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

/* MAXRESERVED = the number of reserved words */
#define MAXRESERVED 8

//  SYNTAX TREE DESCRIPTION inspired by Louden
// 

// the exact type of the token or node involved.  These are divided into
// various "kinds" in the typedefs that follow

// Kinds of Operators
// these are the token numbers for the operators same as in flex

/*typedef enum {IF, OR, AND, ELSE, INT, BOOL, THEN, BY, DO, BREAK, STATIC, CHAR, TRUE, FALSE, FOR, TO, RETURN, NOT, WHILE,
              MOD, EQEQ, NOTEQ, EQ, PLUS, PLUSPLUS, PLUSEQ, MINUS, MINUSMINUS, MINUSEQ, TIMES, TIMESEQ, DIVIDE, DIVEQ, LT,
              SEMILT, LTEQ, GT, SEMIGT, GTEQ, LPAREN, RPAREN, LCURLY, RCURLY, LBRACK, RBRACK, COLON, SEMI, QUESTION, COMMA,
              CHARCONST, STRINGCONST, ID, NUMCONST} OpKind;  
*/
typedef int OpKind;
// Kinds of Statements
typedef enum {DeclK, StmtK, ExpK} NodeKind;

// Subkinds of Declarations
typedef enum {VarK, FuncK, ParamK} DeclKind;

// Subkinds of Statements
typedef enum {NullK, ElsifK, IfK, WhileK, LoopK, LoopForeverK, CompoundK, RangeK, ReturnK, BreakK} StmtKind;

// Subkinds of Expressions
typedef enum {OpK, ConstantK, IdK, AssignK, InitK, CallK} ExpKind;

// ExpType is used for type checking (Void means no type or value, UndefinedType means undefined)
typedef enum {Void, Integer, Boolean, Char, CharInt, Equal, UndefinedType, String} ExpType;

// What kind of scoping is used?  (decided during typing)
typedef enum {None, Local, Global, Parameter, LocalStatic} VarKind;
extern int lineno; /* source line number for listing */
extern FILE* source; /* source code text file */
extern FILE* listing; /* listing output text file */
extern FILE* code; /* code text file for TM simulator */
#define MAXCHILDREN 3                      // no more than 3 children allowed


typedef struct treeNode
{
    // connectivity in the tree
    struct treeNode *child[MAXCHILDREN];   // children of the node
    struct treeNode *sibling;              // siblings for the node

    // what kind of node
    int lineno;                            // linenum relevant to this node
    NodeKind nodekind;                     // type of this node
    union                                  // subtype of type
    {
        DeclKind decl;                     // used when DeclK
        StmtKind stmt;                     // used when StmtK
        ExpKind exp;                       // used when ExpK
    } subkind;
    
    // extra properties about the node depending on type of the node
    union                                  // relevant data to type -> attr
    {
        int op;                         // type of token (same as in bison)
        int value;                         // used when an integer constant or boolean
        unsigned char cvalue;               // used when a character
        char *string;                      // used when a string constant
        char *name;                        // used when IdK
    } attr;                                 
    ExpType expType;		           // used when ExpK for type checking
    int isArray;                          // is this an array
    int isStatic;                         // is staticly allocated?
    VarKind varKind;                       // used when IdK for scoping
    // even more semantic stuff will go here in later assignments.
} TreeNode;
#endif TREE_NODES_H