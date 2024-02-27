#include "treeNode.h"
#include "scanType.h"

#ifndef _treeUtil_H_
#define _treeUtil_H_

void printToken(TokenType, const char *);

TreeNode * newStmtNode(StmtKind, int lineo);

TreeNode * newExpNode(ExpKind, int lineo);

char * copyString(char *);

void printTree(TreeNode *);

TreeNode *addSibling(TreeNode *t, TreeNode *s);

void setType(TreeNode *t, ExpType type, bool isStatic);

#endif
