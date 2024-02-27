#ifndef _treeNode_H_
#define _treeNode_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <stdbool.h>

typedef enum
{
    P_IF, P_ELSE, P_ELSIF, P_WHILE, P_LOOP, P_LOOPFOREVER, P_COMPOUND, P_RANGE, P_RETURN, P_BREAK,
    P_INT, P_CHAR, P_BOOLEAN, P_VOID, P_STATIC, P_TRUE, P_FALSE,
    P_ID, P_NUM, P_CHARCONST, P_STRINGCONST,
    P_ASSIGN, P_EQ, P_NE, P_LT, P_LE, P_GT, P_GE, P_PLUS, P_MINUS, P_TIMES, P_OVER, P_MOD, P_NOT, P_AND, P_OR,
    P_LPAREN, P_RPAREN, P_LBRACKET, P_RBRACKET, P_LBRACE, P_RBRACE, P_SEMI, P_COMMA, P_COLON, P_DOT, P_RANGEOP,
    P_ENDFILE, P_ERROR, P_LTE, P_GTE, P_NEQ
} TokenType;

extern FILE *source;
extern FILE *listing;
extern FILE *code;
extern int lineno;


// Kinds of Operators
// these are the token numbers for the operators same as in flex
typedef int OpKind;  

// Kinds of Statements
typedef enum {DeclK, StmtK, ExpK} NodeKind;

// Subkinds of Declarations
typedef enum {VarK, FuncK, ParamK} DeclKind;

// Subkinds of Statements
typedef enum {NullK, ElsifK, IfK, WhileK, LoopK, LoopForeverK, CompoundK, RangeK, ReturnK, BreakK} StmtKind;

// Subkinds of Expressions
typedef enum {OpK, ConstantK, IdK, InitK, CallK, ArrIdK, AssignK, ArgK, NullExpK} ExpKind;

// ExpType is used for type checking (Void means no type or value, UndefinedType means undefined)
typedef enum {Void, Integer, Boolean, Char, CharInt, Equal, UndefinedType, String} ExpType;

// What kind of scoping is used?  (decided during typing)
typedef enum {None, Local, Global, Parameter, LocalStatic} VarKind;

#define MAXCHILDREN 3



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
        OpKind op;                         // type of token (same as in bison)
	int value;                         // used when an integer constant or boolean
    unsigned char cvalue;               // used when a character
	char *string;                      // used when a string constant
	char *name;                        // used when IdK
    } attr;                                 
    ExpType expType;		           // used when ExpK for type checking
    bool isArray;                          // is this an array
    bool isStatic;                         // is staticly allocated?   
    int arraySize;                         // the size of the array             

    // even more semantic stuff will go here in later assignments.
} TreeNode;


#endif
