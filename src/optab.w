% This file is generated automatically. Please do not edit
@* OPTAB FOR MIXAL.
@c
#include "mix.h"

@ \.{MIX} character set.
@c
char mixalf[] = 
  " ABCDEFGHInJKLMNOPQRepSTUVWXYZ0123456789.,()+-*/=$<>@@;:'abcdfghi";
@ \.{MIXAL} table. Each row consists of following elements:
\tabskip=1em \halign{ \strut\sc#\hfil&\strut{\raggedright#}\cr
OP & Opcode mnemonics\cr
(F) & Default field specification\cr
C  & \.{MIX} operation code\cr
FLD & Field notation type. |0| means |(n)|, |1| means |(L:R)|\cr}
@c
struct mix_op mix_optab[] = {@/
@t\hskip 5em@>{  "NOP",    0,    0,    0 },@/
@t\hskip 5em@>{  "ADD",    5,    1,    1 },@/
@t\hskip 5em@>{  "SUB",    5,    2,    1 },@/
@t\hskip 5em@>{  "MUL",    5,    3,    1 },@/
@t\hskip 5em@>{  "DIV",    5,    4,    1 },@/
@t\hskip 5em@>{  "NUM",    0,    5,    0 },@/
@t\hskip 5em@>{ "CHAR",    1,    5,    0 },@/
@t\hskip 5em@>{  "HLT",    2,    5,    0 },@/
@t\hskip 5em@>{  "SLA",    0,    6,    0 },@/
@t\hskip 5em@>{  "SRA",    1,    6,    0 },@/
@t\hskip 5em@>{ "SLAX",    2,    6,    0 },@/
@t\hskip 5em@>{ "SRAX",    3,    6,    0 },@/
@t\hskip 5em@>{  "SLC",    4,    6,    0 },@/
@t\hskip 5em@>{  "SRC",    5,    6,    0 },@/
@t\hskip 5em@>{ "MOVE",    1,    7,    0 },@/
@t\hskip 5em@>{  "LDA",    5,    8,    1 },@/
@t\hskip 5em@>{  "LD1",    5,    9,    1 },@/
@t\hskip 5em@>{  "LD2",    5,   10,    1 },@/
@t\hskip 5em@>{  "LD3",    5,   11,    1 },@/
@t\hskip 5em@>{  "LD4",    5,   12,    1 },@/
@t\hskip 5em@>{  "LD5",    5,   13,    1 },@/
@t\hskip 5em@>{  "LD6",    5,   14,    1 },@/
@t\hskip 5em@>{  "LDX",    5,   15,    1 },@/
@t\hskip 5em@>{ "LDAN",    5,   16,    1 },@/
@t\hskip 5em@>{ "LD1N",    5,   17,    1 },@/
@t\hskip 5em@>{ "LD2N",    5,   18,    1 },@/
@t\hskip 5em@>{ "LD3N",    5,   19,    1 },@/
@t\hskip 5em@>{ "LD4N",    5,   20,    1 },@/
@t\hskip 5em@>{ "LD5N",    5,   21,    1 },@/
@t\hskip 5em@>{ "LD6N",    5,   22,    1 },@/
@t\hskip 5em@>{ "LDXN",    5,   23,    1 },@/
@t\hskip 5em@>{  "STA",    5,   24,    1 },@/
@t\hskip 5em@>{  "ST1",    5,   25,    1 },@/
@t\hskip 5em@>{  "ST2",    5,   26,    1 },@/
@t\hskip 5em@>{  "ST3",    5,   27,    1 },@/
@t\hskip 5em@>{  "ST4",    5,   28,    1 },@/
@t\hskip 5em@>{  "ST5",    5,   29,    1 },@/
@t\hskip 5em@>{  "ST6",    5,   30,    1 },@/
@t\hskip 5em@>{  "STX",    5,   31,    1 },@/
@t\hskip 5em@>{  "STJ",    2,   32,    1 },@/
@t\hskip 5em@>{  "STZ",    5,   33,    1 },@/
@t\hskip 5em@>{ "JBUS",    0,   34,    0 },@/
@t\hskip 5em@>{  "IOC",    0,   35,    0 },@/
@t\hskip 5em@>{   "IN",    0,   36,    0 },@/
@t\hskip 5em@>{  "OUT",    0,   37,    0 },@/
@t\hskip 5em@>{ "JRED",    0,   38,    0 },@/
@t\hskip 5em@>{  "JMP",    0,   39,    0 },@/
@t\hskip 5em@>{  "JSJ",    1,   39,    0 },@/
@t\hskip 5em@>{  "JOV",    2,   39,    0 },@/
@t\hskip 5em@>{ "JNOV",    3,   39,    0 },@/
@t\hskip 5em@>{   "JL",    4,   39,    0 },@/
@t\hskip 5em@>{   "JE",    5,   39,    0 },@/
@t\hskip 5em@>{   "JG",    6,   39,    0 },@/
@t\hskip 5em@>{  "JGE",    7,   39,    0 },@/
@t\hskip 5em@>{  "JNE",    8,   39,    0 },@/
@t\hskip 5em@>{  "JLE",    9,   39,    0 },@/
@t\hskip 5em@>{  "JAN",    0,   40,    0 },@/
@t\hskip 5em@>{  "JAZ",    1,   40,    0 },@/
@t\hskip 5em@>{  "JAP",    2,   40,    0 },@/
@t\hskip 5em@>{ "JANN",    3,   40,    0 },@/
@t\hskip 5em@>{ "JANZ",    4,   40,    0 },@/
@t\hskip 5em@>{ "JANP",    5,   40,    0 },@/
@t\hskip 5em@>{  "J1N",    0,   41,    0 },@/
@t\hskip 5em@>{  "J1Z",    1,   41,    0 },@/
@t\hskip 5em@>{  "J1P",    2,   41,    0 },@/
@t\hskip 5em@>{ "J1NN",    3,   41,    0 },@/
@t\hskip 5em@>{ "J1NZ",    4,   41,    0 },@/
@t\hskip 5em@>{ "J1NP",    5,   41,    0 },@/
@t\hskip 5em@>{  "J2N",    0,   42,    0 },@/
@t\hskip 5em@>{  "J2Z",    1,   42,    0 },@/
@t\hskip 5em@>{  "J2P",    2,   42,    0 },@/
@t\hskip 5em@>{ "J2NN",    3,   42,    0 },@/
@t\hskip 5em@>{ "J2NZ",    4,   42,    0 },@/
@t\hskip 5em@>{ "J2NP",    5,   42,    0 },@/
@t\hskip 5em@>{  "J3N",    0,   43,    0 },@/
@t\hskip 5em@>{  "J3Z",    1,   43,    0 },@/
@t\hskip 5em@>{  "J3P",    2,   43,    0 },@/
@t\hskip 5em@>{ "J3NN",    3,   43,    0 },@/
@t\hskip 5em@>{ "J3NZ",    4,   43,    0 },@/
@t\hskip 5em@>{ "J3NP",    5,   43,    0 },@/
@t\hskip 5em@>{  "J4N",    0,   44,    0 },@/
@t\hskip 5em@>{  "J4Z",    1,   44,    0 },@/
@t\hskip 5em@>{  "J4P",    2,   44,    0 },@/
@t\hskip 5em@>{ "J4NN",    3,   44,    0 },@/
@t\hskip 5em@>{ "J4NZ",    4,   44,    0 },@/
@t\hskip 5em@>{ "J4NP",    5,   44,    0 },@/
@t\hskip 5em@>{  "J5N",    0,   45,    0 },@/
@t\hskip 5em@>{  "J5Z",    1,   45,    0 },@/
@t\hskip 5em@>{  "J5P",    2,   45,    0 },@/
@t\hskip 5em@>{ "J5NN",    3,   45,    0 },@/
@t\hskip 5em@>{ "J5NZ",    4,   45,    0 },@/
@t\hskip 5em@>{ "J5NP",    5,   45,    0 },@/
@t\hskip 5em@>{  "J6N",    0,   46,    0 },@/
@t\hskip 5em@>{  "J6Z",    1,   46,    0 },@/
@t\hskip 5em@>{  "J6P",    2,   46,    0 },@/
@t\hskip 5em@>{ "J6NN",    3,   46,    0 },@/
@t\hskip 5em@>{ "J6NZ",    4,   46,    0 },@/
@t\hskip 5em@>{ "J6NP",    5,   46,    0 },@/
@t\hskip 5em@>{  "JXN",    0,   47,    0 },@/
@t\hskip 5em@>{  "JXZ",    1,   47,    0 },@/
@t\hskip 5em@>{  "JXP",    2,   47,    0 },@/
@t\hskip 5em@>{ "JXNN",    3,   47,    0 },@/
@t\hskip 5em@>{ "JXNZ",    4,   47,    0 },@/
@t\hskip 5em@>{ "JXNP",    5,   47,    0 },@/
@t\hskip 5em@>{ "INCA",    0,   48,    0 },@/
@t\hskip 5em@>{ "DECA",    1,   48,    0 },@/
@t\hskip 5em@>{ "ENTA",    2,   48,    0 },@/
@t\hskip 5em@>{ "ENNA",    3,   48,    0 },@/
@t\hskip 5em@>{ "INC1",    0,   49,    0 },@/
@t\hskip 5em@>{ "DEC1",    1,   49,    0 },@/
@t\hskip 5em@>{ "ENT1",    2,   49,    0 },@/
@t\hskip 5em@>{ "ENN1",    3,   49,    0 },@/
@t\hskip 5em@>{ "INC2",    0,   50,    0 },@/
@t\hskip 5em@>{ "DEC2",    1,   50,    0 },@/
@t\hskip 5em@>{ "ENT2",    2,   50,    0 },@/
@t\hskip 5em@>{ "ENN2",    3,   50,    0 },@/
@t\hskip 5em@>{ "INC3",    0,   51,    0 },@/
@t\hskip 5em@>{ "DEC3",    1,   51,    0 },@/
@t\hskip 5em@>{ "ENT3",    2,   51,    0 },@/
@t\hskip 5em@>{ "ENN3",    3,   51,    0 },@/
@t\hskip 5em@>{ "INC4",    0,   52,    0 },@/
@t\hskip 5em@>{ "DEC4",    1,   52,    0 },@/
@t\hskip 5em@>{ "ENT4",    2,   52,    0 },@/
@t\hskip 5em@>{ "ENN4",    3,   52,    0 },@/
@t\hskip 5em@>{ "INC5",    0,   53,    0 },@/
@t\hskip 5em@>{ "DEC5",    1,   53,    0 },@/
@t\hskip 5em@>{ "ENT5",    2,   53,    0 },@/
@t\hskip 5em@>{ "ENN5",    3,   53,    0 },@/
@t\hskip 5em@>{ "INC6",    0,   54,    0 },@/
@t\hskip 5em@>{ "DEC6",    1,   54,    0 },@/
@t\hskip 5em@>{ "ENT6",    2,   54,    0 },@/
@t\hskip 5em@>{ "ENN6",    3,   54,    0 },@/
@t\hskip 5em@>{ "INCX",    0,   55,    0 },@/
@t\hskip 5em@>{ "DECX",    1,   55,    0 },@/
@t\hskip 5em@>{ "ENTX",    2,   55,    0 },@/
@t\hskip 5em@>{ "ENNX",    3,   55,    0 },@/
@t\hskip 5em@>{ "CMPA",    5,   56,    1 },@/
@t\hskip 5em@>{ "CMP1",    5,   57,    1 },@/
@t\hskip 5em@>{ "CMP2",    5,   58,    1 },@/
@t\hskip 5em@>{ "CMP3",    5,   59,    1 },@/
@t\hskip 5em@>{ "CMP4",    5,   60,    1 },@/
@t\hskip 5em@>{ "CMP5",    5,   61,    1 },@/
@t\hskip 5em@>{ "CMP6",    5,   62,    1 },@/
@t\hskip 5em@>{ "CMPX",    5,   63,    1 },@/
};
int op_count = sizeof(mix_optab)/sizeof(mix_optab[0]);

