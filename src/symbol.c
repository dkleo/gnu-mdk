#define UNDEFINED 0
#define KEYWORD 1
#define SYMBOL 2 \

#define getnext(a) ((a) ->next) 
#define setnext(a,l) (a->next= l,l= a)  \

/*2:*/
#line 25 "./symbol.w"

#include <stdlib.h> 
#include <stdio.h> 
#include <string.h> 
#include <mix.h> 
#include <mixasm.h> 
#include "xalloc.h"

/*:2*//*3:*/
#line 38 "./symbol.w"

static unsigned int hash_size[]= {
37,101,229,487,1009,2039,4091,8191,16411
};

/*:3*//*4:*/
#line 44 "./symbol.w"

static unsigned int max_rehash= sizeof(hash_size)/sizeof(hash_size[0]);

/*:4*//*5:*/
#line 50 "./symbol.w"

static unsigned int hash_num;

/*:5*//*7:*/
#line 67 "./symbol.w"

struct symtab{
int state;
union{
char*name;
Symbol sym;
struct mix_op op;
}v;
};

static struct symtab*symtable;

/*:7*//*8:*/
#line 80 "./symbol.w"

static struct symtab*lookup_or_install(int type,char*name,int install);

/*:8*//*9:*/
#line 84 "./symbol.w"

unsigned
hash(char*name)
{
unsigned i;

for(i= 0;*name;name++){
i<<= 1;
i^= *(unsigned char*)name;
}
return i%hash_size[hash_num];
}

/*:9*//*10:*/
#line 103 "./symbol.w"

int
rehash()
{
struct symtab*old_symtab= symtable;
struct symtab*sp;
unsigned int i;

if(++hash_num>=max_rehash){
return 1;
}

symtable= calloc(hash_size[hash_num],sizeof(symtable[0]));
if(!symtable){
fprintf(stderr,"not enough memory\n");
abort();
}
if(old_symtab){
for(i= 0;i<hash_size[hash_num-1];i++){
if(old_symtab[i].state!=UNDEFINED){
sp= lookup_or_install(old_symtab[i].state,
old_symtab[i].v.name,1);
sp->state= old_symtab[i].state;
memcpy(&sp->v,&old_symtab[i].v,sizeof sp->v);
}
}
free(old_symtab);
}
return 0;
}

/*:10*//*11:*/
#line 142 "./symbol.w"

static struct symtab*
lookup_or_install(int state,char*name,int install)
{
unsigned i,pos;

if(!symtable){
if(install){
if(rehash())
return NULL;
}else
return NULL;
}

pos= hash(name);

for(i= pos;symtable[i].state!=UNDEFINED;){
if(symtable[i].state==state&&strcmp(symtable[i].v.name,name)==0)
return&symtable[i];
if(++i>=hash_size[hash_num])
i= 0;
if(i==pos)
break;
}

if(!install)
return NULL;

if(symtable[i].state==UNDEFINED)
return&symtable[i];

if(rehash())
return NULL;

return lookup_or_install(state,name,install);
}

/*:11*//*12:*/
#line 180 "./symbol.w"

Symbol*
lookup(char*name)
{
struct symtab*sp= lookup_or_install(SYMBOL,name,0);
return sp?&sp->v.sym:NULL;
}

/*:12*//*13:*/
#line 189 "./symbol.w"

struct mix_op*
lookup_op(char*name)
{
struct symtab*sp= lookup_or_install(KEYWORD,name,0);
return sp?&sp->v.op:NULL;
}


/*:13*//*14:*/
#line 199 "./symbol.w"

Symbol*
install(char*name,int v,int l)
{
struct symtab*sp= lookup_or_install(SYMBOL,name,1);
if(!sp)
return NULL;

if(sp->state==UNDEFINED){

sp->state= SYMBOL;
memset(&sp->v.sym,0,sizeof sp->v.sym);
sp->v.sym.name= xmalloc(strlen(name)+1);
strcpy(sp->v.sym.name,name);
sp->v.sym.value= v;
sp->v.sym.line= l;
sp->v.sym.reflist= 0;
}
return&sp->v.sym;
}

