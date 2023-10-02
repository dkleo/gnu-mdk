/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton implementation for Bison's Yacc-like parsers in C

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

/* C LALR(1) parser skeleton written by Richard Stallman, by
   simplifying the original so-called "semantic" parser.  */

/* All symbols defined below should begin with yy or YY, to avoid
   infringing on user name space.  This should be done even for local
   variables, as they might otherwise be expanded by user macros.
   There are some unavoidable exceptions within include files to
   define necessary library symbols; they are noted "INFRINGES ON
   USER NAME SPACE" below.  */

/* Identify Bison output.  */
#define YYBISON 1

/* Bison version.  */
#define YYBISON_VERSION "2.3"

/* Skeleton name.  */
#define YYSKELETON_NAME "yacc.c"

/* Pure parsers.  */
#define YYPURE 0

/* Using locations.  */
#define YYLSP_NEEDED 0



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




/* Copy the first part of user declarations.  */
#line 1 "mixal.y"

#line 42 "./mixal.yw"
#ifdef HAVE_CONFIG_H
#include <config.h> 
#endif
#include <stdlib.h> 
#include <stdio.h> 
#include <stdarg.h> 
#include <sys/stat.h> 
#include <errno.h> 
#include <unistd.h> 
#include <fcntl.h> 
#include <ctype.h> 
#include <mix.h> 
#include <mixasm.h> 
#include "getopt.h"
#include "string.h"
#include "error.h"
#include "progname.h"
#include "xalloc.h"

/*:2*//*4:*/
#line 65 "./mixal.yw"


#define update_memory(A) memory[location_counter]= (A) ;lines[lineno]= location_counter++;
#define LIST_SUFFIX ".lst" \


#line 66 "./mixal.yw"


char*source_file= NULL;

char*listfile;
FILE*lst;
char*outfile;

int lineno= 1;
int location_counter= 0;
int start_location= MEMSIZE;
unsigned memory[MEMSIZE];
int lines[MEMSIZE];
int opfield;
int error_count;

/*:4*//*5:*/
#line 82 "./mixal.yw"


int list= 0;
int xref= 0;
int writeraw= 0;

/*:5*//*6:*/
#line 88 "./mixal.yw"


FILE*create_temp(char*tmpl);
int word_s(unsigned w);
void symbols(void);
void end_routine(int start);
int num(char*text);
void listing();
void dumpsymtab(FILE*fp);
void resolve_forward(Symbol*f);

unsigned add_mix(unsigned a,unsigned b);
unsigned sub_mix(unsigned a,unsigned b);
unsigned div_mix(unsigned a,unsigned b);
unsigned mul_mix(unsigned a,unsigned b);
unsigned w_eval(unsigned a,unsigned b,int f);

/*:6*//*7:*/
#line 105 "./mixal.yw"




/* Enabling traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif

/* Enabling verbose error messages.  */
#ifdef YYERROR_VERBOSE
# undef YYERROR_VERBOSE
# define YYERROR_VERBOSE 1
#else
# define YYERROR_VERBOSE 0
#endif

/* Enabling the token table.  */
#ifndef YYTOKEN_TABLE
# define YYTOKEN_TABLE 0
#endif

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
/* Line 187 of yacc.c.  */
#line 219 "mixal.c"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif



/* Copy the second part of user declarations.  */


/* Line 216 of yacc.c.  */
#line 232 "mixal.c"

#ifdef short
# undef short
#endif

#ifdef YYTYPE_UINT8
typedef YYTYPE_UINT8 yytype_uint8;
#else
typedef unsigned char yytype_uint8;
#endif

#ifdef YYTYPE_INT8
typedef YYTYPE_INT8 yytype_int8;
#elif (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
typedef signed char yytype_int8;
#else
typedef short int yytype_int8;
#endif

#ifdef YYTYPE_UINT16
typedef YYTYPE_UINT16 yytype_uint16;
#else
typedef unsigned short int yytype_uint16;
#endif

#ifdef YYTYPE_INT16
typedef YYTYPE_INT16 yytype_int16;
#else
typedef short int yytype_int16;
#endif

#ifndef YYSIZE_T
# ifdef __SIZE_TYPE__
#  define YYSIZE_T __SIZE_TYPE__
# elif defined size_t
#  define YYSIZE_T size_t
# elif ! defined YYSIZE_T && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#  include <stddef.h> /* INFRINGES ON USER NAME SPACE */
#  define YYSIZE_T size_t
# else
#  define YYSIZE_T unsigned int
# endif
#endif

#define YYSIZE_MAXIMUM ((YYSIZE_T) -1)

#ifndef YY_
# if YYENABLE_NLS
#  if ENABLE_NLS
#   include <libintl.h> /* INFRINGES ON USER NAME SPACE */
#   define YY_(msgid) dgettext ("bison-runtime", msgid)
#  endif
# endif
# ifndef YY_
#  define YY_(msgid) msgid
# endif
#endif

/* Suppress unused-variable warnings by "using" E.  */
#if ! defined lint || defined __GNUC__
# define YYUSE(e) ((void) (e))
#else
# define YYUSE(e) /* empty */
#endif

/* Identity function, used to suppress warnings about constant conditions.  */
#ifndef lint
# define YYID(n) (n)
#else
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static int
YYID (int i)
#else
static int
YYID (i)
    int i;
#endif
{
  return i;
}
#endif

#if ! defined yyoverflow || YYERROR_VERBOSE

/* The parser invokes alloca or malloc; define the necessary symbols.  */

# ifdef YYSTACK_USE_ALLOCA
#  if YYSTACK_USE_ALLOCA
#   ifdef __GNUC__
#    define YYSTACK_ALLOC __builtin_alloca
#   elif defined __BUILTIN_VA_ARG_INCR
#    include <alloca.h> /* INFRINGES ON USER NAME SPACE */
#   elif defined _AIX
#    define YYSTACK_ALLOC __alloca
#   elif defined _MSC_VER
#    include <malloc.h> /* INFRINGES ON USER NAME SPACE */
#    define alloca _alloca
#   else
#    define YYSTACK_ALLOC alloca
#    if ! defined _ALLOCA_H && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
#     include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#     ifndef _STDLIB_H
#      define _STDLIB_H 1
#     endif
#    endif
#   endif
#  endif
# endif

# ifdef YYSTACK_ALLOC
   /* Pacify GCC's `empty if-body' warning.  */
#  define YYSTACK_FREE(Ptr) do { /* empty */; } while (YYID (0))
#  ifndef YYSTACK_ALLOC_MAXIMUM
    /* The OS might guarantee only one guard page at the bottom of the stack,
       and a page size can be as small as 4096 bytes.  So we cannot safely
       invoke alloca (N) if N exceeds 4096.  Use a slightly smaller number
       to allow for a few compiler-allocated temporary stack slots.  */
#   define YYSTACK_ALLOC_MAXIMUM 4032 /* reasonable circa 2006 */
#  endif
# else
#  define YYSTACK_ALLOC YYMALLOC
#  define YYSTACK_FREE YYFREE
#  ifndef YYSTACK_ALLOC_MAXIMUM
#   define YYSTACK_ALLOC_MAXIMUM YYSIZE_MAXIMUM
#  endif
#  if (defined __cplusplus && ! defined _STDLIB_H \
       && ! ((defined YYMALLOC || defined malloc) \
	     && (defined YYFREE || defined free)))
#   include <stdlib.h> /* INFRINGES ON USER NAME SPACE */
#   ifndef _STDLIB_H
#    define _STDLIB_H 1
#   endif
#  endif
#  ifndef YYMALLOC
#   define YYMALLOC malloc
#   if ! defined malloc && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void *malloc (YYSIZE_T); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
#  ifndef YYFREE
#   define YYFREE free
#   if ! defined free && ! defined _STDLIB_H && (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
void free (void *); /* INFRINGES ON USER NAME SPACE */
#   endif
#  endif
# endif
#endif /* ! defined yyoverflow || YYERROR_VERBOSE */


#if (! defined yyoverflow \
     && (! defined __cplusplus \
	 || (defined YYSTYPE_IS_TRIVIAL && YYSTYPE_IS_TRIVIAL)))

/* A type that is properly aligned for any stack member.  */
union yyalloc
{
  yytype_int16 yyss;
  YYSTYPE yyvs;
  };

/* The size of the maximum gap between one aligned stack and the next.  */
# define YYSTACK_GAP_MAXIMUM (sizeof (union yyalloc) - 1)

/* The size of an array large to enough to hold all stacks, each with
   N elements.  */
# define YYSTACK_BYTES(N) \
     ((N) * (sizeof (yytype_int16) + sizeof (YYSTYPE)) \
      + YYSTACK_GAP_MAXIMUM)

/* Copy COUNT objects from FROM to TO.  The source and destination do
   not overlap.  */
# ifndef YYCOPY
#  if defined __GNUC__ && 1 < __GNUC__
#   define YYCOPY(To, From, Count) \
      __builtin_memcpy (To, From, (Count) * sizeof (*(From)))
