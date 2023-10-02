/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

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

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     DEFINED_SYMBOL = 258,
     LOCAL_SYMBOL = 259,
     FUTURE_REFERENCE = 260,
     LOC = 261,
     END = 262,
     UNDEF = 263,
     DEF = 264,
     NUMBER = 265,
     ASTERISK = 266,
     TEXT = 267,
     ALF = 268,
     PSEUDO = 269,
     OPCODE = 270,
     BOGUS = 271,
     SLASHES = 272,
     UMINUS = 273
   };
#endif
/* Tokens.  */
#define DEFINED_SYMBOL 258
#define LOCAL_SYMBOL 259
#define FUTURE_REFERENCE 260
#define LOC 261
#define END 262
#define UNDEF 263
#define DEF 264
#define NUMBER 265
#define ASTERISK 266
#define TEXT 267
#define ALF 268
#define PSEUDO 269
#define OPCODE 270
#define BOGUS 271
#define SLASHES 272
#define UMINUS 273




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 82 "mixal.y"
{
unsigned val;
Symbol*symp;
char*txt;
char literal[6];
struct mix_op*opcode;
}
/* Line 1489 of yacc.c.  */
#line 93 "mixal.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

