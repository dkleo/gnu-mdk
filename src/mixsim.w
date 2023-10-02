% This file is part of MIX
% Copyright (C) 1998, 1999, 2000 Douglas Laing
% Copyright (C) 2000, 2005, 2007 Sergey Poznyakoff
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3, or (at
% your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%

\def\>{\hskip 5em}

@*A MIX SIMULATOR.
This will simulate a binary  computer with 64 distinct
values per byte. 
Each byte will be represented by 6 bits, with a value range of
|000| to |077|.
Signs will be a single bit, |0| for plus or |1| for minus in the first position
of the real word.
A word will then occupy 4 actual 8-bit hardware bytes of the real machine
and leave one bit (the second bit of the real word) over for possible future
use (garbage collection- - with new operations to set the bit on and off?)

@ The overall structure will be
@c
@<Header files to include@>@/
@<Global variables@>@/
@<I/O functions@>@/
@<Auxiliary Functions@>@/
@<Diagnostic functions@>@/
@<Debugging support@>@/
@<Disassembler support@>@/
@<Interface functions@>@/
@<MIX Instruction Handlers@>@/
@<The main program@>

@ Simulator-specific definitions
@d ADDRESS(word) (word & TWOBYTES << 3*BYTESIZE) >> 3*BYTESIZE	/* magnitude of address */
@d INDEX(word) (word & ONEBYTE << 2*BYTESIZE) >> 2*BYTESIZE  /* index specification */
@d FIELD(word) (word & ONEBYTE << BYTESIZE) >> BYTESIZE /* F-specification */
@d CODE(word) (word & ONEBYTE)  /* operation code */
@d ONEBYTE 077             /* Mask to obtain a single byte from the word */
@d TWOBYTES 07777          /* Mask to obtain two bytes from the word */
@d FIVEBYTES 07777777777   /* Mask to obtain five bytes from the word */
@d WORDSIZE BYTESIZE*BYTESPERWORD /* Size of MIX word in host machine bits */
@ Several MIX instruction codes
@d LDA   8                          
@d LDAN 16                         
@d STA  24                         
@d IOC  35                       
@d IN   36                       
@d OUT  37                        
@d JA   40                         
@d INCA 48                         
@d CMPA 56
@ Overflow toggle values
@d ON      1
@d OFF     0
@ Comparator register values
@d LESS   -1
@d EQUAL   0
@d GREATER 1

@ Define 10 registers and 10 signs, all initialized  to plus zero.
@d areg  reg[0]   /* Magnitude of A-register */
@d i1reg reg[1]   /* Magnitude of index registers */
@d i2reg reg[2]
@d i3reg reg[3]
@d i4reg reg[4]
@d i5reg reg[5]
@d i6reg reg[6]
@d xreg  reg[7]   /* Magnitude of X-register */
@d jreg  reg[8]   /* Magnitude of J-register */
@d zero  reg[9]   /* Constant zero, for "STZ" */
@d signa sign[0]       /* Sign of A-register */
@d sign1 sign[1]       /* Sign of index registers */
@d sign2 sign[2]
@d sign3 sign[3]
@d sign4 sign[4]
@d sign5 sign[5]
@d sign6 sign[6]
@d signx sign[7]      /* Sign of X-register */
@d signj sign[8]      /* Sign of J-register */
@d signz sign[9]      /* Sign stored by ``STZ'' */

@ Breakpoint status flags
@d BP_SET    0x01
@d BP_ACTIVE 0x02
@d BP_IS_SET(n)       (bpoint[n].flags & BP_SET)
@d BP_IS_ACTIVE(n)    (bpoint[n].flags & BP_ACTIVE)

@ The error routines write to standard error so they need stdio.h
@<Header...@>=
#ifdef HAVE_CONFIG_H
# include <config.h>
#endif
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <strings.h>
#include <signal.h>
#include <unistd.h>
#include <errno.h>
#include <mix.h>
#include <mixsim.h>
#include "getopt.h"
#include "string.h"
#include "error.h"
#include "progname.h"

@
@<Global variables@>=
long cell[MEMSIZE];
long reg[10] = {0,0,0,0,0,0,0,0,0,0};
long sign[10] = {0,0,0,0,0,0,0,0,0,0};

FILE *infile;
int termmode = 0;
int halt;
int running;

struct breakpoint {
     int addr;               /* Breakpoint address */
     int flags;              /* Is it set and/or enabled */
     unsigned count;         /* Number of hits */
     unsigned ignore;        /* If |!0|, number of hits to ignore */
     unsigned delete_after;  /* If |!0|, delete after this number of hits */
     int next;               /* Next breakpoint, set on the same location */ 
};

struct breakpoint bpoint[MEMSIZE];
unsigned bpind[MEMSIZE];

int lastbreak;
int stepflag;
int interrupted;

typedef void @[@] (*PFV)(void);
typedef int BOOLEAN;

struct operation {
     PFV fn;
     int time;
     BOOLEAN iflag;
};

void nop(void);
void add(void);
void sub(void);
void mul(void);
void mix_div(void);
void spec(void);
void shift(void);
void move(void);
void load(void);
void loadn(void);
void store(void);
void jbus(void);
void ioc(void);
void in(void);
void out(void);
void jred(void);
void jump(void);
void regjump(void);
void addrop(void);
void compare(void);

struct operation optable[64] = { @/
@t\>@>  { nop,     1, F}, @/
@t\>@>  { add,     2, F}, @/
@t\>@>  { sub,     2, F}, @/
@t\>@>  { mul,    10, F}, @/
@t\>@>  { mix_div,    12, F}, @/
@t\>@>  { spec,    1, F}, @/
@t\>@>  { shift,   2, F}, @/
@t\>@>  { move,    1, F}, @/
@t\>@>  { load,    2, F}, @/
@t\>@>  { load,    2, T}, @/
@t\>@>  { load,    2, T}, @/
@t\>@>  { load,    2, T}, @/
@t\>@>  { load,    2, T}, @/
@t\>@>  { load,    2, T}, @/
@t\>@>  { load,    2, T}, @/
@t\>@>  { load,    2, F}, @/
@t\>@>  { loadn,   2, T}, @/
@t\>@>  { loadn,   2, F}, @/
@t\>@>  { loadn,   2, F}, @/
@t\>@>  { loadn,   2, F}, @/
@t\>@>  { loadn,   2, F}, @/
@t\>@>  { loadn,   2, F}, @/
@t\>@>  { loadn,   2, F}, @/
@t\>@>  { loadn,   2, T}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { store,   2, F}, @/
@t\>@>  { jbus,    1, F}, @/
@t\>@>  { ioc,     1, F}, @/
@t\>@>  { in,      1, F}, @/
@t\>@>  { out,     1, F}, @/
@t\>@>  { jred,    1, F}, @/
@t\>@>  { jump,    1, F}, @/
@t\>@>  { regjump, 1, F}, @/
@t\>@>  { regjump, 1, F}, @/
@t\>@>  { regjump, 1, F}, @/
@t\>@>  { regjump, 1, F}, @/
@t\>@>  { regjump, 1, F}, @/
@t\>@>  { regjump, 1, F}, @/
@t\>@>  { regjump, 1, F}, @/
@t\>@>  { regjump, 1, F}, @/
@t\>@>  { addrop,  1, F}, @/
@t\>@>  { addrop,  1, T}, @/
@t\>@>  { addrop,  1, T}, @/
@t\>@>  { addrop,  1, T}, @/
@t\>@>  { addrop,  1, T}, @/
@t\>@>  { addrop,  1, T}, @/
@t\>@>  { addrop,  1, T}, @/
@t\>@>  { addrop,  1, F}, @/
@t\>@>  { compare, 2, T}, @/
@t\>@>  { compare, 2, T}, @/
@t\>@>  { compare, 2, T}, @/
@t\>@>  { compare, 2, T}, @/
@t\>@>  { compare, 2, T}, @/
@t\>@>  { compare, 2, T}, @/
@t\>@>  { compare, 2, T}, @/
@t\>@>  { compare, 2, T}  @/
}; 

@ An array of device structures describing the each of the available     
I/O devices.
The paper tape unit has temporarily been discontinued.

Setting the clock field of a unit to -1 indicates that
no I/O operation is outstanding for this unit.
@d TAPE7     7                         
@d DISK8     8                         
@d DISK15   15                         
@d READER   16                        
@d PUNCH    17                        
@d PRINTER  18                         
@d TTY      19
@d MAXUNITS 20

@<Global variables@>=
void tape(void), disk(void), reader(void), punch(void), printer(void), tty(void);
const char *mix_opname(int c, int f);

#ifndef PATH_MAX
# define PATH_MAX 256
#endif
struct io_device {
     PFV device;    /* device function  */
     int io_time;   /* transmission time per block */
     int position;  /* current disk or tape head position */
     int seek_pos;  /* seek position on disk */
     int tape_end;  /* end of file on tape */
     int seek_time; /* skip or seek time */  
     int address;   /* memory address for current i/o */
     int io_op;     /* IOC, IN or OUT */ 
     mix_clock_t clock;     /* clock time when i/o will occur */
     int complete;  /* flag for I/O complete */
     int fd;        /* file descriptor */
     FILE *fp;      /* stream */
     char path[PATH_MAX]; /* associated filename */
};

struct io_device *unitp, unit[MAXUNITS] = { @/
@t\>@>     {tape,      50, 0, 0, 0,    50, 0, 0, 0, 1, 0, NULL, "tape0"}, @/
@t\>@>     {tape,      50, 0, 0, 0,    50, 0, 0, 0, 1, 0, NULL, "tape1"}, @/
@t\>@>     {tape,      50, 0, 0, 0,    50, 0, 0, 0, 1, 0, NULL, "tape2"}, @/
@t\>@>     {tape,      50, 0, 0, 0,    50, 0, 0, 0, 1, 0, NULL, "tape3"}, @/
@t\>@>     {tape,      50, 0, 0, 0,    50, 0, 0, 0, 1, 0, NULL, "tape4"}, @/
@t\>@>     {tape,      50, 0, 0, 0,    50, 0, 0, 0, 1, 0, NULL, "tape5"}, @/
@t\>@>     {tape,      50, 0, 0, 0,    50, 0, 0, 0, 1, 0, NULL, "tape6"}, @/
@t\>@>     {tape,      50, 0, 0, 0,    50, 0, 0, 0, 1, 0, NULL, "tape7"}, @/
@t\>@>     {disk,     250, 0, 0, 0,     1, 0, 0, 0, 1, 0, NULL, "disk0"}, @/
@t\>@>     {disk,     250, 0, 0, 0,     1, 0, 0, 0, 1, 0, NULL, "disk1"}, @/
@t\>@>     {disk,     250, 0, 0, 0,     1, 0, 0, 0, 1, 0, NULL, "disk2"}, @/
@t\>@>     {disk,     250, 0, 0, 0,     1, 0, 0, 0, 1, 0, NULL, "disk3"}, @/
@t\>@>     {disk,     250, 0, 0, 0,     1, 0, 0, 0, 1, 0, NULL, "disk4"}, @/
@t\>@>     {disk,     250, 0, 0, 0,     1, 0, 0, 0, 1, 0, NULL, "disk5"}, @/
@t\>@>     {disk,     250, 0, 0, 0,     1, 0, 0, 0, 1, 0, NULL, "disk6"}, @/
@t\>@>     {disk,     250, 0, 0, 0,     1, 0, 0, 0, 1, 0, NULL, "disk7"}, @/
@t\>@>     {reader, 10000, 0, 0, 0,     0, 0, 0, 0, 1, 0, NULL, "stdin"}, @/
@t\>@>     {punch,  20000, 0, 0, 0,     0, 0, 0, 0, 1, 0, NULL, "stderr"}, @/
@t\>@>     {printer, 7500, 0, 0, 0, 10000, 0, 0, 0, 1, 0, NULL, "stdout"},  @/
@t\>@>     {tty,        0, 0, 0, 0,     0, 0, 0, 0, 1, 0, NULL, "stdin"}, @/
}; @/


@  Allocate some variables.
@<Global variables@>=
int loc;          /* Location of the next instruction */
int mem;          /* Address of the present instruction, plus indexing */
int op;           /* Operation code of the present instruction */
int fld;          /* F-field of the present instruction */ 
long inst;        /* Instruction being simulated */
int compi = EQUAL;/* Comparison indicator */
int ovtog = OFF;  /* Overflow toggle */
mix_clock_t uclock;       /* Simulated execution time */
int instime = 0;  /* Time of previous instruction */
long rA, rX;      /* Used as work registers to pass data */
int  rI1, rI2;
void inc(), dec(), sizechk(), ovcheck(), jmp(), jsj(), jumps(), 
     addrerror(), indexerror(), operror(), memerror(), fielderror(),
     sizeerror(), dump();

@ Memory fetch routine
Returns contents of memory location |mem|.
@<Aux...@>=
void
memory() 
{
     if (mem < 0 || mem >= MEMSIZE)
        memerror();
     rA = MAG(cell[mem]); /* rA $\leftarrow$ magnitude of word */
     rX = SIGN(cell[mem]); /* rX $\leftarrow$ sign of word */
}
@ The |fcheck| subroutine process a partial field specification,
making sure that it has the form $8L+R$ with $L\le R\le 5$.
Returns value of L.
@<Aux...@>=
void
fcheck()
{
     rI1 = rA = fld / 8;  /* rA $\leftarrow$  L */
     rI2 = rX = fld % 8;  /* rX $\leftarrow$  R */
     if (rA > rX || rX > 5)
        fielderror();  /* Error if L $>$ R or R $>$ 5 */
}  
@ |sizechk|
@<Aux...@>=
void
sizechk()
{
     if (optable[op].iflag) {  /* Have we just loaded an index register? */ 
	  if (abs(rA) > TWOBYTES)
	       sizeerror(); /* Make sure the result fits in two bytes */
     } else
	  ovcheck();
}

@ |ovcheck|
@<Aux...@>=
void
ovcheck()
{
     if (rA & (FIVEBYTES+1))
	  ovtog = ON; /* Did overflow just occur? */
     rA &= FIVEBYTES;  /* reset overflow bit */
} 
@ Normally called by |getv| to extract a field from memory.
|getav| is called directly only in comparison operations
to extract a field from a register.
@<Aux...@>=
void
getav()
{
     if (rI1) { /* Is the sign included in the field? */
	  rX = PLUS;  /* If not, set the sign positive. */
	  rA <<= (BYTESIZE * (rI1 - 1)); /* Zero out all bytes to the left */
	  rA &= FIVEBYTES;
	  rA >>= (BYTESIZE * (rI1 - 1)); /* of the field. */
     }
     rA >>= (BYTESIZE * (BYTESPERWORD - rI2));	/* Shift right into the proper position. */		
}
@ |getv| finds the quantity V (namely, the appropriate field
of location M) used in various MIX operators.
@<Aux...@>=
void
getv()
{
     fcheck();  /* Process the field and set |rI1| $\leftarrow$ |L| */
     memory();  /* |rA| $\leftarrow$ memory magnitude, |rX| $\leftarrow$ sign.  */
     getav();   /* Extract the field */
}

@*1 MIX Instruction Handlers.
Use NOP to reset the clock if F is 63.
@<MIX...@>=
void
nop()
{
/* after adding 1 for the NOP the clock will be zero. */
     if (fld == 63)
	  uclock = 0; 
}
@ |add| 
@<MIX...@>=
void
add()
{
     getv();  /* Get the value V in rA and rX. */
     rI1 = 0; /* Let rI1 indicate the A register */
     inc(); /* Go to ``increase'' routine. */
}
@ |sub| 
@<MIX...@>=
void
sub()
{
     getv();  /* Get the value V in rA and rX. */
     rI1 = 0; /* Let rI1 indicate the A register */
     dec(); /* Go to ``decrease'' routine. */
}
@ |mul|
@<MIX...@>=
void
mul()
{
     long long work; /* 64-bit work area */

     getv();  /* Get the value V in rA and rX. */
     if (rX == signa)   /* Are the signs the same? */
	  rX = PLUS;   /* Set rX to the result sign */
     else
	  rX = MINUS;
     signa = signx = rX;  /* Put in both simulated registers */
     work = rA * (long long int) areg;
     xreg = work & FIVEBYTES;
     work >>= WORDSIZE;
     areg = work & FIVEBYTES;
}		

@ |mix_div|
@<MIX...@>=
void
mix_div()
{
     long long work; /* 64-bit work area */

     signx = signa; /* Set the sign of the remainder */
     getv();  /* Get the value V in rA and rX. */
     if (rX == signa)   /* Are the signs the same? */
	  rX = PLUS;   /* Set rX to the result sign */
     else
	  rX = MINUS;
     signa = rX; /* Put it in the simulated rA */
     if (areg > rA)
	  ovtog = ON;  /* The quotient will not fit in 5 bytes */
     work = areg;  /* Divide the operands */
     work <<= WORDSIZE; 
     work |= xreg;
     areg = (work / rA) & FIVEBYTES;
     xreg = work % rA;
} 

@ |load|
@<MIX...@>=
void
loadn() 
{
     getv();  /* Get the value V in rA and rX. */
     rI1 = op - LDAN; /* Register */
     rX = rX ? PLUS : MINUS; /* Negate the sign. */
     reg[rI1] = rA & FIVEBYTES;
     sign[rI1] = rX;
     sizechk();
}

@
@<Aux...@>=
void
load() 
{
     getv();  /* Get the value V in rA and rX. */
     rI1 = op - LDA; /* Register */
     reg[rI1] = rA & FIVEBYTES;
     sign[rI1] = rX;
     sizechk();
}
	
@ |store|
@<Aux...@>=
void
store()
{
     long work;

     fcheck();  /* rI1 $\leftarrow$ L. */
     memory();  /* Get the contents of the memory location. */
     if (!rI1) {  /* Is the sign included in the field */
	  rI1 = 1; /* If so, change L to 1 */
	  rX = sign[op - STA]; /*  and ``store'' the register's sign */
     }
     rA <<= (BYTESIZE * rI2);
     rA &= FIVEBYTES; 
     rA >>= (BYTESIZE * rI2);
     work = rA; /* save the area to the field's right */
     rA = cell[mem];
     rA &= FIVEBYTES; 
     rA >>= (BYTESIZE * (BYTESPERWORD - (rI1 - 1)));
     rA <<= (BYTESIZE * (BYTESPERWORD - (rI1 - 1)));
     work |= rA; /* OR in area to field's left */
     rA = reg[op - STA];
     rA <<= (BYTESIZE * (BYTESPERWORD - rI2 + (rI1 - 1)));  /* Truncate register */
     rA &= FIVEBYTES; 
     rA >>= (BYTESIZE * (rI1 - 1));  /* Right adjust register */
     work |= rA;  /* OR in register */
     work |= rX;  /* OR in sign */
     cell[mem] = work;
}
@ |jump|
@<Aux...@>=
void
jump()
{
     if (fld > 9)
	  fielderror();  /* Is F too large? */
     rA = compi;  /* rA $\leftarrow$ comparison indicator. */
     jumps(fld);
}

@
@<Aux...@>=
void
jumps(int fld)
{
     switch (fld) {
     case 0:  /* jmp */
	  jmp();
	  break;
     case 1:	 /* jsj */
	  jsj();
	  break;
     case 2:	 /* jov */
	  rX = ovtog;
	  ovtog = OFF; /* Shut off overflow toggle. */
	  if (rX)
	       jmp();
	  break;
     case 3:	 /* jnov */
	  rX = ovtog; 
	  ovtog = OFF; /* Shut off overflow toggle. */
	  if (!rX)
	       jmp();
	  break;
     case 4:  /* ls */
	  if (rA < 0)
	       jmp();  /* Jump if rA negative. */
	  break;
     case 5:  /* eq */
	  if (rA == 0)
	       jmp();  /* Jump if rA zero. */
	  break;
     case 6:  /* gr */
	  if (rA > 0)
	       jmp();  /* Jump if rA positive. */
	  break;
     case 7:  /* ge */
	  if (rA >= 0)
	       jmp(); /* Jump if rA zero or positive. */
	  break;
     case 8:  /* ne */
	  if (rA != 0)
	       jmp(); /* Jump if rA negative or positive. */
	  break;
     case 9:  /* le */
	  if (rA <= 0)
	       jmp(); /* Jump if rA zero or negative. */
	  break;
     }
}

@
@<MIX...@>=
void
jmp()
{	
     jreg = loc; /* Set the simulated J-register */
     jsj();
}
@
@<MIX...@>=
void
jsj()
{
     memory();  /* Check for valid memory address. */
     loc = mem;
}

@ |regjump|
@<Aux...@>=
void
regjump()
{
     rA = reg[op - JA];  /* Register jumps */
     rA = sign[op - JA] ? -rA : rA;
     if (fld > 5)
	  fielderror();
     jumps(fld+4);
}

@ |addrop|
@<Aux...@>=
void
addrop()  /* Address transfer operations */
{
     if (fld > 3)
	  fielderror();  /* Is F too large? */
     /*  When M is zero ENTA loads the sign of */
     /*  the instruction and ENNA loads the opposite sign. */
     if (!mem)
          rX = SIGN(inst); 
     else
	  rX = mem<0 ? MINUS : PLUS;  
     rA = mem>0 ? mem : -mem; /* rX $\leftarrow$ sign of M, and rA $\leftarrow$ the magnitude. */
     rI1 = op - INCA; /* rI1 indicates the register. */ 
     switch (fld) {
     case 0:
	  inc();
	  break;
     case 1:
	  dec();
	  break;
     case 2: /* enta */
	  reg[rI1] = rA & FIVEBYTES;
	  sign[rI1] = rX;
	  sizechk();
	  break;
     case 3: /* enna */
	  reg[rI1] = rA & FIVEBYTES;
	  sign[rI1] = rX ? PLUS : MINUS; /* Negate the sign. */
	  sizechk();
	  break;
     }	
}

@
@<MIX...@>=
void
dec()
{
     rX = rX ? PLUS : MINUS; /* Reverse the sign. */
     inc();	/* Reduce dec to inc */
}

@
@<MIX...@>=
void
inc() /* Addition routine: */
{
     if (rX != sign[rI1]) {  /* Are the signs the same? */
	  rA -= reg[rI1];  /* No; subtract the magnitudes */
	  if (rA > 0)   /* Sign change needed? */
	       sign[rI1] = rX; /* Change the register's sign */
	  else
	       rA = -rA;  /* rA is the magnitude of the difference */
     }
     else
	  rA += reg[rI1]; /* Add magnitudes */
     reg[rI1] = rA & FIVEBYTES; /* Store the magnitude of the result */
     sizechk();
}

@ |compare|
@<Aux...@>=
void
compare()
{
     long v;

     getv();
     v = rX ? -rA : rA; /* Attach the sign */
     rA = reg[op - CMPA]; /* Get field F of the appropriate register */
     rX = sign[op - CMPA];
     getav();
     rX = rX ? -rA : rA; /* Attach the sign */
     if (rX == v)
	  compi = EQUAL; /* Set comparison indicator to either */
     else
	  compi = rX > v ? GREATER : LESS; /* zero, plus one, or minus one. */
}
		
@ |shift|
@<Aux...@>=
void
shift()
{
     unsigned long long work, work1;
     if (mem < 0)
	  addrerror();
     if (fld > 5)
	  fielderror();
     rA = areg;
     work = areg;
     work <<= WORDSIZE;
     work |= xreg; 
	
     switch (fld) {
     case 0: /* sla */
	  if (mem > BYTESPERWORD)
	       mem = BYTESPERWORD;
	  rA <<= mem * BYTESIZE;
	  areg = rA & FIVEBYTES;
	  break;
     case 1: /* sra */
	  if (mem > BYTESPERWORD)
	       mem = BYTESPERWORD;
	  rA >>= mem * BYTESIZE;
	  areg = rA;
	  break;
     case 2: /* slax */
	  if (mem > (2*BYTESPERWORD))
	       mem = (2*BYTESPERWORD);
	  work <<= mem * BYTESIZE;
	  rX = work & FIVEBYTES;
	  work >>= WORDSIZE;
	  rA = work & FIVEBYTES;
	  areg = rA;
	  xreg = rX;
	  break;
     case 3: /* srax */
	  if (mem > (2*BYTESPERWORD))
	       mem = (2*BYTESPERWORD);
	  work >>= mem * BYTESIZE;
	  rX = work & FIVEBYTES;
	  work >>= WORDSIZE;
	  rA = work & FIVEBYTES;
	  areg = rA;
	  xreg = rX;
	  break;
     case 4: /* slc */
	  mem %= (2*BYTESPERWORD);
	  work1 = work;
	  work <<= mem * BYTESIZE;
	  work1 >>= (((2*BYTESPERWORD)-mem) * BYTESIZE);	
	  work |= work1;  /* restore circulated bits */
	  rX = work & FIVEBYTES;
	  work >>= WORDSIZE;
	  rA = work & FIVEBYTES;
	  areg = rA;
	  xreg = rX;
	  break;
     case 5: /* src */
	  mem %= (2*BYTESPERWORD);
	  work1 = work;
	  work >>= mem * BYTESIZE;
	  work1 <<= (((2*BYTESPERWORD) - mem) * BYTESIZE);	
	  work |= work1;  /* restore circulated bits */
	  rX = work & FIVEBYTES;
	  work >>= WORDSIZE;
	  rA = work & FIVEBYTES;
	  areg = rA;
	  xreg = rX;
	  break;
     }
}
@ |move|
@<Aux...@>=
void
move()
{
     while (fld) {
	  memory();
	  rX |= rA;
	  rI1 = i1reg;
	  rA = sign1;
	  if (rA) {
	       if (rI1)
		    memerror();
	       sign1 = 0;
	  }
	  if (rI1 > MEMSIZE)
	       memerror();
	  cell[rI1] = rX;
	  uclock += 2;
	  rI1++;
	  i1reg = rI1;
	  mem++;
	  fld--;
     }
}

@ |jbus|
@<MIX...@>=
void
jbus()
{
     if (unitp->clock > uclock) { /* Is there incomplete I/O on this unit? */
	  if (loc-1 == mem) { /* Check for JBUS * */
	       do_outstanding_io(unitp->clock);
	       uclock = unitp->clock; 
	  }
	  jmp();
     }
}

@ |ioc|
@<MIX...@>=
void
ioc()
{
     if (fld == PUNCH || fld == READER)
	  return;  /* ignore IOC for these units */
     if (unitp->clock > uclock) {  /* Is there i/o  outstanding? */
	  do_outstanding_io(unitp->clock);
	  uclock = unitp->clock; 
	  do_io();
     }
     if (unitp->clock > uclock) { /* Is there still i/o outstanding? */
	  do_outstanding_io(unitp->clock);
	  uclock = unitp->clock; 
	  do_io();
     }
     unitp->io_op = op;
     unitp->address = mem;
     if (fld <= TAPE7) {
	  if (mem)
	       unitp->clock = uclock + abs(mem)*unitp->seek_time;  
	  else
	       unitp->clock = uclock + unitp->position*unitp->seek_time;
     }
     if (DISK8 <= fld && fld <= DISK15) { /* disk seek */
	  unitp->clock = uclock + abs(xreg - unitp->position)*unitp->seek_time;
	  unitp->seek_pos = xreg; /* remember where to seek */
     }
     if (fld == PRINTER) {
	  unitp->clock = uclock + unitp->seek_time;   
     } 
}

@ |in|
@<MIX...@>=
void
in()
{
     if (unitp->clock > uclock) {  /* Is there i/o  outstanding? */
	  do_outstanding_io(unitp->clock);
	  uclock = unitp->clock; 
	  do_io();
     }
     if (unitp->clock > uclock) { /* Is there still i/o outstanding? */
	  do_outstanding_io(unitp->clock);
	  uclock = unitp->clock; 
	  do_io();
     }
     unitp->io_op = op;
     unitp->address = mem;  /* Remember where the input is to go to */
     unitp->clock = uclock + unitp->io_time / 2;
     unitp->complete = F;  /* flag as not done */
     if (fld >= DISK8 && fld <= DISK15) {   /* disk i/o */
	  unitp->clock += abs(xreg - unitp->position)*unitp->seek_time; 
	  unitp->seek_pos = xreg; /* remember where to seek */
     }
}

@ |jred|
@<MIX...@>=
void
jred()
{
     if (unitp->clock <= uclock) 
	  jmp();
}

@ |spec|
@<Aux...@>=
void
spec()
{
     long long n, m;
     char work[11];
     int i;
     int table[10] = {30, 31, 32, 33, 34, 35, 36, 37, 38, 39};
	
     if (fld > 2)
	  fielderror();	
     switch (fld) {
     case 0:  /* num */
	  n = 0;
	  m = 1;
	  for (i=0; i<BYTESPERWORD; i++) {  /* shift right and take modulus 64 to */
	       n += (xreg>>BYTESIZE*i)%64%10*m; /* isolate the byte, take modulus 10 */           
	       m *= 10;    /* finally raise to the appropriate power of 10. */
	  }
	  for (i = 0; i < BYTESPERWORD; i++) {
	       n += (areg>>BYTESIZE*i)%64%10*m;
	       m *= 10;
	  }
	  areg = n & FIVEBYTES;
	  if (areg != n)
	       ovtog = ON;
	  uclock += 9;
	  break;
     case 1: /* char */
	  sprintf(work, "%010ld", areg);
	  areg = xreg = 0;
	  for (i = 0; i < BYTESPERWORD; i++) {
	       areg |= table[work[i]-'0']  << ((BYTESPERWORD-(i+1))*BYTESIZE);
	       xreg |= table[work[i+BYTESPERWORD]-'0']  << ((BYTESPERWORD-(i+1))*BYTESIZE); 
	  }
	  uclock += 9;
	  break;
     case 2: /* hlt */
	  do_outstanding_io(FIVEBYTES);         /* tag with a large value */               
	  dump();
	  if (termmode)
	       halt = 1;
	  else
	       exit(-1);
     }
}

@ |out|
@<MIX...@>=

void
out()
{
     if (unitp->clock > uclock) {  /* Is there i/o  outstanding? */
	  do_outstanding_io(unitp->clock);
	  uclock = unitp->clock; 
	  do_io();
     }
     if (unitp->clock > uclock) { /* Is there still i/o outstanding? */
	  do_outstanding_io(unitp->clock);
	  uclock = unitp->clock; 
	  do_io();
     }
     unitp->io_op = op;
     unitp->address = mem;  /* Remember where the output is to come from */
     unitp->clock = uclock + unitp->io_time / 2;
     unitp->complete = F;  /* flag as not done */
     if (fld >=DISK8 && fld <= DISK15)  {  /* disk i/o */
	  unitp->clock += abs(xreg - unitp->position)*unitp->seek_time; 
	  unitp->seek_pos = xreg; /* remember where to seek */
     }
}

@*1 I/O routines.
@<I/O...@>=
void
do_io()  /* check if I/O still needs to be done */
{
     if (!unitp->complete) { /* if I/O not done then do it */
	  (*unitp->device)();
	  unitp->complete = T;  /* flag as done and set clock */
	  unitp->clock = uclock + unitp->io_time / 2;
     } else
	  unitp->clock = 0;
}

@ 
@<I/O...@>=
void
do_outstanding_io(int time)
{
     int i, next, save_fld;

     save_fld = fld;
     next = 0;
     while (next != time) { /* Keep on till no more outstanding i/o */
	  next = time;      /* up until time */                        
	  for (i = 0; i < MAXUNITS; i++)  /* Check all units. */
	       if (unit[i].clock > 0 && unit[i].clock < next) {
		    next = unit[i].clock; /* Find which should complete next. */
		    fld = i;
	       }
	  if (next != time) {
	       unitp = &unit[fld];
	       uclock = unitp->clock;
	       do_io();
	  }
     }   /* Keep on till no more outstanding i/o */
     fld = save_fld;
     unitp = &unit[fld];
}

@ 
@<I/O...@>=
int
open_stream_unit(struct io_device *unitp, char *mode)
{
    if (!unitp->fp) {
	if (strcmp(unitp->path, "stdin") == 0)
	    unitp->fp = stdin;
	else if (strcmp(unitp->path, "stdout") == 0)
	    unitp->fp = stdout;
	else if (strcmp(unitp->path, "stderr") == 0)
	    unitp->fp = stderr;
	else {
	    if (!(unitp->fp = fopen(unitp->path, mode))) {
		error(0, errno, "open failed for %s", unitp->path);
	    }
	}
    }
    return unitp->fp == NULL;
}

@ 
@<I/O...@>=
void
close_stream_unit(struct io_device *unitp)
{
    if (unitp->fp &&
	!(unitp->fp == stdin || unitp->fp == stdout ||
	  unitp->fp == stderr)) {
	fclose(unitp->fp);
	unitp->fp = NULL;
    }
}

@ 
@<I/O...@>=
void
stream_reader(int blocksize, char *buffer, int bufsize)
{
    int i, j, l;
    char *p;

    fgets(buffer, bufsize, unitp->fp);
    l = strlen(buffer);
    for (i = 0; i < blocksize; i++) {
	cell[unitp->address] = 0;
	for (j = 0; j < BYTESPERWORD; j++)
	    if (i * BYTESPERWORD + j < l
		&& (p = strchr(mixalf, buffer[i * BYTESPERWORD + j])))
		cell[unitp->address] |=
		    (p - mixalf) << (BYTESIZE * (BYTESPERWORD - (j + 1)));
	unitp->address++;
    }
}

@ The card reader is connected to stdin.
@<I/O...@>=
void
reader()
{
    char buffer[16*BYTESPERWORD+2];

    switch (unitp->io_op) {
    case IOC:
	close_stream_unit(unitp);
	break;
    case IN:
	if (open_stream_unit(unitp, "r"))
	    return;
	stream_reader(16, buffer, sizeof(buffer));
	break;
    case OUT:
	break;
    }
}

@ 
@<I/O...@>=
void
tty()
{
    char buffer[14*BYTESPERWORD+2];

    switch (unitp->io_op) {
    case IOC:
	close_stream_unit(unitp);
	break;
    case IN:
	if (open_stream_unit(unitp, "r"))
	    return;
	stream_reader(14, buffer, sizeof(buffer));
	break;
    case OUT:
	break;
    }
}

@ The printer is connect to stdout.         
@<I/O...@>=
void
printer()
{
    int i, j;

    if (open_stream_unit(unitp, "a"))
	return;
    switch (unitp->io_op) {
    case IOC:
	fprintf(unitp->fp, "\f");
	break;
    case OUT:
	for (i = 0; i < 24; i++)
	    for (j = BYTESPERWORD - 1; j >= 0; j--)
		putc(mixalf[
		    (cell[unit[PRINTER].address + i] & ONEBYTE <<
		     BYTESIZE * j) >> BYTESIZE * j],
		     unitp->fp);
	putc('\n', unitp->fp);
	break;
    }
}

@ The punch is connected to stderr.
@<I/O...@>=
void
punch()
{
    int i, j;

    open_stream_unit(unitp, "a");
    for (i = 0; i < 15; i++)
	for (j = BYTESPERWORD - 1; j >= 0; j--)
	    putc(mixalf[
		  (cell[unit[PUNCH].address + i] & ONEBYTE << BYTESIZE * j)
		  >> BYTESIZE * j], unitp->fp);
    putc('\n', unitp->fp);
}
@ The tape units use files tape0 to tape7 in the current directory.
@<I/O...@>=
void
tape()
{
    if (!unitp->fd) {
	unitp->position = unitp->tape_end = 0;
	if (unitp->io_op == OUT) {
	    if ((unitp->fd = open(unitp->path,
				  O_RDWR | O_CREAT | O_TRUNC, 0777)) < 0)
                error(0, errno, "write open failed for %s", unitp->path);
	} else {
	    if (!unitp->fd && (unitp->fd = open(unitp->path, O_RDWR)) < 0)
                error(0, errno, "read open failed for %s", unitp->path);
	}
    }

    switch (unitp->io_op) {
    case OUT:
	if (write(unitp->fd, &cell[unitp->address], 400) < 0)
            error(0, errno, "write failed for %s", unitp->path);
	unitp->position++;
	unitp->tape_end = unitp->position;
	break;
    case IN:
	if (read(unitp->fd, &cell[unitp->address], 400) <= 0)
            error(0, errno, "read failed for %s", unitp->path);
	unitp->position++;
	break;
    case IOC:
	if (unitp->address == 0) {
	    close(unitp->fd);
	    unitp->fd = 0;
	    unitp->position = 0;
	} else {
	    if (unitp->position + unitp->address < 0) {
		close(unitp->fd);
		unitp->position = 0;
	    } else {
		if (lseek(unitp->fd, unitp->address * 400, SEEK_CUR) < 0)
                    error(0, errno, "IOC %d on tape %d failed",
                          unitp->address, fld);
		unitp->position += unitp->address;
	    }
	}
    }
}
@ The disk units use files disk8 to disk15 in the current directory.
They are always opened for update without truncating so that old data
is not destroyed until it is overwritten.
Note that big disk files will never shrink and the only way to recover
space is to delete them outside of MIX.
@<I/O...@>=
void 
disk()
{
    if (!unitp->fd) {
	if ((unitp->fd = open(unitp->path, O_RDWR | O_CREAT, 0777)) < 0)
	    error(0, errno, "open failed for %s", unitp->path);
    }
    switch (unitp->io_op) {
    case IOC:
	unitp->position = unitp->seek_pos;
	break;
    case OUT:
	if (lseek(unitp->fd, unitp->seek_pos * 400, SEEK_SET) < 0)
	    error(0, errno, "seek failed for %s", unitp->path);
	else
	    unitp->position = unitp->seek_pos;
	if (write(unitp->fd, &cell[unitp->address], 400) < 0)
	    error(0, errno, "write failed for %s", unitp->path);
	else
	    unitp->position++;
	break;
    case IN:
	if (lseek(unitp->fd, unitp->seek_pos * 400, SEEK_SET) < 0)
	    error(0, errno, "seek failed for %s", unitp->path);
	else
	    unitp->position = unitp->seek_pos;
	if (read(unitp->fd, &cell[unitp->address], 400) <= 0)
	    error(0, errno, "read failed for %s", unitp->path);
	else
	    unitp->position++;
	break;
    }
}

       	
@*1 Error routines.
@<Aux...@>=
void
indexerror()
{
     error(0, 0, "invalid index register: %d", rI2);
     dump();
}	
@
@<Aux...@>=
void
addrerror()  
{
     error(0, 0, "invalid address: %d", mem);
     dump();
}	
@
@<Aux...@>=
void
operror()  
{
     error(0, 0, "invalid opcode: %d", op);
     dump();
}	
@
@<Aux...@>=
void
memerror()  
{
     error(0, 0, "invalid memory location: %d", mem);
     dump();
}	
@
@<Aux...@>=
void
fielderror()  
{
     error(0, 0, "invalid field: %d", fld);
     dump();
}	
@
@<Aux...@>=
void
sizeerror()  
{
     error(0, 0, "invalid size: %ld", rA);
     dump();
}	

@*1 Dump routines.
@d sch(p) (sign[p] ? '-' : '+' )

@ Dump contents of MIX registers
@<Diag...@>=
void
dump_status()
{
     char t[4], c[8];
     if (ovtog)
	  strcpy(t,"ON");
     else
	  strcpy(t,"OFF");  
     if (!compi)
	  strcpy(c,"EQUAL");
     else if (compi > 0)
	  strcpy(c,"GREATER");
     else
	  strcpy(c,"LESS");
     fprintf(stderr, "Registers A/X    %c0%010lo %c0%010lo\n",
	     sch(0), reg[0], sch(7), reg[7]);
     fprintf(stderr,"                 %c %10ld %c %10ld\n\n",
	     sch(0), reg[0], sch(7), reg[7]);
     fprintf(stderr,
	     "Index Registers  %c0%04lo  %c0%04lo  %c0%04lo  %c0%04lo  %c0%04lo  %c0%04lo \n",
	     sch(1), reg[1], sch(2), reg[2],
	     sch(3), reg[3], sch(4), reg[4],
	     sch(5), reg[5], sch(6), reg[6]);
     fprintf(stderr,
	     "                 %c %4ld  %c %4ld  %c %4ld  %c %4ld  %c %4ld  %c %4ld \n\n",
	     sch(1), reg[1], sch(2), reg[2],
	     sch(3), reg[3], sch(4), reg[4],
	     sch(5),reg[5],sch(6),reg[6]);
     fprintf(stderr,
	     "Jump Register    %c0%04lo     Overflow toggle:      %s\n",
	     sch(8), reg[8], t);
     fprintf(stderr,
	     "                 %c %4ld     Comparison Indicator: %s\n\n",
	     sch(8), reg[8], c);
     fprintf(stderr,
	     "Clock = %"PRI_MIX_CLOCK" u. "
             "Location = %04d, M %d, I %ld, F %d, C %d, inst = %c %010lo \n\n",
	     uclock, loc, mem, INDEX(inst), fld, op, SIGN(inst) ? '-' : '+',
	     MAG(inst));
}

@
@<Global...@>=
int wpn = 5;   /* Number of decoded machine words per line of dump output */

@ Dump contents of the memory starting from the location |from| to location
|to|. Both locations are rounded to the nearest |wpn| boundary.
@<Diag...@>=
void
dump_memory(int from, int to)
{
    char buff[2][132*2];
    char cbuff[132*2];
    char albuff[132*2];
    char tbuff[64];
    int a, i, j, k, flag;
    char *p;
    int b;

    from = (from / wpn) * wpn;
    to   = ((to + wpn - 1) / wpn) * wpn;
    if (to > MEMSIZE)
	to = MEMSIZE;

    k = 0;
    flag = 0;
    a = 0;
    for (i = from; i < to; i += wpn) {
	k = (k + 1) % 2;
	sprintf(buff[k], "%04d ", i);
	for (j = 0; j < wpn; j++) {
	    sprintf(buff[k] + 5 + j * 15,
		    "%c%013ld ",
		    SIGN(cell[i + j]) ? '-' : '+',
		    MAG(cell[i + j]));
	}
	if (strcmp(buff[0] + 5, buff[1] + 5)) {
	    if (flag) {
		if (a - i + wpn)
		    fprintf(stderr,
			    "    Lines %04d to %04d are the same.\n", a,
			    i - wpn);
	    }
	    flag = 0;

	    for (j = 0; j < wpn; j++) {
		sprintf(cbuff + j * 15,
			"%c%04ld %02ld %02ld %02ld ",
			SIGN(cell[i + j]) ? '-' : '+', ADDRESS(cell[i + j]),
			INDEX(cell[i + j]), FIELD(cell[i + j]),
			CODE(cell[i + j]));

		p = tbuff;
		*p++ = '\'';
		for (b = BYTESPERWORD - 1; b >= 0; b--)
		    *p++ = mixalf[(cell[i + j] & ONEBYTE << BYTESIZE * b)
				    >> BYTESIZE * b];
		*p++ = '\'';
		*p = 0;

		sprintf(albuff + j * 15,
			"%-15.15s", tbuff);
	    }
	    fprintf(stderr, "%s\n", buff[k]);
	    fprintf(stderr, "%5.5s%s\n", "", cbuff);
	    fprintf(stderr, "%5.5s%s\n", "", albuff);
	} else {
	    if (!flag)
		a = i;
	    flag = 1;
	}
    }
    if (flag) {
	if (a - i + wpn)
	    fprintf(stderr, "    Lines %04d to %04d are the same.\n", a,
		    i - wpn);
    }
}

@ Dump the entire status of \.{MIX} machine. Exit immediately, unless in
{\tt terminal mode} (i.e. |termmode| is set).
@<Diag...@>=
void
dump()
{
     dump_status();
     dump_memory(0, MEMSIZE);
     if (!termmode)
	  exit(-1);
}

@ \.{GO} button
@<Interface...@>=
void
go()
{
    unit[READER].address = 0;
    unitp = &unit[READER];
    unitp->io_op = IOC;
    reader();
    uclock += unitp->io_time;
    unitp->io_op = IN;
    reader();
    loc = 0; /* Take first instruction from location zero. */
    lastbreak = -1;
    run();
}

@ If the \.{UNIX} file |name| is accessible, bind it to \.{MIX} device 16 and
return 0. Othervise, return -1.
@<Interface...@>=
int
source_deck(char *name)
{
    FILE *infile;
    
    if (name) {
	infile = fopen(name, "r");
	if (!infile) {
            error(0, errno, "can't load card deck %s", name);
	    return -1;
	}
	fclose(infile);
	asgn_io(16, name);
    } 
    return 0;
}

@ Default signal handler for {\tt terminal mode}.
@<Aux...@>=
RETSIGTYPE
sig_int(int sig)
{
    if (termmode) {
        interrupted = 1;
        signal(sig, sig_int);
    } else
	dump();
}

@ Not used currently.
@<Aux...@>=
void
init()
{
    memset(cell, 0, sizeof(cell));
    memset(reg, 0, sizeof(reg));
    memset(sign, 0, sizeof(sign));
    compi = EQUAL;
    ovtog = OFF;  
    uclock = 0;
    instime = 0;
    rA = rX = rI1 = rI2;
}    

@ Not used currently
@<Aux...@>=
void
done()
{
    fclose(infile);
    infile = 0;
}

@ Run \.{MIX} instructions until |halt| gets raised.
@<Interface...@>=
void
run()
{
    running = 1;
    halt = 0;
    while (!halt && loc < MEMSIZE) {
	if (bp_hit(loc)) {
	    if (lastbreak == loc) {
		lastbreak = 0;
	    } else {
		lastbreak = loc;
		disas(stdout, loc, loc+1);
		stepflag = 0;
		return;
	    }
	} else if (interrupted) {
	    interrupted = 0;
	    printf("interrupted at %d\n", loc);
	    return;
	}

	uclock += instime;
	for (fld = 0; fld < MAXUNITS; fld++) { /* Check each unit. */
	    unitp = &unit[fld];
	    if (unitp->clock > 0 && unitp->clock <= uclock) {

		do_io();
	    }
	}
	inst = cell[loc];
	loc++;
	if (loc >= MEMSIZE)
	    addrerror();
	mem = ADDRESS(inst);
	if (SIGN(inst))
	    mem = -mem;
	rI2 = INDEX(inst);
	if (rI2) {
	    if (rI2 > 6)
		indexerror();
	    mem += sign[rI2] ? -reg[rI2] : reg[rI2];
	    if (abs(mem) > TWOBYTES)
		addrerror();
	}
	fld = FIELD(inst);
	op = CODE(inst);
	if (op >= 64)
	    operror(op);
	instime = optable[op].time;
	unitp = &unit[fld];
	(*optable[op].fn) ();

	if (stepflag) {
		disas(stdout, loc, loc+1);
		if (--stepflag == 0)
		     return;
	}

    }
    running = 0;
}				

@*1 Debugging support.

@ Set breakpoint after the current location. If |step_in| is set, step into 
called functions.
@<Debug...@>=
void
set_next(unsigned count, int step_in)
{
     int opcode;
     int br_loc = loc + count - 1;
     int c, f, cc, a;
#define isproccall(c) \
 (CODE(cell[c]) == 39 && FIELD(cell[c]) == 0 && \
  CODE(cell[ADDRESS(cell[c])]) == 32) 
    
     opcode = CODE(cell[br_loc]);
     c = CODE(cell[br_loc]);
     f = FIELD(cell[br_loc]);
     a = ADDRESS(cell[br_loc]);
     cc = CODE(ADDRESS(cell[br_loc]));
     
     if (!step_in && isproccall(br_loc)) {
	  /* opcode == JMP */
	  br_loc++;
	  if (br_loc >= MEMSIZE) {
	       printf("CAN'T SET BREAKPOINT\n");
	       return;
	  }
	  bpoint[0].flags = BP_SET|BP_ACTIVE;
	  bpoint[0].addr = br_loc;
	  bpoint[0].ignore = 0;
	  bpoint[0].delete_after = 1;
	  bpoint[0].next = bpind[br_loc];
	  bpind[br_loc] = 0;
     } else
	  stepflag = count;
}

@ Find next unallocated breakpoint and return its number.
@<Debug...@>=
int
bp_allocate()
{
     int i;
     for (i = 1; i < sizeof(bpoint) / sizeof(bpoint[0]); i++)
	  if (!BP_IS_SET(i)) {
	       memset(bpoint+i, 0, sizeof(bpoint[0]));
	       bpoint[i].flags = BP_SET;
	       return i;
	  }
     return 0;
}

@ Set breakpoint at address |addr|. |count| specifies number of crossings
after which the breakpoint is deleted. -1 means forever.
@<Debug...@>=
void
bp_set(int addr, int count)
{
     int i;
     
     if (loc < 0 || loc >= MEMSIZE) {
	  printf("LOCATION OUT OF ADDRESS SPACE\n");
	  return;
     }
     i = bp_allocate();
     if (i == 0) {
	  printf("OUT OF BREAKPOINT SPACE\n");
	  return;
     }
     bpoint[i].addr = addr;
     bpoint[i].flags |= BP_ACTIVE;
     bpoint[i].delete_after = count;
     bpoint[i].next = bpind[addr];
     bpind[addr] = i;
     printf("BREAKPOINT %d IS SET AT ADDRESS %d\n", i, addr);
     while (i = bpoint[i].next) {
	  if (BP_IS_ACTIVE(i))
	      printf("WARNING: BREAKPOINT %d IS ALSO SET AT ADDRESS %d\n",
		     i, addr);
	  else
	       printf("WARNING: BREAKPOINT %d (DISABLED) IS ALSO SET AT ADDRESS %d\n",
		     i, addr);
     }
}

@ Verify if |n| refers to a valid breakpoint. Return 0 if so, 1 otherwise.
@<Debug...@>=
static int
bp_verify(int n)
{
     if (n < 0 || n >= MEMSIZE) {
	  printf("NUMBER OUT OF BREAKPOINT SPACE\n");
	  return 1;
     }
     if (!BP_IS_SET(n)) {
	  printf("BREAKPOINT %d IS NOT SET\n", n);
	  return 1;
     }
     return 0;
}

@ Return number of the first breakpoint set on address |addr|.
@<Debug...@>=
int
bp_first(int addr)
{
     if (addr < 0 || addr >= MEMSIZE) {
	  printf("LOCATION OUT OF ADDRESS SPACE\n");
	  return 0;
     }
     return bpind[addr];
}

@ Return number of the next breakpoint set on the same address as
the breakpoint number |cur|.
@<Debug...@>=
int
bp_next(int cur)
{
     if (cur < 1 || cur >= MEMSIZE+1) {
	  printf("LOCATION OUT OF ADDRESS SPACE\n");
	  return 0;
     }
     return bpoint[cur].next;
}

@ Clear breakpoint number |n|

@<Debug...@>=
void
bp_delete(int n)
{
     int i;

     if (n == -1) {
	  /* Delete all breakpoints */
	  memset(bpoint, 0, sizeof bpoint);
	  memset(bpind, 0, sizeof bpind);
	  return;
     }
     
     if (bp_verify(n))
	  return;

     i = bpind[bpoint[n].addr];
     if (i == n)
	  bpind[bpoint[n].addr] = bpoint[n].next;
     else {
	  for (; i; i = bpoint[i].next) {
	       if (bpoint[i].next == n) {
		    bpoint[i].next = bpoint[n].next;
		    break;
	       }
	  }
     }    
     bpoint[n].flags = 0;
}

@ Change the status of breakpoint |n| to |status|.

@<Debug...@>=
void
bp_enable(int n, int status)
{
     if (n == -1) {
	  for (n = 0; n < sizeof(bpoint)/sizeof(bpoint[0]); n++)
	       if (BP_IS_SET(n))
		    bp_enable(n, status);
	  return;
     }
     
     if (bp_verify(n))
	  return;
     if (status)
	  bpoint[n].flags |= BP_ACTIVE;
     else
	  bpoint[n].flags &= ~BP_ACTIVE;
}

@ Set ignore count for breakpoint |n|.
@<Debug...@>=
void
bp_set_ignore(int n, unsigned count)
{
     if (bp_verify(n))
	  return;
     bpoint[n].ignore = count;
}
	 
@ Set maximum crossings count for breakpoint |n|.
@<Debug...@>=
void
bp_set_max_crossings(int n, unsigned count)
{
     if (bp_verify(n))
	  return;
     bpoint[n].delete_after = count;
}

@ Print breakpoint |n|. If |n| is -1, print the breakpoint listing header 
instead.

@<Debug...@>=
void
print_breakpoint(int n)
{
     if (n == -1) 
	  printf("%4s %4s %4s %4s %4s %4s\n",
		 "NUM", "LOC", "ENB", "CNT", "IGN", "PAS");
     else
	  printf("%4d %4d %4s %4u %4u %4u\n",
		 n, bpoint[n].addr,
		 BP_IS_ACTIVE(n) ? "Y" : "N",
		 bpoint[n].count, bpoint[n].ignore,
		 bpoint[n].delete_after);
}

@ List all breakpoints.
@<Debug...@>=
void
list_bp(int n, int isloc)
{
     if (n == -1) {
	  print_breakpoint(-1);
	  for (n = 1; n < sizeof(bpoint)/sizeof(bpoint[0]); n++) {
	       if (BP_IS_SET(n))
		    print_breakpoint(n);
	  }
     } else if (isloc) {
	  n = bp_first(n);
	  if (n) {
	       print_breakpoint(-1);
	       do
		    print_breakpoint(n);
	       while (n = bp_next(n));
	  }
     } else if (bp_verify(n) == 0) {
	  print_breakpoint(-1);
	  print_breakpoint(n);
     } 
}

@ Examine all breakpoints set at address |loc|, and return 1 if any of
them is hit.
@<Debug...@>=
int
bp_hit(int addr)
{
     int n;
     int rc = 0;
     for (n = bpind[addr]; n; n = bpoint[n].next) {
	  if (BP_IS_SET(n)) {
	       bpoint[n].count++;
               if (!BP_IS_ACTIVE(n))
		    continue;
	       if (bpoint[n].ignore) {
		    --bpoint[n].ignore;
		    continue;
	       }
	       printf("BREAKPOINT %d\n", n);
	       rc = 1;
	       if (bpoint[n].delete_after && --bpoint[n].delete_after == 0)
		    bp_delete(n);
	  }
     }
     return rc;
}

@ Display the status of \.{MIX} I/O device |dev|.
@<Diag...@>=
void
show_io(int dev)
{
    struct io_device *dp = &unit[dev];

    printf("%4d  %5d  %5d  %4d %4d  %3s  %10"PRI_MIX_CLOCK" %s\n",
	   dev,	
	   dp->io_time,
	   dp->seek_time,
	   dp->address,
           dp->position,
           dp->complete ? "N/A" : mix_opname(dp->io_op, 0),
	   dp->clock,
	   dp->path);
}

@ List the status of \.{MIX} device |dev|. If |dev == -1| list all available
devices.
@<Diag...@>=
void
list_io(int dev)
{
    if (dev >= MAXUNITS) {
	printf("INVALID UNIT NUMBER\n");
	return;
    }
    printf("UNIT    IOT    SKT  ADDR  POS   OP       CLOCK ASGN\n");
    if (dev == -1) {
	for (dev = 0; dev < MAXUNITS; dev++) 
	    show_io(dev);
    } else   
	show_io(dev);
}

@ Assign (bind) \.{UNIX} file |path| to \.{MIX} device |dev|
@<Interface...@>=
void
asgn_io(int dev, char *path)
{
    struct io_device *dp;
    
    if (dev < 0 || dev >= MAXUNITS) {
	printf("INVALID UNIT NUMBER\n");
	return;
    }
    if (strlen(path) > PATH_MAX) {
	printf("PATHNAME TOO LONG\n");
	return;
    }
    dp = &unit[dev];
    if (dev < 16) {
	if (dp->fd > 0) {
	    close(dp->fd);
	    dp->fd = 0;
	}
    } else {
	close_stream_unit(dp);
    }
    strcpy(dp->path, path);
}

@*1 Disassembler functions.
@
@<Disas...@>=
const char *
mix_opname(int c, int f)
{
    int i;

    if (c <= 63) {
	if (dd_cnt[c] == 1)
	    i = dd_ent[c];
	else if (f < dd_cnt[c]) 
	    i = dd_ent[c] + f;
        return mix_optab[i].name;
    }
    return "??";
}

@
@<Disas...@>=
char *
sprintop(char *buf, int loc)
{
    int c, f, i, addr, ind;
    char *p = buf;
    
    c    = CODE(cell[loc]);
    f    = FIELD(cell[loc]);
    addr = ADDRESS(cell[loc]);
    if (SIGN(cell[loc]))
	addr = -addr;
    i    = INDEX(cell[loc]);
    if (c <= 63) {
	if (dd_cnt[c] == 1)
	    ind = dd_ent[c];
	else if (f < dd_cnt[c]) 
	    ind = dd_ent[c] + f;
	else
	    goto badop;
	
	p += sprintf(p, "%s ", mix_optab[ind].name);
	if (addr == loc)
	    p += sprintf(p+14, "*");
	else
	    p += sprintf(p, "%d", addr);
	if (i != 0)
	    p += sprintf(p, ",%d", i);
	if (f != mix_optab[ind].f) {
	    if (mix_optab[ind].notation == 0)
		p += sprintf(p, "(%d)", f);
	    else
		p += sprintf(p, "(%d:%d)", f/8, f%8);
	}
    } else {
    badop:
	sprintf(p, "%c%04ld %02ld %02ld %02ld",
		SIGN(cell[loc]) ? '-' : '+', ADDRESS(cell[loc]),
		INDEX(cell[loc]), FIELD(cell[loc]),
		CODE(cell[loc]));
    }
    return buf;
}

@ Disassemble memory range from |loc| to |stop_loc|. Output disassembled code
to file |fp|.
@<Disas...@>=
void
disas(FILE *fp, int loc, int stop_loc)
{
    int c, f, i, addr, ind;
    
    for ( ; loc < stop_loc; loc++) {
	c    = CODE(cell[loc]);
	f    = FIELD(cell[loc]);
	addr = ADDRESS(cell[loc]);
	if (SIGN(cell[loc]))
	    addr = -addr;
	i    = INDEX(cell[loc]);
	if (c <= 63) {
	    if (dd_cnt[c] == 1)
		ind = dd_ent[c];
	    else if (f < dd_cnt[c]) 
		ind = dd_ent[c] + f;
	    else
		goto badop;

	    fprintf(fp, "%-8d%-6.6s", loc, mix_optab[ind].name);
	    if (addr == loc && mix_optab[ind].name[0] == 'J')
		fprintf(fp, "*");
	    else
		fprintf(fp, "%d", addr);
	    if (i != 0)
		fprintf(fp, ",%d", i);
	    if (f != mix_optab[ind].f) {
		if (mix_optab[ind].notation == 0)
		    fprintf(fp, "(%d)", f);
		else
		    fprintf(fp, "(%d:%d)", f/8, f%8);
	    }
	    fprintf(fp, "\n");
	} else {
	badop:
	    fprintf(fp, "%c%04ld %02ld %02ld %02ld",
		    SIGN(cell[loc]) ? '-' : '+', ADDRESS(cell[loc]),
		    INDEX(cell[loc]), FIELD(cell[loc]),
		    CODE(cell[loc]));
	}
    }
}

@
@<Aux...@>=
void
usage()
{
    printf("usage: mixsim [OPTIONS] [DECK-FILE]\n");
    printf("MIX simulator and terminal\n");
    printf("\n");
    printf("OPTIONS are:\n");

    printf("  -a, --assign-device DEV=NAME  assign file NAME to MIX device #DEV\n");       
    printf("  -t, --terminal                run in terminal mode\n");
    printf("\n");
    printf("Informative options:\n");
    printf("  -h, --help                    print this help summary\n");
    printf("  -V, --version                 print program version and license info\n");
    printf ("\n");
    printf ("Report bugs to <%s>\n", PACKAGE_BUGREPORT);
}

@ Declare long options
@<Aux...@>=

struct option options[] = {
     { "assign-device", required_argument, NULL, 'a' },
     { "terminal", no_argument, NULL, 't' },
     { "help", no_argument, NULL, 'h' },
     { "version", no_argument, NULL, 'V' },
     { NULL }
};

@ 
@<The main program@>=
int
main(int argc, char *argv[])
{
     int i, n;
     char *p;
     
     set_program_name(argv[0]);
     while ((i = getopt_long(argc, argv, "a:htV", options, NULL)) != EOF) {
	  switch (i) {
	  case 'a':
	       n = strtol(optarg, &p, 10);
	       if (*p != '=') 
		    error(1, 0, "device assignment syntax error (near %s)", p);

	       if (n < 0 || n >= MAXUNITS) 
		    error(1, 0, "invalid unit number");
	       
	       asgn_io(n, p+1);
	       break;
	       
	  case 't':
	       termmode++;
	       break;
	       
	  case 'V':
	       mix_version(program_name);
	       exit(0);
	       
	  case 'h':
	       usage();
	       exit(0);
	       
	  default:
	       exit(1);
	  }
     }
     
     signal(SIGINT, sig_int);
     if (argv[optind] && source_deck(argv[optind]))
	  exit(1);
     if (argc - optind > 1)
	  error(0, 0, "excess arguments ignored");

     if (termmode) 
	  mixterm();
     else
	  go();
     return 0;	
}