#  else
#   define YYCOPY(To, From, Count)		\
      do					\
	{					\
	  YYSIZE_T yyi;				\
	  for (yyi = 0; yyi < (Count); yyi++)	\
	    (To)[yyi] = (From)[yyi];		\
	}					\
      while (YYID (0))
#  endif
# endif

/* Relocate STACK from its old location to the new one.  The
   local variables YYSIZE and YYSTACKSIZE give the old and new number of
   elements in the stack, and YYPTR gives the new location of the
   stack.  Advance YYPTR to a properly aligned location for the next
   stack.  */
# define YYSTACK_RELOCATE(Stack)					\
    do									\
      {									\
	YYSIZE_T yynewbytes;						\
	YYCOPY (&yyptr->Stack, Stack, yysize);				\
	Stack = &yyptr->Stack;						\
	yynewbytes = yystacksize * sizeof (*Stack) + YYSTACK_GAP_MAXIMUM; \
	yyptr += yynewbytes / sizeof (*yyptr);				\
      }									\
    while (YYID (0))

#endif

/* YYFINAL -- State number of the termination state.  */
#define YYFINAL  6
/* YYLAST -- Last index in YYTABLE.  */
#define YYLAST   85

/* YYNTOKENS -- Number of terminals.  */
#define YYNTOKENS  29
/* YYNNTS -- Number of nonterminals.  */
#define YYNNTS  15
/* YYNRULES -- Number of rules.  */
#define YYNRULES  40
/* YYNRULES -- Number of states.  */
#define YYNSTATES  63

/* YYTRANSLATE(YYLEX) -- Bison symbol number corresponding to YYLEX.  */
#define YYUNDEFTOK  2
#define YYMAXUTOK   273

#define YYTRANSLATE(YYX)						\
  ((unsigned int) (YYX) <= YYMAXUTOK ? yytranslate[YYX] : YYUNDEFTOK)

/* YYTRANSLATE[YYLEX] -- Bison symbol number corresponding to YYLEX.  */
static const yytype_uint8 yytranslate[] =
{
       0,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      24,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
      26,    27,    19,    18,    25,    17,     2,    20,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,    21,     2,
       2,    28,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
       2,     2,     2,     2,     2,     2,     1,     2,     3,     4,
       5,     6,     7,     8,     9,    10,    11,    12,    13,    14,
      15,    16,    22,    23
};

#if YYDEBUG
/* YYPRHS[YYN] -- Index of the first RHS symbol of rule number YYN in
   YYRHS.  */
static const yytype_uint8 yyprhs[] =
{
       0,     0,     3,     7,    12,    16,    18,    21,    27,    31,
      34,    36,    37,    39,    40,    42,    44,    46,    48,    51,
      54,    58,    62,    66,    70,    74,    78,    80,    82,    84,
      86,    87,    89,    91,    93,    94,    97,    98,   102,   105,
     110
};

/* YYRHS -- A `-1'-separated list of the rules' RHS.  */
static const yytype_int8 yyrhs[] =
{
      30,     0,    -1,    32,    34,    31,    -1,    30,    32,    34,
      31,    -1,    30,     1,    31,    -1,    24,    -1,    31,    24,
      -1,    33,    35,    39,    40,    41,    -1,    33,    36,    42,
      -1,    33,    13,    -1,    11,    -1,    -1,     6,    -1,    -1,
      12,    -1,    15,    -1,    14,    -1,    38,    -1,    18,    38,
      -1,    17,    38,    -1,    37,    18,    38,    -1,    37,    17,
      38,    -1,    37,    11,    38,    -1,    37,    20,    38,    -1,
      37,    22,    38,    -1,    37,    21,    38,    -1,    10,    -1,
      11,    -1,     3,    -1,     4,    -1,    -1,    37,    -1,     5,
      -1,    43,    -1,    -1,    25,    37,    -1,    -1,    26,    37,
      27,    -1,    37,    41,    -1,    42,    25,    37,    41,    -1,
      28,    42,    28,    -1
};

/* YYRLINE[YYN] -- source line where rule number YYN was defined.  */
static const yytype_uint16 yyrline[] =
{
       0,   122,   122,   123,   126,   134,   138,   144,   154,   174,
     179,   183,   187,   201,   202,   207,   214,   221,   222,   227,
     232,   237,   242,   247,   252,   257,   264,   265,   270,   278,
     286,   290,   291,   300,   308,   312,   320,   324,   331,   336,
     343
};
#endif

#if YYDEBUG || YYERROR_VERBOSE || YYTOKEN_TABLE
/* YYTNAME[SYMBOL-NUM] -- String name of the symbol SYMBOL-NUM.
   First, the terminals, then, starting at YYNTOKENS, nonterminals.  */
static const char *const yytname[] =
{
  "$end", "error", "$undefined", "DEFINED_SYMBOL", "LOCAL_SYMBOL",
  "FUTURE_REFERENCE", "LOC", "END", "UNDEF", "DEF", "NUMBER", "ASTERISK",
  "TEXT", "ALF", "PSEUDO", "OPCODE", "BOGUS", "'-'", "'+'", "'*'", "'/'",
  "':'", "SLASHES", "UMINUS", "'\\n'", "','", "'('", "')'", "'='",
  "$accept", "statement_list", "eol", "statement", "label", "comment",
  "op", "pseudo", "expression", "atomic_expression", "a_part", "i_part",
  "f_part", "w_value", "literal_constant", 0
};
#endif

# ifdef YYPRINT
/* YYTOKNUM[YYLEX-NUM] -- Internal token number corresponding to
   token YYLEX-NUM.  */
static const yytype_uint16 yytoknum[] =
{
       0,   256,   257,   258,   259,   260,   261,   262,   263,   264,
     265,   266,   267,   268,   269,   270,   271,    45,    43,    42,
      47,    58,   272,   273,    10,    44,    40,    41,    61
};
# endif

/* YYR1[YYN] -- Symbol number of symbol that rule YYN derives.  */
static const yytype_uint8 yyr1[] =
{
       0,    29,    30,    30,    30,    31,    31,    32,    32,    32,
      32,    33,    33,    34,    34,    35,    36,    37,    37,    37,
      37,    37,    37,    37,    37,    37,    38,    38,    38,    38,
      39,    39,    39,    39,    40,    40,    41,    41,    42,    42,
      43
};

/* YYR2[YYN] -- Number of symbols composing right hand side of rule YYN.  */
static const yytype_uint8 yyr2[] =
{
       0,     2,     3,     4,     3,     1,     2,     5,     3,     2,
       1,     0,     1,     0,     1,     1,     1,     1,     2,     2,
       3,     3,     3,     3,     3,     3,     1,     1,     1,     1,
       0,     1,     1,     1,     0,     2,     0,     3,     2,     4,
       3
};

/* YYDEFACT[STATE-NAME] -- Default rule to reduce with in state
   STATE-NUM when YYTABLE doesn't specify something else to do.  Zero
   means the default is an error.  */
static const yytype_uint8 yydefact[] =
{
      11,    12,    10,     0,    13,     0,     1,     0,    13,    14,
       0,     9,    16,    15,    30,     0,     5,     4,     0,     2,
      28,    29,    32,    26,    27,     0,     0,     0,    31,    17,
      34,    33,    36,     8,     6,     3,    19,    18,     0,     0,
       0,     0,     0,     0,     0,     0,    36,     0,    38,     0,
      40,    22,    21,    20,    23,    25,    24,    35,     7,     0,
      36,    37,    39
};

/* YYDEFGOTO[NTERM-NUM].  */
static const yytype_int8 yydefgoto[] =
{
      -1,     3,    17,     4,     5,    10,    14,    15,    32,    29,
      30,    46,    48,    33,    31
};

/* YYPACT[STATE-NUM] -- Index in YYTABLE of the portion describing
   STATE-NUM.  */
#define YYPACT_NINF -37
static const yytype_int8 yypact[] =
{
      21,   -37,   -37,    42,    -1,    55,   -37,   -12,    -1,   -37,
     -12,   -37,   -37,   -37,    -2,    61,   -37,     4,   -12,     4,
     -37,   -37,   -37,   -37,   -37,     3,     3,    61,    63,   -37,
       9,   -37,    41,    13,   -37,     4,   -37,   -37,    22,     3,
       3,     3,     3,     3,     3,    61,    18,    61,   -37,    61,
     -37,   -37,   -37,   -37,   -37,   -37,   -37,    63,   -37,    19,
      41,   -37,   -37
};

/* YYPGOTO[NTERM-NUM].  */
static const yytype_int8 yypgoto[] =
{
     -37,   -37,     7,    26,   -37,    37,   -37,   -37,   -14,   -21,
     -37,   -37,   -36,    24,   -37
};

/* YYTABLE[YYPACT[STATE-NUM]].  What to do in state STATE-NUM.  If
   positive, shift that token.  If negative, reduce the rule which
   number is the opposite.  If zero, do what YYDEFACT says.
   If YYTABLE_NINF, syntax error.  */
