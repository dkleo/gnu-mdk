% This file is part of mix
% Copyright (C) 2005, 2007 Sergey Poznyakoff
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

@*SYMBOL TABLES FOR MIX ASSEMBLER.

@s Symbol int
@s symtab int
@s ref int
@s line c

@ Header files.
@c
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <mix.h>
#include <mixasm.h>
#include "xalloc.h"

@ |hash_size| defines a sequence of symbol table sizes. These are prime numbers,
the distance between each pair of them grows exponentially, starting from 64.
Hardly someone will need more than 16411 symbols, and even if someone will,
it is easy enough to add more numbers to the sequence.

@c
static unsigned int hash_size[] = {
    37,   101,  229,  487, 1009, 2039, 4091, 8191, 16411
};

@ |max_rehash| keeps the number of entries in |hash_size| table.
@c
static unsigned int max_rehash = sizeof (hash_size) / sizeof (hash_size[0]);

@ |hash_num| is the index to |hash_size| table. Current size of the
|symtab| table is thus |hash_size[hash_num]|

@c
static unsigned int hash_num;  

@ The symbol table is used to keep two kinds of data: \.{MIXAL} reserved
keywords (|struct mix_op|) and symbols defined in the program. So, each
symbol table entry can be in one of three states:
     
@d UNDEFINED 0      /* The entry is not defined */
@d KEYWORD 1        /* The entry holds a \.{MIXAL} reserved keyword */
@d SYMBOL 2         /* The entry holds a symbol defined in user program */

@ Both |struct mix_op| and |struct Symbol| are designed so their first
member is |char *name|, i.e. the symbol name. So it is safe to enclose
them into a union.

A symbol table entry has the following structure;

@c
struct symtab {
     int state;     /* Entry state */
     union {
	  char *name;     /* Name of the symbol if |state != UNDEFINED| */
  	  Symbol sym;     /* if |state == SYMBOL| */
	  struct mix_op op; /* if |state == KEYWORD| */
     } v;
};

static struct symtab *symtable; /* Table of symbols */

@ Forward declaration for |lookup_or_install|
@c
static struct symtab *lookup_or_install(int type, char *name, int install);

@ Hash function. This should probably be revised.
@c
unsigned
hash(char *name)
{
    unsigned i;

    for (i = 0; *name; name++) {
        i <<= 1;
        i ^= *(unsigned char*) name;
    }
    return i % hash_size[hash_num];
}

@ |rehash| is called when the symbol table becomes full. Its purpose is
to select new table size, allocate storage for the resized table, install
to it all data stored so far and reclaim the unused memory.

|rehash| returns |0| on success and |1| otherwise.
     
@c
int
rehash()
{
     struct symtab *old_symtab = symtable;
     struct symtab *sp;
     unsigned int i;
     
     if (++hash_num >= max_rehash) {
	  return 1;
     }

     symtable = calloc(hash_size[hash_num], sizeof(symtable[0]));
     if (!symtable) {
	  fprintf(stderr, "not enough memory\n");
	  abort();
     }
     if (old_symtab) {
	  for (i = 0; i < hash_size[hash_num - 1]; i++) {
	       if (old_symtab[i].state != UNDEFINED) {
		    sp = lookup_or_install(old_symtab[i].state,
					   old_symtab[i].v.name, 1);
		    sp->state = old_symtab[i].state;
		    memcpy(&sp->v, &old_symtab[i].v, sizeof sp->v);
	       }
	  }
	  free(old_symtab);
     }
     return 0;
}

@ Look up symbol |name| in the table. If not found and |install| is not 0, 
insert the symbol into the table.

Basically it uses algorithm L from TAOCP 6.4, except that if the insertion
fails the table is rehashed and the attempt is retried. The process continues
until the symbol is successfully inserted or the table reaches maximum allowed
size.

@c
static struct symtab *
lookup_or_install(int state, char *name, int install)
{
     unsigned i, pos;

     if (!symtable) {
	  if (install) {
	       if (rehash())
		    return NULL;
	  } else
	       return NULL;
     }

     pos = hash(name);

     for (i = pos; symtable[i].state != UNDEFINED;) {
	  if (symtable[i].state == state && strcmp(symtable[i].v.name, name) == 0)
	       return &symtable[i];
	  if (++i >= hash_size[hash_num])
	       i = 0;
	  if (i == pos)
	       break;
     }

     if (!install)
	  return NULL;

     if (symtable[i].state == UNDEFINED)
	  return &symtable[i];

     if (rehash())
	  return NULL;

     return lookup_or_install(state, name, install);
}

@ Look up a symbol |name|.
@c
Symbol *
lookup(char *name)
{
     struct symtab *sp = lookup_or_install(SYMBOL, name, 0);
     return sp ? &sp->v.sym : NULL;
}

@ Look up an opcode |name|.
@c
struct mix_op *
lookup_op(char *name)
{
     struct symtab *sp = lookup_or_install(KEYWORD, name, 0);
     return sp ? &sp->v.op : NULL;
}


