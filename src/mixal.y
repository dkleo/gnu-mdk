%{
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


%}

	/*:7*//*9:*/

%union{
unsigned val;
Symbol*symp;
char*txt;
char literal[6];
struct mix_op*opcode;
}

	/*:9*//*10:*/

%token<symp> DEFINED_SYMBOL
%token<symp> LOCAL_SYMBOL
%token<symp> FUTURE_REFERENCE
%token<symp> LOC
%token<symp> END
%token<val> UNDEF
%token<val> DEF
%token<val> NUMBER
%token<val> ASTERISK
%token<txt> TEXT
%token<literal> ALF PSEUDO
%token<opcode> OPCODE
%token BOGUS
%left'-''+'
%left'*''/'
%left':'SLASHES
%nonassoc UMINUS

	/*:10*//*11:*/

%type<val> expression
%type<val> atomic_expression
%type<val> a_part i_part f_part w_value
%type<symp> literal_constant
%type<symp> label
%type<opcode> op
%type<literal> pseudo

%%
	/*:11*//*13:*/
statement_list:statement comment eol
|statement_list statement comment eol
;
	/*:13*//*14:*/
statement_list:statement_list error eol
	{
#line 169 "./mixal.yw"
	yyerrok;
	yyclearin;
	reset_lex();
	}
	/*:14*//*15:*/
eol:'\n'
	{
#line 177 "./mixal.yw"
	lineno++;}
|eol'\n'
	{
#line 179 "./mixal.yw"
	lineno++;}
;
	/*:15*//*16:*/
statement:label op a_part i_part f_part
	{
#line 186 "./mixal.yw"
	unsigned word;
	
	word= $2->c|SIGN($3)|MAG($3)*B3|$4*B2|$5*B1;
	update_memory(word);
	}
;
	/*:16*//*17:*/
statement:label pseudo w_value
	{
#line 197 "./mixal.yw"
	if(!strcmp($2,"EQU")){
	
	if($1==NULL)
	dumpsymtab(stderr);
	else
	$1->value= $3;
	}else if(!strcmp($2,"ORIG")){
	location_counter= word_s($3);
	}else if(!strcmp($2,"CON")){
	update_memory($3);
	}else if(!strcmp($2,"END")){
	if($1!=NULL)
	$1->type= END;
	start_location= $3;
	YYACCEPT;
	}
	}
|label ALF
	{
#line 216 "./mixal.yw"
	update_memory(num($2));
	}
|ASTERISK{;}
;
	/*:17*//*18:*/
label:
	{
#line 225 "./mixal.yw"
	$$= NULL;
	}
|LOC
	{
#line 229 "./mixal.yw"
	if(localref($1->name,"FB")){
	yyerror("invalid label");
	YYERROR;
	}
	$1->type= DEF;
	$1->line= lineno;
	$1->value= location_counter;
	$$= $1;
	}
;
	/*:18*//*19:*/
comment:
|TEXT	{
#line 243 "./mixal.yw"
	;}
;
	/*:19*//*20:*/
op:OPCODE
	{
#line 250 "./mixal.yw"
	opfield= $1->f;
	}
;
	/*:20*//*21:*/
pseudo:PSEUDO
	{
#line 259 "./mixal.yw"
	opfield= 5;
	}
;
	/*:21*//*22:*/
expression:atomic_expression
|'+'atomic_expression%prec UMINUS
	{
#line 268 "./mixal.yw"
	$$= $2;
	}
|'-'atomic_expression%prec UMINUS
	{
#line 272 "./mixal.yw"
	$$= $2^MINUS;
	}
|expression'+'atomic_expression
	{
#line 276 "./mixal.yw"
	$$= add_mix($1,$3);
	}
|expression'-'atomic_expression
	{
#line 280 "./mixal.yw"
	$$= sub_mix($1,$3);
	}
|expression ASTERISK atomic_expression%prec'*'
	{
#line 284 "./mixal.yw"
	$$= mul_mix($1,$3);
	}
|expression'/'atomic_expression
	{
#line 288 "./mixal.yw"
	$$= div_mix($1,$3);
	}
|expression SLASHES atomic_expression
	{
#line 292 "./mixal.yw"
	$$= mul_mix($1,B5/MAG($3));
	}
|expression':'atomic_expression
	{
#line 296 "./mixal.yw"
	$$= add_mix(mul_mix($1,8),$3);
	}
;
	/*:22*//*23:*/
atomic_expression:NUMBER
|ASTERISK
	{
#line 305 "./mixal.yw"
	$$= location_counter;
	}
|DEFINED_SYMBOL
	{
#line 309 "./mixal.yw"
	$$= $1->value;
	if(xref)
	$1->xref= addref($1->xref,location_counter,
	lineno);
	}
|LOCAL_SYMBOL
	{
#line 316 "./mixal.yw"
	$$= $1->value;
	}
;
	/*:23*//*24:*/
a_part:
	{
#line 324 "./mixal.yw"
	$$= 0;
	}
|expression
|FUTURE_REFERENCE
	{
#line 329 "./mixal.yw"
	$1->reflist= addref($1->reflist,location_counter,lineno);
	if(xref)
	$1->xref= addref($1->xref,location_counter,
	lineno);
	$$= 0;
	}
|literal_constant
	{
#line 337 "./mixal.yw"
	$$= 0;
	}
;
	/*:24*//*25:*/
i_part:
	{
#line 345 "./mixal.yw"
	$$= 0;
	}
|','expression
	{
#line 349 "./mixal.yw"
	$$= $2;
	}
;
	/*:25*//*26:*/
f_part:
	{
#line 357 "./mixal.yw"
	$$= opfield;
	}
|'('expression')'
	{
#line 361 "./mixal.yw"
	$$= $2;
	}
;
	/*:26*//*27:*/
w_value:expression f_part
	{
#line 369 "./mixal.yw"
	$$= w_eval(0,$1,$2);
	}
|w_value','expression f_part
	{
#line 373 "./mixal.yw"
	$$= w_eval($1,$3,$4);
	}
;
	/*:27*//*28:*/
literal_constant:'='w_value'='
	{
#line 381 "./mixal.yw"
	char literal[13];
	Symbol*s;
	
	sprintf(literal,"=%d=",word_s($2));
	if(!(s= lookup(literal)))
	s= install(literal,$2,lineno);
	s->reflist= addref(s->reflist,location_counter,lineno);
	if(xref)
	s->xref= addref(s->xref,location_counter,lineno);
	}
;
%%
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