#define YYTABLE_NINF -12
static const yytype_int8 yytable[] =
{
      28,    20,    21,    22,    36,    37,    20,    21,    23,    24,
      58,     9,    16,    23,    24,    25,    26,    19,    51,    52,
      53,    54,    55,    56,    62,    35,    27,     1,    34,     8,
      39,    57,     2,    59,    45,    60,    40,    41,    49,    42,
      43,    44,     6,     7,    47,    18,    61,    49,     1,     0,
      50,    38,    39,     2,     0,   -11,   -11,   -11,    40,    41,
       0,    42,    43,    44,    20,    21,     0,    47,    11,    12,
      13,    23,    24,     0,    39,     0,     0,     0,    25,    26,
      40,    41,     0,    42,    43,    44
};

static const yytype_int8 yycheck[] =
{
      14,     3,     4,     5,    25,    26,     3,     4,    10,    11,
      46,    12,    24,    10,    11,    17,    18,    10,    39,    40,
      41,    42,    43,    44,    60,    18,    28,     6,    24,     3,
      11,    45,    11,    47,    25,    49,    17,    18,    25,    20,
      21,    22,     0,     1,    26,     8,    27,    25,     6,    -1,
      28,    27,    11,    11,    -1,    13,    14,    15,    17,    18,
      -1,    20,    21,    22,     3,     4,    -1,    26,    13,    14,
      15,    10,    11,    -1,    11,    -1,    -1,    -1,    17,    18,
      17,    18,    -1,    20,    21,    22
};

/* YYSTOS[STATE-NUM] -- The (internal number of the) accessing
   symbol of state STATE-NUM.  */
static const yytype_uint8 yystos[] =
{
       0,     6,    11,    30,    32,    33,     0,     1,    32,    12,
      34,    13,    14,    15,    35,    36,    24,    31,    34,    31,
       3,     4,     5,    10,    11,    17,    18,    28,    37,    38,
      39,    43,    37,    42,    24,    31,    38,    38,    42,    11,
      17,    18,    20,    21,    22,    25,    40,    26,    41,    25,
      28,    38,    38,    38,    38,    38,    38,    37,    41,    37,
      37,    27,    41
};

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		(-2)
#define YYEOF		0

#define YYACCEPT	goto yyacceptlab
#define YYABORT		goto yyabortlab
#define YYERROR		goto yyerrorlab


/* Like YYERROR except do call yyerror.  This remains here temporarily
   to ease the transition to the new meaning of YYERROR, for GCC.
   Once GCC version 2 has supplanted version 1, this can go.  */

#define YYFAIL		goto yyerrlab

#define YYRECOVERING()  (!!yyerrstatus)

#define YYBACKUP(Token, Value)					\
do								\
  if (yychar == YYEMPTY && yylen == 1)				\
    {								\
      yychar = (Token);						\
      yylval = (Value);						\
      yytoken = YYTRANSLATE (yychar);				\
      YYPOPSTACK (1);						\
      goto yybackup;						\
    }								\
  else								\
    {								\
      yyerror (YY_("syntax error: cannot back up")); \
      YYERROR;							\
    }								\
while (YYID (0))


#define YYTERROR	1
#define YYERRCODE	256


/* YYLLOC_DEFAULT -- Set CURRENT to span from RHS[1] to RHS[N].
   If N is 0, then set CURRENT to the empty location which ends
   the previous symbol: RHS[0] (always defined).  */

#define YYRHSLOC(Rhs, K) ((Rhs)[K])
#ifndef YYLLOC_DEFAULT
# define YYLLOC_DEFAULT(Current, Rhs, N)				\
    do									\
      if (YYID (N))                                                    \
	{								\
	  (Current).first_line   = YYRHSLOC (Rhs, 1).first_line;	\
	  (Current).first_column = YYRHSLOC (Rhs, 1).first_column;	\
	  (Current).last_line    = YYRHSLOC (Rhs, N).last_line;		\
	  (Current).last_column  = YYRHSLOC (Rhs, N).last_column;	\
	}								\
      else								\
	{								\
	  (Current).first_line   = (Current).last_line   =		\
	    YYRHSLOC (Rhs, 0).last_line;				\
	  (Current).first_column = (Current).last_column =		\
	    YYRHSLOC (Rhs, 0).last_column;				\
	}								\
    while (YYID (0))
#endif


/* YY_LOCATION_PRINT -- Print the location on the stream.
   This macro was not mandated originally: define only if we know
   we won't break user code: when these are the locations we know.  */

#ifndef YY_LOCATION_PRINT
# if YYLTYPE_IS_TRIVIAL
#  define YY_LOCATION_PRINT(File, Loc)			\
     fprintf (File, "%d.%d-%d.%d",			\
	      (Loc).first_line, (Loc).first_column,	\
	      (Loc).last_line,  (Loc).last_column)
# else
#  define YY_LOCATION_PRINT(File, Loc) ((void) 0)
# endif
#endif


/* YYLEX -- calling `yylex' with the right arguments.  */

#ifdef YYLEX_PARAM
# define YYLEX yylex (YYLEX_PARAM)
#else
# define YYLEX yylex ()
#endif

/* Enable debugging if requested.  */
#if YYDEBUG

# ifndef YYFPRINTF
#  include <stdio.h> /* INFRINGES ON USER NAME SPACE */
#  define YYFPRINTF fprintf
# endif

# define YYDPRINTF(Args)			\
do {						\
  if (yydebug)					\
    YYFPRINTF Args;				\
} while (YYID (0))

# define YY_SYMBOL_PRINT(Title, Type, Value, Location)			  \
do {									  \
  if (yydebug)								  \
    {									  \
      YYFPRINTF (stderr, "%s ", Title);					  \
      yy_symbol_print (stderr,						  \
		  Type, Value); \
      YYFPRINTF (stderr, "\n");						  \
    }									  \
} while (YYID (0))


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_value_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_value_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (!yyvaluep)
    return;
# ifdef YYPRINT
  if (yytype < YYNTOKENS)
    YYPRINT (yyoutput, yytoknum[yytype], *yyvaluep);
# else
  YYUSE (yyoutput);
# endif
  switch (yytype)
    {
      default:
	break;
    }
}


/*--------------------------------.
| Print this symbol on YYOUTPUT.  |
`--------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_symbol_print (FILE *yyoutput, int yytype, YYSTYPE const * const yyvaluep)
#else
static void
yy_symbol_print (yyoutput, yytype, yyvaluep)
    FILE *yyoutput;
    int yytype;
    YYSTYPE const * const yyvaluep;
#endif
{
  if (yytype < YYNTOKENS)
    YYFPRINTF (yyoutput, "token %s (", yytname[yytype]);
  else
    YYFPRINTF (yyoutput, "nterm %s (", yytname[yytype]);

  yy_symbol_value_print (yyoutput, yytype, yyvaluep);
  YYFPRINTF (yyoutput, ")");
}

/*------------------------------------------------------------------.
| yy_stack_print -- Print the state stack from its BOTTOM up to its |
| TOP (included).                                                   |
`------------------------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_stack_print (yytype_int16 *bottom, yytype_int16 *top)
#else
static void
yy_stack_print (bottom, top)
    yytype_int16 *bottom;
    yytype_int16 *top;
#endif
{
  YYFPRINTF (stderr, "Stack now");
  for (; bottom <= top; ++bottom)
    YYFPRINTF (stderr, " %d", *bottom);
  YYFPRINTF (stderr, "\n");
}

# define YY_STACK_PRINT(Bottom, Top)				\
do {								\
  if (yydebug)							\
    yy_stack_print ((Bottom), (Top));				\
} while (YYID (0))


/*------------------------------------------------.
| Report that the YYRULE is going to be reduced.  |
`------------------------------------------------*/

#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yy_reduce_print (YYSTYPE *yyvsp, int yyrule)
#else
static void
yy_reduce_print (yyvsp, yyrule)
    YYSTYPE *yyvsp;
    int yyrule;
#endif
{
  int yynrhs = yyr2[yyrule];
  int yyi;
  unsigned long int yylno = yyrline[yyrule];
  YYFPRINTF (stderr, "Reducing stack by rule %d (line %lu):\n",
	     yyrule - 1, yylno);
  /* The symbols being reduced.  */
  for (yyi = 0; yyi < yynrhs; yyi++)
    {
      fprintf (stderr, "   $%d = ", yyi + 1);
      yy_symbol_print (stderr, yyrhs[yyprhs[yyrule] + yyi],
		       &(yyvsp[(yyi + 1) - (yynrhs)])
		       		       );
      fprintf (stderr, "\n");
    }
}

# define YY_REDUCE_PRINT(Rule)		\
do {					\
  if (yydebug)				\
    yy_reduce_print (yyvsp, Rule); \
} while (YYID (0))

/* Nonzero means print parse trace.  It is left uninitialized so that
   multiple parsers can coexist.  */
int yydebug;
#else /* !YYDEBUG */
# define YYDPRINTF(Args)
# define YY_SYMBOL_PRINT(Title, Type, Value, Location)
# define YY_STACK_PRINT(Bottom, Top)
# define YY_REDUCE_PRINT(Rule)
#endif /* !YYDEBUG */