/*:14*//*15:*/
#line 221 "./symbol.w"

void
install_op(struct mix_op*op)
{
struct symtab*sp= lookup_or_install(KEYWORD,op->name,1);
if(!sp)
abort();
if(sp->state==UNDEFINED){

sp->state= KEYWORD;
sp->v.op= *op;
}else
abort();
}

/*:15*//*16:*/
#line 243 "./symbol.w"

unsigned
iterate(int(*fun)(Symbol*))
{
int i;
unsigned count;
for(i= 0,count= 0;i<hash_size[hash_num];i++)
if(symtable[i].state==SYMBOL&&fun(&symtable[i].v.sym))
break;
return count;
}

/*:16*//*17:*/
#line 256 "./symbol.w"

static int
compsym(const void*a,const void*b)
{
Symbol*const*sa= a;
Symbol*const*sb= b;

return(*sa)->value-(*sb)->value;
}

/*:17*//*18:*/
#line 268 "./symbol.w"

Symbol**
sort_symbols()
{
int i,j;
unsigned count;
Symbol**sp;

/*:18*//*19:*/
#line 277 "./symbol.w"

for(i= 0,count= 0;i<hash_size[hash_num];i++)
if(symtable[i].state==SYMBOL)
count++;

sp= calloc(count+1,sizeof(*sp));
if(!sp){
fprintf(stderr,"not enough memory\n");
abort();
}

/*:19*//*20:*/
#line 289 "./symbol.w"

for(i= j= 0;i<hash_size[hash_num];i++)
if(symtable[i].state==SYMBOL)
sp[j++]= &symtable[i].v.sym;
sp[j]= NULL;

/*:20*//*21:*/
#line 296 "./symbol.w"

qsort(sp,count,sizeof*sp,compsym);

return sp;
}

/*:21*//*22:*/
#line 307 "./symbol.w"

typedef struct list{
struct list*next;
}List;


/*:22*//*23:*/
#line 315 "./symbol.w"

List*
sortl(List*list,int(*compare)())
{
List*low_list,*high_list,*current,*pivot,*temp;
int result;

if(!list)
return NULL;

/*:23*//*24:*/
#line 327 "./symbol.w"

current= list;
do{
current= getnext(current);
if(!current)
return list;
}while(0==(result= compare(list,current)));

/*:24*//*25:*/
#line 338 "./symbol.w"


if(result> 0)
pivot= current;
else
pivot= list;

/*:25*//*26:*/
#line 346 "./symbol.w"

low_list= high_list= NULL;

/*:26*//*27:*/
#line 350 "./symbol.w"

current= list;
while(current){
temp= getnext(current);
if(compare(pivot,current)<0){

setnext(current,high_list);
high_list= current;
}else{

setnext(current,low_list);
low_list= current;
}
current= temp;
}

/*:27*//*28:*/
#line 367 "./symbol.w"

low_list= sortl(low_list,compare);
high_list= sortl(high_list,compare);

/*:28*//*29:*/
#line 373 "./symbol.w"

current= temp= low_list;
while(1){
current= getnext(current);
if(!current)
break;
temp= current;
}
/*:29*//*30:*/
#line 382 "./symbol.w"

setnext(temp,high_list);
return low_list;
}

/*:30*//*31:*/
#line 388 "./symbol.w"

static int
compref(struct ref*a,struct ref*b)
{
return a->line-b->line;
}

/*:31*//*32:*/
#line 396 "./symbol.w"

void
sort_refs(Symbol*s)
{
s->xref= (struct ref*)sortl((List*)s->xref,compref);
}

/*:32*//*33:*/
#line 404 "./symbol.w"

ref*
addref(ref*p,int loc,int line)
{
ref*sp;

sp= (ref*)xmalloc(sizeof(ref));
sp->next= p;
sp->address= loc;
sp->line= line;
return sp;
}
/*:33*/
