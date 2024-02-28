/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_PARSER_TAB_H_INCLUDED
# define YY_YY_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    IF = 258,
    THEN = 259,
    ELSE = 260,
    WHILE = 261,
    DO = 262,
    FOR = 263,
    TO = 264,
    BY = 265,
    RETURN = 266,
    BREAK = 267,
    OR = 268,
    AND = 269,
    NOT = 270,
    STATIC = 271,
    BOOL = 272,
    CHAR = 273,
    INT = 274,
    ID = 275,
    NUMCONST = 276,
    CHARCONST = 277,
    STRINGCONST = 278,
    TRUE = 279,
    FALSE = 280,
    EQ = 281,
    LT = 282,
    PLUS = 283,
    LTEQ = 284,
    GT = 285,
    GTEQ = 286,
    MINUS = 287,
    TIMES = 288,
    OVER = 289,
    LPAREN = 290,
    RPAREN = 291,
    SEMI = 292,
    COMMA = 293,
    COLON = 294,
    ERROR = 295,
    LBRACK = 296,
    RBRACK = 297,
    LCURLY = 298,
    RCURLY = 299,
    PLUSEQ = 300,
    MINUSEQ = 301,
    TIMESEQ = 302,
    DIVEQ = 303,
    PLUSPLUS = 304,
    MINUSMINUS = 305,
    EQEQ = 306,
    NOTEQ = 307,
    SEMIGT = 308,
    SEMILT = 309,
    MOD = 310,
    QUESTION = 311,
    DIVIDE = 312
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 42 "parser.y"

    TokenData *tokenData;
    TreeNode *tree;

#line 120 "parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_TAB_H_INCLUDED  */