/* YYINITDEPTH -- initial size of the parser's stacks.  */
#ifndef	YYINITDEPTH
# define YYINITDEPTH 200
#endif

/* YYMAXDEPTH -- maximum size the stacks can grow to (effective only
   if the built-in stack extension method is used).

   Do not make this value too large; the results are undefined if
   YYSTACK_ALLOC_MAXIMUM < YYSTACK_BYTES (YYMAXDEPTH)
   evaluated with infinite-precision integer arithmetic.  */

#ifndef YYMAXDEPTH
# define YYMAXDEPTH 10000
#endif



#if YYERROR_VERBOSE

# ifndef yystrlen
#  if defined __GLIBC__ && defined _STRING_H
#   define yystrlen strlen
#  else
/* Return the length of YYSTR.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static YYSIZE_T
yystrlen (const char *yystr)
#else
static YYSIZE_T
yystrlen (yystr)
    const char *yystr;
#endif
{
  YYSIZE_T yylen;
  for (yylen = 0; yystr[yylen]; yylen++)
    continue;
  return yylen;
}
#  endif
# endif

# ifndef yystpcpy
#  if defined __GLIBC__ && defined _STRING_H && defined _GNU_SOURCE
#   define yystpcpy stpcpy
#  else
/* Copy YYSRC to YYDEST, returning the address of the terminating '\0' in
   YYDEST.  */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static char *
yystpcpy (char *yydest, const char *yysrc)
#else
static char *
yystpcpy (yydest, yysrc)
    char *yydest;
    const char *yysrc;
#endif
{
  char *yyd = yydest;
  const char *yys = yysrc;

  while ((*yyd++ = *yys++) != '\0')
    continue;

  return yyd - 1;
}
#  endif
# endif

# ifndef yytnamerr
/* Copy to YYRES the contents of YYSTR after stripping away unnecessary
   quotes and backslashes, so that it's suitable for yyerror.  The
   heuristic is that double-quoting is unnecessary unless the string
   contains an apostrophe, a comma, or backslash (other than
   backslash-backslash).  YYSTR is taken from yytname.  If YYRES is
   null, do not copy; instead, return the length of what the result
   would have been.  */
static YYSIZE_T
yytnamerr (char *yyres, const char *yystr)
{
  if (*yystr == '"')
    {
      YYSIZE_T yyn = 0;
      char const *yyp = yystr;

      for (;;)
	switch (*++yyp)
	  {
	  case '\'':
	  case ',':
	    goto do_not_strip_quotes;

	  case '\\':
	    if (*++yyp != '\\')
	      goto do_not_strip_quotes;
	    /* Fall through.  */
	  default:
	    if (yyres)
	      yyres[yyn] = *yyp;
	    yyn++;
	    break;

	  case '"':
	    if (yyres)
	      yyres[yyn] = '\0';
	    return yyn;
	  }
    do_not_strip_quotes: ;
    }

  if (! yyres)
    return yystrlen (yystr);

  return yystpcpy (yyres, yystr) - yyres;
}
# endif

/* Copy into YYRESULT an error message about the unexpected token
   YYCHAR while in state YYSTATE.  Return the number of bytes copied,
   including the terminating null byte.  If YYRESULT is null, do not
   copy anything; just return the number of bytes that would be
   copied.  As a special case, return 0 if an ordinary "syntax error"
   message will do.  Return YYSIZE_MAXIMUM if overflow occurs during
   size calculation.  */
static YYSIZE_T
yysyntax_error (char *yyresult, int yystate, int yychar)
{
  int yyn = yypact[yystate];

  if (! (YYPACT_NINF < yyn && yyn <= YYLAST))
    return 0;
  else
    {
      int yytype = YYTRANSLATE (yychar);
      YYSIZE_T yysize0 = yytnamerr (0, yytname[yytype]);
      YYSIZE_T yysize = yysize0;
      YYSIZE_T yysize1;
      int yysize_overflow = 0;
      enum { YYERROR_VERBOSE_ARGS_MAXIMUM = 5 };
      char const *yyarg[YYERROR_VERBOSE_ARGS_MAXIMUM];
      int yyx;

# if 0
      /* This is so xgettext sees the translatable formats that are
	 constructed on the fly.  */
      YY_("syntax error, unexpected %s");
      YY_("syntax error, unexpected %s, expecting %s");
      YY_("syntax error, unexpected %s, expecting %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s");
      YY_("syntax error, unexpected %s, expecting %s or %s or %s or %s");
# endif
      char *yyfmt;
      char const *yyf;
      static char const yyunexpected[] = "syntax error, unexpected %s";
      static char const yyexpecting[] = ", expecting %s";
      static char const yyor[] = " or %s";
      char yyformat[sizeof yyunexpected
		    + sizeof yyexpecting - 1
		    + ((YYERROR_VERBOSE_ARGS_MAXIMUM - 2)
		       * (sizeof yyor - 1))];
      char const *yyprefix = yyexpecting;

      /* Start YYX at -YYN if negative to avoid negative indexes in
	 YYCHECK.  */
      int yyxbegin = yyn < 0 ? -yyn : 0;

      /* Stay within bounds of both yycheck and yytname.  */
      int yychecklim = YYLAST - yyn + 1;
      int yyxend = yychecklim < YYNTOKENS ? yychecklim : YYNTOKENS;
      int yycount = 1;

      yyarg[0] = yytname[yytype];
      yyfmt = yystpcpy (yyformat, yyunexpected);

      for (yyx = yyxbegin; yyx < yyxend; ++yyx)
	if (yycheck[yyx + yyn] == yyx && yyx != YYTERROR)
	  {
	    if (yycount == YYERROR_VERBOSE_ARGS_MAXIMUM)
	      {
		yycount = 1;
		yysize = yysize0;
		yyformat[sizeof yyunexpected - 1] = '\0';
		break;
	      }
	    yyarg[yycount++] = yytname[yyx];
	    yysize1 = yysize + yytnamerr (0, yytname[yyx]);
	    yysize_overflow |= (yysize1 < yysize);
	    yysize = yysize1;
	    yyfmt = yystpcpy (yyfmt, yyprefix);
	    yyprefix = yyor;
	  }

      yyf = YY_(yyformat);
      yysize1 = yysize + yystrlen (yyf);
      yysize_overflow |= (yysize1 < yysize);
      yysize = yysize1;

      if (yysize_overflow)
	return YYSIZE_MAXIMUM;

      if (yyresult)
	{
	  /* Avoid sprintf, as that infringes on the user's name space.
	     Don't have undefined behavior even if the translation
	     produced a string with the wrong number of "%s"s.  */
	  char *yyp = yyresult;
	  int yyi = 0;
	  while ((*yyp = *yyf) != '\0')
	    {
	      if (*yyp == '%' && yyf[1] == 's' && yyi < yycount)
		{
		  yyp += yytnamerr (yyp, yyarg[yyi++]);
		  yyf += 2;
		}
	      else
		{
		  yyp++;
		  yyf++;
		}
	    }
	}
      return yysize;
    }
}
#endif /* YYERROR_VERBOSE */


/*-----------------------------------------------.
| Release the memory associated to this symbol.  |
`-----------------------------------------------*/

/*ARGSUSED*/
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
static void
yydestruct (const char *yymsg, int yytype, YYSTYPE *yyvaluep)
#else
static void
yydestruct (yymsg, yytype, yyvaluep)
    const char *yymsg;
    int yytype;
    YYSTYPE *yyvaluep;
#endif
{
  YYUSE (yyvaluep);

  if (!yymsg)
    yymsg = "Deleting";
  YY_SYMBOL_PRINT (yymsg, yytype, yyvaluep, yylocationp);

  switch (yytype)
    {

      default:
	break;
    }
}


/* Prevent warnings from -Wmissing-prototypes.  */

#ifdef YYPARSE_PARAM
#if defined __STDC__ || defined __cplusplus
int yyparse (void *YYPARSE_PARAM);
#else
int yyparse ();
#endif
#else /* ! YYPARSE_PARAM */
#if defined __STDC__ || defined __cplusplus
int yyparse (void);
#else
int yyparse ();
#endif
#endif /* ! YYPARSE_PARAM */



/* The look-ahead symbol.  */
int yychar;

/* The semantic value of the look-ahead symbol.  */
YYSTYPE yylval;

/* Number of syntax errors so far.  */
int yynerrs;



/*----------.
| yyparse.  |
`----------*/

#ifdef YYPARSE_PARAM
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void *YYPARSE_PARAM)
#else
int
yyparse (YYPARSE_PARAM)
    void *YYPARSE_PARAM;
#endif
#else /* ! YYPARSE_PARAM */
#if (defined __STDC__ || defined __C99__FUNC__ \
     || defined __cplusplus || defined _MSC_VER)
int
yyparse (void)
#else
int
yyparse ()