@ The following two tables are used when disassembling \.{MIX} code.
Let |C| be the operation code read from the input program,
|F| be the field specification and |I| be the index of |mix_optab| entry,
describing the instruction in question.
Then, |I = dd_ent[C]|, if |dd_cnt[C] == 1|. Otherwise, if |F < dd_cnt[C]|,
|I = dd_ent[C] + F|.

@ count
@c
int dd_cnt[] = {@/
	@t\hskip 5em@>   1,    1,    1,    1,    1,    3,    6,    1,    1,    1, @/
	@t\hskip 5em@>   1,    1,    1,    1,    1,    1,    1,    1,    1,    1, @/
	@t\hskip 5em@>   1,    1,    1,    1,    1,    1,    1,    1,    1,    1, @/
	@t\hskip 5em@>   1,    1,    1,    1,    1,    1,    1,    1,    1,   10, @/
	@t\hskip 5em@>   6,    6,    6,    6,    6,    6,    6,    6,    4,    4, @/
	@t\hskip 5em@>   4,    4,    4,    4,    4,    4,    1,    1,    1,    1, @/
	@t\hskip 5em@>   1,    1,    1,    1, @/
};
@ entry points.
@c
int dd_ent[] = {@/
	@t\hskip 5em@>   0,    1,    2,    3,    4,    5,    8,   14,   15,   16, @/
	@t\hskip 5em@>  17,   18,   19,   20,   21,   22,   23,   24,   25,   26, @/
	@t\hskip 5em@>  27,   28,   29,   30,   31,   32,   33,   34,   35,   36, @/
	@t\hskip 5em@>  37,   38,   39,   40,   41,   42,   43,   44,   45,   46, @/
	@t\hskip 5em@>  56,   62,   68,   74,   80,   86,   92,   98,  104,  108, @/
	@t\hskip 5em@> 112,  116,  120,  124,  128,  132,  136,  137,  138,  139, @/
	@t\hskip 5em@> 140,  141,  142,  143, @/
};