@ Install a symbol |name| with value |v|, defined on line |l|.
@c
Symbol *
install(char *name, int v, int l)
{
     struct symtab *sp = lookup_or_install(SYMBOL, name, 1);
     if (!sp)
	  return NULL;

     if (sp->state == UNDEFINED) {
	  /* new entry */
	  sp->state = SYMBOL;
	  memset(&sp->v.sym, 0, sizeof sp->v.sym);
	  sp->v.sym.name = xmalloc(strlen(name)+1); 
	  strcpy(sp->v.sym.name, name);
	  sp->v.sym.value = v;
	  sp->v.sym.line = l;    
	  sp->v.sym.reflist = 0;
     }
     return &sp->v.sym;
}

@ Install \.{MIXAL} opcode |op|
@c
void
install_op(struct mix_op *op)
{
     struct symtab *sp = lookup_or_install(KEYWORD, op->name, 1);
     if (!sp)
          abort();
     if (sp->state == UNDEFINED) {
	  /* new entry */
	  sp->state = KEYWORD;
	  sp->v.op = *op;
     } else
          abort();
}

@ Iterate over all entries with state |SYMBOL|. Call user-supplied
function |fun| for each found symbol.

Stop when the entire symbol table is scaned or |fun| returns non-0,
whichever happens first.

Return number of symbols processed.     
@c
unsigned
iterate(int (*fun)(Symbol *))
{
     int i;
     unsigned count;
     for (i = 0, count = 0; i < hash_size[hash_num]; i++) 
	  if (symtable[i].state == SYMBOL && fun(&symtable[i].v.sym))
	       break;
     return count;
}

@ Comparator function for an array |Symbol **|
@c
static int
compsym(const void *a, const void *b)
{
     Symbol *const *sa = a;
     Symbol *const *sb = b;

     return (*sa)->value - (*sb)->value;
}

@ Compress the hash table into an array of symbols, sorted by their value.
Allocates memory.
@c
Symbol **
sort_symbols()
{
     int i, j;
     unsigned count;
     Symbol **sp;

@ First pass: count existing symbols.
@c
     for (i = 0, count = 0; i < hash_size[hash_num]; i++) 
	  if (symtable[i].state == SYMBOL)
	       count++;

     sp = calloc(count + 1, sizeof(*sp));
     if (!sp) {
	  fprintf(stderr, "not enough memory\n");
	  abort();
     }

@ Second pass: fill in the return array.
@c
     for (i = j = 0; i < hash_size[hash_num]; i++)
	  if (symtable[i].state == SYMBOL)
	       sp[j++] = &symtable[i].v.sym;
     sp[j] = NULL; /* Mark end of data */

@ Third pass: sort the array and return.
@c
     qsort(sp, count, sizeof *sp, compsym);

     return sp;
}
     
@*1 Reference functions.

@d getnext(a) ((a)->next)
@d setnext(a,l) (a->next = l, l = a)

@c
typedef struct list {
     struct list *next;
} List;


@ Quicksort routine for linked lists. Based on the general-purpose routine 
by Jon Guthrie.
@c
List *
sortl(List *list, int (*compare)())
{
    List *low_list, *high_list, *current, *pivot, *temp;
    int     result;

    if (!list)
        return NULL;

@ Find the first element that doesn't have the same value as the first
element.
@c
    current = list;
    do {
        current = getnext(current);
        if (!current)
            return list;
    } while (0 == (result = compare(list, current)));

@ My pivot value is the lower of the two.  This insures that the sort will
always terminate by guaranteeing that there will be at least one member of
both of the sublists.
@c

    if (result > 0)
        pivot = current;
    else
        pivot = list;

@ Initialize the sublist pointers.
@c
    low_list = high_list = NULL;

@ Now, separate the items into the two sublists
@c
    current = list;
    while (current) {
        temp = getnext(current);
        if (compare(pivot, current) < 0) {
            /* add one to the high list */
            setnext(current, high_list);
            high_list = current;
        } else {
            /* add one to the low list */
            setnext(current, low_list);
            low_list = current;
        }
        current = temp;
    }

@ And, recursively call the sort for each of the two sublists.
@c
    low_list  = sortl(low_list, compare);
    high_list = sortl(high_list, compare);

@ Now, I have to put the "high" list after the end of the "low" list.  
To do that, I first have to find the end of the "low" list...
@c
    current = temp = low_list;
    while (1) {
        current = getnext(current);
        if (!current)
            break;
        temp = current;
    }
@ Then, I put the "high" list at the end of the low list.
@c
    setnext(temp, high_list);
    return low_list;
}

@ Compare two reference entries
@c
static int
compref(struct ref *a, struct ref *b)
{
    return a->line - b->line;
}

@
@c
void
sort_refs(Symbol *s)
{
    s->xref = (struct ref *)sortl((List*)s->xref, compref);
}

@
@c
ref *
addref(ref *p, int loc, int line)
{
    ref *sp;

    sp = (ref *) xmalloc(sizeof(ref));
    sp->next = p;
    sp->address = loc;
    sp->line = line;
    return sp;
}