#endif
#endif
{
  
  int yystate;
  int yyn;
  int yyresult;
  /* Number of tokens to shift before error messages enabled.  */
  int yyerrstatus;
  /* Look-ahead token as an internal (translated) token number.  */
  int yytoken = 0;
#if YYERROR_VERBOSE
  /* Buffer for error messages, and its allocated size.  */
  char yymsgbuf[128];
  char *yymsg = yymsgbuf;
  YYSIZE_T yymsg_alloc = sizeof yymsgbuf;
#endif

  /* Three stacks and their tools:
     `yyss': related to states,
     `yyvs': related to semantic values,
     `yyls': related to locations.

     Refer to the stacks thru separate pointers, to allow yyoverflow
     to reallocate them elsewhere.  */

  /* The state stack.  */
  yytype_int16 yyssa[YYINITDEPTH];
  yytype_int16 *yyss = yyssa;
  yytype_int16 *yyssp;

  /* The semantic value stack.  */
  YYSTYPE yyvsa[YYINITDEPTH];
  YYSTYPE *yyvs = yyvsa;
  YYSTYPE *yyvsp;



#define YYPOPSTACK(N)   (yyvsp -= (N), yyssp -= (N))

  YYSIZE_T yystacksize = YYINITDEPTH;

  /* The variables used to return semantic value and location from the
     action routines.  */
  YYSTYPE yyval;


  /* The number of symbols on the RHS of the reduced rule.
     Keep to zero when no symbol should be popped.  */
  int yylen = 0;

  YYDPRINTF ((stderr, "Starting parse\n"));

  yystate = 0;
  yyerrstatus = 0;
  yynerrs = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.
     The wasted elements are never initialized.  */

  yyssp = yyss;
  yyvsp = yyvs;

  goto yysetstate;

/*------------------------------------------------------------.
| yynewstate -- Push a new state, which is found in yystate.  |
`------------------------------------------------------------*/
 yynewstate:
  /* In all cases, when you get here, the value and location stacks
     have just been pushed.  So pushing a state here evens the stacks.  */
  yyssp++;

 yysetstate:
  *yyssp = yystate;

  if (yyss + yystacksize - 1 <= yyssp)
    {
      /* Get the current used size of the three stacks, in elements.  */
      YYSIZE_T yysize = yyssp - yyss + 1;

#ifdef yyoverflow
      {
	/* Give user a chance to reallocate the stack.  Use copies of
	   these so that the &'s don't force the real ones into
	   memory.  */
	YYSTYPE *yyvs1 = yyvs;
	yytype_int16 *yyss1 = yyss;


	/* Each stack pointer address is followed by the size of the
	   data in use in that stack, in bytes.  This used to be a
	   conditional around just the two extra args, but that might
	   be undefined if yyoverflow is a macro.  */
	yyoverflow (YY_("memory exhausted"),
		    &yyss1, yysize * sizeof (*yyssp),
		    &yyvs1, yysize * sizeof (*yyvsp),

		    &yystacksize);

	yyss = yyss1;
	yyvs = yyvs1;
      }
#else /* no yyoverflow */
# ifndef YYSTACK_RELOCATE
      goto yyexhaustedlab;
# else
      /* Extend the stack our own way.  */
      if (YYMAXDEPTH <= yystacksize)
	goto yyexhaustedlab;
      yystacksize *= 2;
      if (YYMAXDEPTH < yystacksize)
	yystacksize = YYMAXDEPTH;

      {
	yytype_int16 *yyss1 = yyss;
	union yyalloc *yyptr =
	  (union yyalloc *) YYSTACK_ALLOC (YYSTACK_BYTES (yystacksize));
	if (! yyptr)
	  goto yyexhaustedlab;
	YYSTACK_RELOCATE (yyss);
	YYSTACK_RELOCATE (yyvs);

#  undef YYSTACK_RELOCATE
	if (yyss1 != yyssa)
	  YYSTACK_FREE (yyss1);
      }
# endif
#endif /* no yyoverflow */

      yyssp = yyss + yysize - 1;
      yyvsp = yyvs + yysize - 1;


      YYDPRINTF ((stderr, "Stack size increased to %lu\n",
		  (unsigned long int) yystacksize));

      if (yyss + yystacksize - 1 <= yyssp)
	YYABORT;
    }

  YYDPRINTF ((stderr, "Entering state %d\n", yystate));

  goto yybackup;

/*-----------.
| yybackup.  |
`-----------*/
yybackup:

  /* Do appropriate processing given the current state.  Read a
     look-ahead token if we need one and don't already have one.  */

  /* First try to decide what to do without reference to look-ahead token.  */
  yyn = yypact[yystate];
  if (yyn == YYPACT_NINF)
    goto yydefault;

  /* Not known => get a look-ahead token if don't already have one.  */

  /* YYCHAR is either YYEMPTY or YYEOF or a valid look-ahead symbol.  */
  if (yychar == YYEMPTY)
    {
      YYDPRINTF ((stderr, "Reading a token: "));
      yychar = YYLEX;
    }

  if (yychar <= YYEOF)
    {
      yychar = yytoken = YYEOF;
      YYDPRINTF ((stderr, "Now at end of input.\n"));
    }
  else
    {
      yytoken = YYTRANSLATE (yychar);
      YY_SYMBOL_PRINT ("Next token is", yytoken, &yylval, &yylloc);
    }

  /* If the proper action on seeing token YYTOKEN is to reduce or to
     detect an error, take that action.  */
  yyn += yytoken;
  if (yyn < 0 || YYLAST < yyn || yycheck[yyn] != yytoken)
    goto yydefault;
  yyn = yytable[yyn];
  if (yyn <= 0)
    {
      if (yyn == 0 || yyn == YYTABLE_NINF)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Count tokens shifted since error; after three, turn off error
     status.  */
  if (yyerrstatus)
    yyerrstatus--;

  /* Shift the look-ahead token.  */
  YY_SYMBOL_PRINT ("Shifting", yytoken, &yylval, &yylloc);

  /* Discard the shifted token unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  yystate = yyn;
  *++yyvsp = yylval;

  goto yynewstate;


/*-----------------------------------------------------------.
| yydefault -- do the default action for the current state.  |
`-----------------------------------------------------------*/
yydefault:
  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;
  goto yyreduce;


/*-----------------------------.
| yyreduce -- Do a reduction.  |
`-----------------------------*/
yyreduce:
  /* yyn is the number of a rule to reduce with.  */
  yylen = yyr2[yyn];

  /* If YYLEN is nonzero, implement the default value of the action:
     `$$ = $1'.

     Otherwise, the following line sets YYVAL to garbage.
     This behavior is undocumented and Bison
     users should not rely upon it.  Assigning to YYVAL
     unconditionally makes the parser a bit smaller, and it avoids a
     GCC warning that YYVAL may be used uninitialized.  */
  yyval = yyvsp[1-yylen];


  YY_REDUCE_PRINT (yyn);
  switch (yyn)
    {
        case 4:
#line 127 "mixal.y"
    {
#line 169 "./mixal.yw"
	yyerrok;
	yyclearin;
	reset_lex();
	}
    break;

  case 5:
#line 135 "mixal.y"
    {
#line 177 "./mixal.yw"
	lineno++;}
    break;

  case 6:
#line 139 "mixal.y"
    {
#line 179 "./mixal.yw"
	lineno++;}
    break;

  case 7:
#line 145 "mixal.y"
    {
#line 186 "./mixal.yw"
	unsigned word;
	
	word= (yyvsp[(2) - (5)].opcode)->c|SIGN((yyvsp[(3) - (5)].val))|MAG((yyvsp[(3) - (5)].val))*B3|(yyvsp[(4) - (5)].val)*B2|(yyvsp[(5) - (5)].val)*B1;
	update_memory(word);
	}
    break;

  case 8:
#line 155 "mixal.y"
    {
#line 197 "./mixal.yw"
	if(!strcmp((yyvsp[(2) - (3)].literal),"EQU")){
	
	if((yyvsp[(1) - (3)].symp)==NULL)
	dumpsymtab(stderr);
	else
	(yyvsp[(1) - (3)].symp)->value= (yyvsp[(3) - (3)].val);
	}else if(!strcmp((yyvsp[(2) - (3)].literal),"ORIG")){
	location_counter= word_s((yyvsp[(3) - (3)].val));
	}else if(!strcmp((yyvsp[(2) - (3)].literal),"CON")){
	update_memory((yyvsp[(3) - (3)].val));
	}else if(!strcmp((yyvsp[(2) - (3)].literal),"END")){
	if((yyvsp[(1) - (3)].symp)!=NULL)
	(yyvsp[(1) - (3)].symp)->type= END;
	start_location= (yyvsp[(3) - (3)].val);
	YYACCEPT;
	}
	}
    break;

  case 9:
#line 175 "mixal.y"
    {
#line 216 "./mixal.yw"
	update_memory(num((yyvsp[(2) - (2)].literal)));
	}
    break;

  case 10:
#line 179 "mixal.y"
    {;}
    break;

  case 11:
#line 183 "mixal.y"
    {
#line 225 "./mixal.yw"
	(yyval.symp)= NULL;
	}
    break;

  case 12:
#line 188 "mixal.y"
    {
#line 229 "./mixal.yw"
	if(localref((yyvsp[(1) - (1)].symp)->name,"FB")){
	yyerror("invalid label");
	YYERROR;
	}
	(yyvsp[(1) - (1)].symp)->type= DEF;
	(yyvsp[(1) - (1)].symp)->line= lineno;
	(yyvsp[(1) - (1)].symp)->value= location_counter;
	(yyval.symp)= (yyvsp[(1) - (1)].symp);
	}
    break;

  case 14:
#line 202 "mixal.y"
    {
#line 243 "./mixal.yw"
	;}
    break;

  case 15:
#line 208 "mixal.y"
    {
#line 250 "./mixal.yw"
	opfield= (yyvsp[(1) - (1)].opcode)->f;
	}
    break;

  case 16:
#line 215 "mixal.y"
    {
#line 259 "./mixal.yw"
	opfield= 5;
	}
    break;

  case 18:
#line 223 "mixal.y"
    {
#line 268 "./mixal.yw"
	(yyval.val)= (yyvsp[(2) - (2)].val);
	}
    break;

  case 19:
#line 228 "mixal.y"
    {
#line 272 "./mixal.yw"
	(yyval.val)= (yyvsp[(2) - (2)].val)^MINUS;
	}
    break;

  case 20:
#line 233 "mixal.y"
    {
#line 276 "./mixal.yw"
	(yyval.val)= add_mix((yyvsp[(1) - (3)].val),(yyvsp[(3) - (3)].val));
	}
    break;

  case 21:
#line 238 "mixal.y"
    {
#line 280 "./mixal.yw"
	(yyval.val)= sub_mix((yyvsp[(1) - (3)].val),(yyvsp[(3) - (3)].val));
	}
    break;

  case 22:
#line 243 "mixal.y"
    {
#line 284 "./mixal.yw"
	(yyval.val)= mul_mix((yyvsp[(1) - (3)].val),(yyvsp[(3) - (3)].val));
	}
    break;

  case 23:
#line 248 "mixal.y"
    {
#line 288 "./mixal.yw"
	(yyval.val)= div_mix((yyvsp[(1) - (3)].val),(yyvsp[(3) - (3)].val));
	}
    break;

  case 24:
#line 253 "mixal.y"
    {
#line 292 "./mixal.yw"
	(yyval.val)= mul_mix((yyvsp[(1) - (3)].val),B5/MAG((yyvsp[(3) - (3)].val)));
	}
    break;

  case 25:
#line 258 "mixal.y"
    {
#line 296 "./mixal.yw"
	(yyval.val)= add_mix(mul_mix((yyvsp[(1) - (3)].val),8),(yyvsp[(3) - (3)].val));
	}
    break;

  case 27:
#line 266 "mixal.y"
    {
#line 305 "./mixal.yw"
	(yyval.val)= location_counter;
	}
    break;

  case 28:
#line 271 "mixal.y"
    {
#line 309 "./mixal.yw"
	(yyval.val)= (yyvsp[(1) - (1)].symp)->value;
	if(xref)
	(yyvsp[(1) - (1)].symp)->xref= addref((yyvsp[(1) - (1)].symp)->xref,location_counter,
	lineno);
	}
    break;

  case 29:
#line 279 "mixal.y"
    {
#line 316 "./mixal.yw"
	(yyval.val)= (yyvsp[(1) - (1)].symp)->value;
	}
    break;

  case 30:
#line 286 "mixal.y"
    {
#line 324 "./mixal.yw"
	(yyval.val)= 0;
	}
    break;

  case 32:
#line 292 "mixal.y"
    {
#line 329 "./mixal.yw"
	(yyvsp[(1) - (1)].symp)->reflist= addref((yyvsp[(1) - (1)].symp)->reflist,location_counter,lineno);
	if(xref)
	(yyvsp[(1) - (1)].symp)->xref= addref((yyvsp[(1) - (1)].symp)->xref,location_counter,
	lineno);
	(yyval.val)= 0;
	}
    break;

  case 33:
#line 301 "mixal.y"
    {
#line 337 "./mixal.yw"
	(yyval.val)= 0;
	}
    break;

  case 34:
#line 308 "mixal.y"
    {
#line 345 "./mixal.yw"
	(yyval.val)= 0;
	}
    break;

  case 35:
#line 313 "mixal.y"
    {
#line 349 "./mixal.yw"
	(yyval.val)= (yyvsp[(2) - (2)].val);
	}
    break;

  case 36:
#line 320 "mixal.y"
    {
#line 357 "./mixal.yw"
	(yyval.val)= opfield;
	}
    break;

  case 37:
#line 325 "mixal.y"
    {
#line 361 "./mixal.yw"
	(yyval.val)= (yyvsp[(2) - (3)].val);
	}
    break;

  case 38:
#line 332 "mixal.y"
    {
#line 369 "./mixal.yw"
	(yyval.val)= w_eval(0,(yyvsp[(1) - (2)].val),(yyvsp[(2) - (2)].val));
	}
    break;

  case 39:
#line 337 "mixal.y"
    {
#line 373 "./mixal.yw"
	(yyval.val)= w_eval((yyvsp[(1) - (4)].val),(yyvsp[(3) - (4)].val),(yyvsp[(4) - (4)].val));
	}
    break;

  case 40:
#line 344 "mixal.y"
    {
#line 381 "./mixal.yw"
	char literal[13];
	Symbol*s;
	
	sprintf(literal,"=%d=",word_s((yyvsp[(2) - (3)].val)));
	if(!(s= lookup(literal)))
	s= install(literal,(yyvsp[(2) - (3)].val),lineno);
	s->reflist= addref(s->reflist,location_counter,lineno);
	if(xref)
	s->xref= addref(s->xref,location_counter,lineno);
	}
    break;


/* Line 1267 of yacc.c.  */
#line 1783 "mixal.c"
      default: break;
    }
  YY_SYMBOL_PRINT ("-> $$ =", yyr1[yyn], &yyval, &yyloc);

  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);

  *++yyvsp = yyval;


  /* Now `shift' the result of the reduction.  Determine what state
     that goes to, based on the state we popped back to and the rule
     number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTOKENS] + *yyssp;
  if (0 <= yystate && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTOKENS];

  goto yynewstate;


/*------------------------------------.
| yyerrlab -- here on detecting error |
`------------------------------------*/
yyerrlab:
  /* If not already recovering from an error, report this error.  */
  if (!yyerrstatus)
    {
      ++yynerrs;
#if ! YYERROR_VERBOSE
      yyerror (YY_("syntax error"));
#else
      {
	YYSIZE_T yysize = yysyntax_error (0, yystate, yychar);
	if (yymsg_alloc < yysize && yymsg_alloc < YYSTACK_ALLOC_MAXIMUM)
	  {
	    YYSIZE_T yyalloc = 2 * yysize;
	    if (! (yysize <= yyalloc && yyalloc <= YYSTACK_ALLOC_MAXIMUM))
	      yyalloc = YYSTACK_ALLOC_MAXIMUM;
	    if (yymsg != yymsgbuf)
	      YYSTACK_FREE (yymsg);
	    yymsg = (char *) YYSTACK_ALLOC (yyalloc);
	    if (yymsg)
	      yymsg_alloc = yyalloc;
	    else
	      {
		yymsg = yymsgbuf;
		yymsg_alloc = sizeof yymsgbuf;
	      }
	  }

	if (0 < yysize && yysize <= yymsg_alloc)
	  {
	    (void) yysyntax_error (yymsg, yystate, yychar);
	    yyerror (yymsg);
	  }
	else
	  {
	    yyerror (YY_("syntax error"));
	    if (yysize != 0)
	      goto yyexhaustedlab;
	  }
      }
#endif
    }



  if (yyerrstatus == 3)
    {
      /* If just tried and failed to reuse look-ahead token after an
	 error, discard it.  */

      if (yychar <= YYEOF)
	{
	  /* Return failure if at end of input.  */
	  if (yychar == YYEOF)
	    YYABORT;
	}
      else
	{
	  yydestruct ("Error: discarding",
		      yytoken, &yylval);
	  yychar = YYEMPTY;
	}
    }

  /* Else will try to reuse look-ahead token after shifting the error
     token.  */
  goto yyerrlab1;


/*---------------------------------------------------.
| yyerrorlab -- error raised explicitly by YYERROR.  |
`---------------------------------------------------*/
yyerrorlab:

  /* Pacify compilers like GCC when the user code never invokes
     YYERROR and the label yyerrorlab therefore never appears in user
     code.  */
  if (/*CONSTCOND*/ 0)
     goto yyerrorlab;

  /* Do not reclaim the symbols of the rule which action triggered
     this YYERROR.  */
  YYPOPSTACK (yylen);
  yylen = 0;
  YY_STACK_PRINT (yyss, yyssp);
  yystate = *yyssp;
  goto yyerrlab1;


/*-------------------------------------------------------------.
| yyerrlab1 -- common code for both syntax error and YYERROR.  |
`-------------------------------------------------------------*/
yyerrlab1:
  yyerrstatus = 3;	/* Each real token shifted decrements this.  */

  for (;;)
    {
      yyn = yypact[yystate];
      if (yyn != YYPACT_NINF)
	{
	  yyn += YYTERROR;
	  if (0 <= yyn && yyn <= YYLAST && yycheck[yyn] == YYTERROR)
	    {
	      yyn = yytable[yyn];
	      if (0 < yyn)
		break;
	    }
	}

      /* Pop the current state because it cannot handle the error token.  */
      if (yyssp == yyss)
	YYABORT;


      yydestruct ("Error: popping",
		  yystos[yystate], yyvsp);
      YYPOPSTACK (1);
      yystate = *yyssp;
      YY_STACK_PRINT (yyss, yyssp);
    }

  if (yyn == YYFINAL)
    YYACCEPT;

  *++yyvsp = yylval;


  /* Shift the error token.  */
  YY_SYMBOL_PRINT ("Shifting", yystos[yyn], yyvsp, yylsp);

  yystate = yyn;
  goto yynewstate;


/*-------------------------------------.
| yyacceptlab -- YYACCEPT comes here.  |
`-------------------------------------*/
yyacceptlab:
  yyresult = 0;
  goto yyreturn;

/*-----------------------------------.
| yyabortlab -- YYABORT comes here.  |
`-----------------------------------*/
yyabortlab:
  yyresult = 1;
  goto yyreturn;

#ifndef yyoverflow
/*-------------------------------------------------.
| yyexhaustedlab -- memory exhaustion comes here.  |
`-------------------------------------------------*/
yyexhaustedlab:
  yyerror (YY_("memory exhausted"));
  yyresult = 2;
  /* Fall through.  */
#endif

yyreturn:
  if (yychar != YYEOF && yychar != YYEMPTY)
     yydestruct ("Cleanup: discarding lookahead",
		 yytoken, &yylval);
  /* Do not reclaim the symbols of the rule which action triggered
     this YYABORT or YYACCEPT.  */
  YYPOPSTACK (yylen);
  YY_STACK_PRINT (yyss, yyssp);
  while (yyssp != yyss)
    {
      yydestruct ("Cleanup: popping",
		  yystos[*yyssp], yyvsp);
      YYPOPSTACK (1);
    }
#ifndef yyoverflow
  if (yyss != yyssa)
    YYSTACK_FREE (yyss);
#endif
#if YYERROR_VERBOSE
  if (yymsg != yymsgbuf)
    YYSTACK_FREE (yymsg);
#endif
  /* Make sure YYID is used.  */
  return YYID (yyresult);
}


#line 357 "mixal.y"

#line 395 "./mixal.yw"

/*:28*//*30:*/
#line 397 "./mixal.yw"


unsigned
add_mix(unsigned a,unsigned b)
{
unsigned s,t;

s= SIGN(a);
t= SIGN(b);
if(s!=t){
if(MAG(a)> MAG(b)){
a= MAG(a)-MAG(b);
t= s;
}else
a= MAG(b)-MAG(a);
}else
a= MAG(a)+MAG(b);
if(a> B5-1)
yyerror("Arithmetic result greater than 1073741823");
return a|t;
}

/*:30*//*31:*/
#line 419 "./mixal.yw"


unsigned
sub_mix(unsigned a,unsigned b)
{
b^= MINUS;
return add_mix(a,b);
}


/*:31*//*32:*/
#line 429 "./mixal.yw"


unsigned
mul_mix(unsigned a,unsigned b)
{
unsigned s;
long long w;
s= SIGN(a)==SIGN(b)?PLUS:MINUS;
if((w= MAG(a)*MAG(b))> B5-1)
yyerror("Arithmetic result greater than 1073741823");
return s|MAG(w);
}

/*:32*//*33:*/
#line 442 "./mixal.yw"


unsigned
div_mix(unsigned a,unsigned b)
{
return SIGN(a)|MAG(MAG(a)/MAG(b));
}

/*:33*//*34:*/
#line 450 "./mixal.yw"


unsigned
w_eval(unsigned x,unsigned y,int f)
{
int l,r;
unsigned sign,mask;

l= f/8;
r= f%8;
mask= B5-1;
if(l<0||l> r||r> 5)
yyerror("Invalid F-part");
if(l==0){
sign= MINUS&y;
l= 1;
}else sign= MINUS&x;
y<<= (4-r+l)*BYTESIZE;

y= MAG(y);
y>>= (l-1)*BYTESIZE;
mask<<= (4-r+l)*BYTESIZE;
mask= MAG(mask);
mask>>= (l-1)*BYTESIZE;
x&= ~mask;
x= MAG(x);
x|= y;
x|= sign;
return x;
}

/*:34*//*35:*/
#line 481 "./mixal.yw"


int
word_s(unsigned w)
{
if(w&MINUS)
w= -MAG(w);
return w;
}

/*:35*//*36:*/
#line 491 "./mixal.yw"


void
warning_l(int line,char*s,char*t)
{
if(t)
error_at_line(0,0,source_file,line,"warning: %s %s",s,t);
else
error_at_line(0,0,source_file,line,"warning: %s",s);
}

/*:36*//*37:*/
#line 502 "./mixal.yw"


void
warning(char*s,char*t)
{
warning_l(lineno,s,t);
}

/*:37*//*38:*/
#line 510 "./mixal.yw"


void
parse_error_l(int line,char*s,char*t)
{
if(t)
error_at_line(0,0,source_file,line,"%s %s",s,t);
else
error_at_line(0,0,source_file,line,"%s",s);
error_count++;
}

/*:38*//*39:*/
#line 522 "./mixal.yw"


void
parse_error(char*s,char*t)
{
parse_error_l(lineno,s,t);
}

/*:39*//*40:*/
#line 530 "./mixal.yw"


int
yyerror(char*s)
{
parse_error(s,NULL);
}

/*:40*//*41:*/
#line 538 "./mixal.yw"


void
usage()
{
printf("usage: mixal [OPTIONS] [input-file]\n");
printf("Assemble a MIX source file\n");
printf("\n");
printf("OPTIONS are:\n");
printf("  -l, --list                    produce a source listing\n");
printf("  --list-file=FILE              set listing file name\n");
printf("  -f, --force                   force generating object deck even if\n");
printf("                                assembled with errors\n");
printf("  -o, --output=FILE             set output file name\n");
printf("  -r, --raw-output              produce raw code output\n");
printf("  -x, --cross-reference, --xref output a cross reference\n");

printf("\n");
printf("Debugging options:\n");
printf("  --debug-gram                  enable parser debugging\n");
printf("  --debug-lex                   enable lexer debugging\n");
printf("  -d LEVEL                      set debug level\n");

printf("\n");
printf("Informative options:\n");
printf("  -h, --help                    print this help summary\n");
printf("  -V, --version                 print program version and license info\n");
printf("\n");
printf("Report bugs to <%s>\n",PACKAGE_BUGREPORT);
}

/*:41*//*42:*/
#line 569 "./mixal.yw"


void
init_keywords()
{
int i;
for(i= 0;i<op_count;i++)
install_op(&mix_optab[i]);
}

/*:42*//*43:*/
#line 579 "./mixal.yw"


enum{
DEBUG_GRAM_OPTION= 256,
DEBUG_LEX_OPTION,
LIST_FILE_OPTION,
};

struct option options[]= {
{"debug-gram",no_argument,NULL,DEBUG_GRAM_OPTION},
{"debug-lex",no_argument,NULL,DEBUG_LEX_OPTION},
{"help",no_argument,NULL,'h'},
{"list",no_argument,NULL,'l'},
{"list-file",required_argument,NULL,LIST_FILE_OPTION},
{"force",no_argument,NULL,'f'},
{"raw-output",no_argument,NULL,'r'},
{"output",required_argument,NULL,'o'},
{"version",no_argument,NULL,'V'},
{"cross-reference",no_argument,NULL,'x'},
{"xref",no_argument,NULL,'x'},
{NULL}
};



/*:43*//*44:*/
#line 604 "./mixal.yw"


int
main(int argc,char*argv[])
{
int lexdebug= 0;
int i;
char*p;
int force= 0;


set_program_name(argv[0]);
while((i= getopt_long(argc,argv,"d:fhlo:rVx",options,NULL))!=EOF){
switch(i){
case'd':
for(p= optarg;*p;p++){
switch(*p){
case'y':
yydebug= 1;
break;

case'l':
lexdebug= 1;
break;

default:
error(1,0,"invalid debugging level: %c\n",*p);
break;
}
}
break;

case DEBUG_GRAM_OPTION:
yydebug= 1;
break;

case DEBUG_LEX_OPTION:
lexdebug= 1;
break;

case'f':
force= 1;
break;

case'l':
list= 1;
break;

case LIST_FILE_OPTION:
list= 1;
listfile= optarg;
break;

case'o':
outfile= optarg;
break;

case'r':
writeraw= 1;
break;

case'V':
mix_version(program_name);
exit(0);

case'x':
xref= 1;
break;

case'h':
usage();
exit(0);

default:
exit(1);
}
}
if(argc> optind){
FILE*fp;
source_file= argv[optind];
if((fp= fopen(source_file,"r"))==NULL)
error(1,errno,"can't open %s",source_file);

init_lex(fp,lexdebug);
if(list&&!listfile){
unsigned len;
char*base,*p;

base= strrchr(source_file,'/');
if(base)
base++;
else
base= source_file;
p= strrchr(base,'.');
if(p)
len= p-base;
else
len= strlen(base);
listfile= xmalloc(len+sizeof(LIST_SUFFIX));
memcpy(listfile,base,len);
strcat(listfile,LIST_SUFFIX);
}
}else
init_lex(stdin,lexdebug);
if(list){
lst= create_temp("lstXXXXXX");
if(!listfile)
listfile= "mixal.lst";
}

for(i= 0;i<MEMSIZE;i++)
lines[i]= -1;
init_keywords();
error_count+= yyparse();

if(start_location==MEMSIZE)
parse_error("No END statement in program",NULL);

if(error_count&&!force)
exit(1);

symbols();
end_routine(word_s(start_location));

if(list)
listing();
else if(xref)
dumpsymtab(stderr);

exit(error_count> 0);
}

/*:44*//*45:*/
#line 736 "./mixal.yw"


FILE*
create_temp(char*tmpl)
{
char*buf;
char*tmp;
int fd;
int save_mask;

if((tmp= getenv("TMP"))==NULL&&(tmp= getenv("TEMP"))==NULL)
tmp= "/tmp";
buf= xmalloc(strlen(tmp)+1+strlen(tmpl)+1);
sprintf(buf,"%s/%s",tmp,tmpl);

save_mask= umask(077);
fd= mkstemp(buf);
umask(save_mask);

if(fd==-1)
error(1,errno,"can't create temporary file %s",tmp);

unlink(buf);
free(buf);
return fdopen(fd,"w+");
}

/*:45*//*46:*/
#line 763 "./mixal.yw"


void
list_cell(FILE*fp,int i)
{
int Av,Iv,Fv,Cv,Sv;
Sv= (memory[i]&MINUS)?'-':'+';
Av= (memory[i]&(B5-1))>>3*BYTESIZE;
Iv= (memory[i]&(B3-1))>>2*BYTESIZE;
Fv= (memory[i]&(B2-1))>>BYTESIZE;
Cv= (memory[i]&(B1-1));
fprintf(fp,"%4d: %c %4d %2d %2d %2d",
i,Sv,Av,Iv,Fv,Cv);
}

/*:46*//*47:*/
#line 778 "./mixal.yw"


void
listing()
{
FILE*fp;
char buf[512];
int i,l;
int lastloc= 0;

/*:47*//*48:*/
#line 788 "./mixal.yw"


fseek(lst,-1,SEEK_CUR);
if(fgetc(lst)!='\n')
fputc('\n',lst);
rewind(lst);

/*:48*//*49:*/
#line 795 "./mixal.yw"


fp= fopen(listfile,"w");
if(fp==NULL)
error(1,errno,"can't open %s",listfile);

/*:49*//*50:*/
#line 801 "./mixal.yw"


for(l= 1;l<=lineno;l++){
if((i= lines[l])!=-1){
list_cell(fp,i);
fprintf(fp,"   %3d ",l);
lastloc= i;
}else
fprintf(fp,"%23s %3d "," ",l);

if(fgets(buf,sizeof(buf),lst))
fputs(buf,fp);
else
fputs("\n",fp);
}

/*:50*//*51:*/
#line 817 "./mixal.yw"


for(i= lastloc+1;i<location_counter;i++){
list_cell(fp,i);
fputs("\n",fp);
}

/*:51*//*52:*/
#line 824 "./mixal.yw"


dumpsymtab(fp);

/*:52*//*53:*/
#line 828 "./mixal.yw"


fclose(fp);
}


/*:53*//*54:*/
#line 834 "./mixal.yw"


void
dumpsymtab(FILE*fp)
{
Symbol**symbols= sort_symbols();
int i;
ref*refp;

fprintf(fp,"\nSymbol     Value  Line");
if(xref){
fprintf(fp,"  Referenced on line");
}
fprintf(fp,"\n");
for(i= 0;symbols[i];i++){
Symbol*s= symbols[i];
fprintf(fp,"%-10s  %4d %4d",
s->name,word_s(s->value),s->line);
if(xref){
sort_refs(s);
for(refp= s->xref;refp;refp= refp->next){
if(refp->line!=s->line)
fprintf(fp," %4d",refp->line);
}
}
fprintf(fp,"\n");
}
free(symbols);
}

/*:54*//*55:*/
#line 864 "./mixal.yw"


void
tlist(char*fmt,...)
{
va_list ap;

if(!lst)
return;
va_start(ap,fmt);
vfprintf(lst,fmt,ap);
va_end(ap);
}

/*:55*//*56:*/
#line 878 "./mixal.yw"


int
sym_eval_wexpr(Symbol*s)
{
if(s->name[0]=='='){
memory[location_counter]= w_eval(0,s->value,5);
s->value= location_counter++;
}
if(s->type==UNDEF){
if(s->name[0]=='|'){
parse_error_l(s->line,"missing 'forward here'",NULL);
}else{
error(0,0,"warning: '%-10s CON  0' inserted at %d:",
s->name,location_counter);
memory[location_counter]= 0;
s->value= location_counter++;
s->type= DEF;
}
}
return 0;
}

/*:56*//*57:*/
#line 901 "./mixal.yw"


static int
sym_resolve(Symbol*s)
{


if(s->type==END)
s->value= location_counter;


resolve_forward(s);
return 0;
}

/*:57*//*58:*/
#line 916 "./mixal.yw"


void
symbols()
{
iterate(sym_eval_wexpr);
iterate(sym_resolve);
}

/*:58*//*59:*/
#line 925 "./mixal.yw"


char loader[]= 
" O O6 Z O6    I C O4 0 EH A  F F CF 0  E   EU 0 IH G BB   EJ  CA. Z EU   EH E BA\n"
"   EU 2A-H S BB  C U 1AEH 2AEN V  E  CLU  ABG Z EH E BB J B. A  9               \n";

/*:59*//*60:*/
#line 931 "./mixal.yw"


void
end_routine(int start)
{
long address,loc,sign,value;
int i,j,flag;
char field[7][11];
char title[6];
FILE*fp;

if(outfile){
fp= fopen(outfile,"w");
if(!fp)
error(1,errno,"cannot open output file `%s'",outfile);
}else
fp= stdout;

if(source_file){
char*p;
if(p= strrchr(source_file,'/'))
p++;
else
p= source_file;
for(i= 0;i<5&&p[i];i++)
title[i]= toupper(p[i]);
title[i]= '\0';
}else
strcpy(title,"MIXAL");

if(writeraw){
int count= 0;
for(i= 0;i<32;i++){
fprintf(fp,
"%c%c%c%c%c",
mixalf[((memory[i]&(B5-1))>>4*BYTESIZE)&(B1-1)],
mixalf[((memory[i]&(B5-1))>>3*BYTESIZE)&(B1-1)],
mixalf[((memory[i]&(B3-1))>>2*BYTESIZE)&(B1-1)],
mixalf[((memory[i]&(B2-1))>>BYTESIZE)&(B1-1)],
mixalf[(memory[i]&(B1-1))]);
count++;
if(count%16==0)
fprintf(fp,"\n");
}
return;
}


fprintf(fp,"%s",loader);

flag= i= 0;
for(address= 0;address<MEMSIZE;address++)
if(memory[address]){
sign= memory[address]&MINUS?-1:1;
value= MAG(memory[address]);
if(!flag)
flag= 1,loc= address;
if(address!=loc+i||i>=7){
fprintf(fp,"%-5s%1d%04ld",title,i,loc);
for(j= 0;j<i;j++)
fprintf(fp,"%10s",field[j]);
fprintf(fp,"\n");
loc= address;
i= 0;
}
sprintf(field[i],"%010ld",value);
if(sign<0)
field[i][9]= "~JKLMNOPQR"[field[i][9]-'0'];
i++;
}
fprintf(fp,"%-5s%1d%04ld",title,i,loc);
for(j= 0;j<i;j++)
fprintf(fp,"%10s",field[j]);
fprintf(fp,"\n");
fprintf(fp,"TRANS0%04d\n",start);

fclose(fp);
}

/*:60*//*61:*/
#line 1010 "./mixal.yw"


int
num(char*text)
{
int i,n;
char*p;

n= 0;
for(i= 0;i<5;i++)
if(!text[i])
n= n*B1;
else if(p= strchr(mixalf,text[i]))
n= n*B1+(p-mixalf);
else
yyerror("bad character in ALF constant");
return n;
}

/*:61*//*62:*/
#line 1029 "./mixal.yw"


void
resolve_forward(Symbol*f)
{
ref*p;

for(p= f->reflist;p;p= p->next){
memory[p->address]&= (B3-1);
memory[p->address]|= f->value<<(BYTESIZE*3);
}
}/*:62*/

