/*2:*/
#line 46 "./yfmt.w"

#ifdef HAVE_CONFIG_H
# include <config.h> 
#endif
#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <stdarg.h> 
#include <errno.h> 
#include <assert.h> 
#ifdef HAVE_GETOPT_H
# include <getopt.h> 
#endif

/*:2*//*3:*/
#line 61 "./yfmt.w"

typedef struct{
char*file;
int line;
}Locus;

/*:3*//*4:*/
#line 71 "./yfmt.w"

Locus real_locus,effective_locus;

/*:4*//*6:*/
#line 80 "./yfmt.w"

FILE*infile,*outfile;

/*:6*//*9:*/
#line 102 "./yfmt.w"

void
output_effective_line()
{
fprintf(outfile,"#line %d \"%s\"\n",
effective_locus.line,effective_locus.file);
}

/*:9*//*10:*/
#line 111 "./yfmt.w"

void
output_chars(char*p)
{
fprintf(outfile,"%s",p);
}

/*:10*//*11:*/
#line 119 "./yfmt.w"

char*progname;

/*:11*//*13:*/
#line 131 "./yfmt.w"

void
error(char*fmt,...)
{
va_list ap;

fprintf(stderr,"%s: ",progname);
va_start(ap,fmt);
vfprintf(stderr,fmt,ap);
va_end(ap);
fprintf(stderr,"\n");
}

/*:13*//*14:*/
#line 145 "./yfmt.w"

void
usage_error(char*msg)
{
error(msg);
fprintf(stderr,"Try `%s -h' for more information.\n",progname);
exit(1);
}

/*:14*//*15:*/
#line 155 "./yfmt.w"

void
input_error(char*msg)
{
error("%s:%d: %s",effective_locus.file,effective_locus.line,msg);
}

/*:15*//*16:*/
#line 203 "./yfmt.w"

#define LIMBO 0
#define CHEAD 1
#define DEFNS 2
#define RULES 3
#define CBODY 4
#define CTAIL 5 \

#define EOL 1
#define LINE 2
#define YSEP 3
#define YLBRACE 4
#define YRBRACE 5
#define COMMENT 6 \
 \

#define MAXSAVECHARS 128 \


#line 204 "./yfmt.w"

int state;

/*:16*//*17:*/
#line 208 "./yfmt.w"

typedef void(*Procfun)(void);

/*:17*//*18:*/
#line 212 "./yfmt.w"

/*21:*/
#line 232 "./yfmt.w"

int token;
int lastchar= '\n';

/*:21*//*22:*/
#line 240 "./yfmt.w"

int return_line_info= 0;

/*:22*//*23:*/
#line 249 "./yfmt.w"

char pbuffer[MAXSAVECHARS];
int pindex= 0;

/*:23*//*24:*/
#line 254 "./yfmt.w"

int
nextchar()
{
if(pindex> 0)
lastchar= pbuffer[--pindex];
else{
lastchar= fgetc(infile);
if(lastchar=='\n'){
real_locus.line++;
effective_locus.line++;
}
}
return lastchar;
}

/*:24*//*25:*/
#line 272 "./yfmt.w"

char savebuffer[MAXSAVECHARS];
int saveindex;

/*:25*//*26:*/
#line 277 "./yfmt.w"

void
putback()
{
while(saveindex> 0)
pbuffer[pindex++]= savebuffer[--saveindex];
}

/*:26*//*27:*/
#line 286 "./yfmt.w"

void
putback_last()
{
pbuffer[pindex++]= lastchar;
}

/*:27*//*28:*/
#line 294 "./yfmt.w"

void
clearsave()
{
saveindex= 0;
}

/*:28*//*29:*/
#line 302 "./yfmt.w"

void
savechar()
{
if(saveindex==MAXSAVECHARS){
input_error("Save buffer overflow");
abort();
}
savebuffer[saveindex++]= lastchar;
}

/*:29*//*30:*/
#line 314 "./yfmt.w"

void
skipchars()
{
while(nextchar()!=EOF&&lastchar!='\n')
;
}

/*:30*//*31:*/
#line 324 "./yfmt.w"

void
save_effective_line()
{
saveindex= sprintf(savebuffer,"#line %d \"%s\"\n",
effective_locus.line,effective_locus.file);
if(saveindex==MAXSAVECHARS){
input_error("Save buffer overflow");
abort();
}
}

/*:31*//*32:*/
#line 337 "./yfmt.w"

void
flushsave()
{
if(saveindex){
fwrite(savebuffer,saveindex,1,outfile);
clearsave();
}
}

/*:32*//*33:*/
#line 349 "./yfmt.w"

void
copychars()
{
if(token==EOL)
fputc('\n',outfile);
else{
flushsave();
while(nextchar()!=EOF&&lastchar!='\n')
fputc(lastchar,outfile);
if(lastchar=='\n')
fputc(lastchar,outfile);
}
}

/*:33*//*34:*/
#line 365 "./yfmt.w"

int
get_token()
{
static char*linestr= "line";

if(lastchar!='\n')
skipchars();

if(nextchar()==EOF)
return EOF;

if(lastchar=='\n')
return EOL;
else if(lastchar=='#'){
int n;
char*p;

savechar();
while(nextchar()&&isspace(lastchar))
;

for(p= linestr;*p;p++,nextchar()){
savechar();
if(lastchar!=*p)
return LINE;
}

while(nextchar()&&isspace(lastchar))
;

clearsave();
if(!isdigit(lastchar))
input_error("Invalid #line directive");
else{
for(n= 0;isdigit(lastchar);nextchar())
n= n*10+lastchar-'0';

effective_locus.line= n-1;

while((lastchar!='\n'&&isspace(lastchar))&&nextchar())
;

if(lastchar=='"'){

while(nextchar()&&lastchar!='"')
savechar();

effective_locus.file= malloc(saveindex+1);
assert(effective_locus.file!=NULL);
memcpy(effective_locus.file,savebuffer,saveindex);
effective_locus.file[saveindex]= 0;

clearsave();
}
if(return_line_info){
save_effective_line();
return LINE;
}
}
}else if(lastchar=='%'){
savechar();
nextchar();
savechar();
switch(lastchar){
case'{':
return YLBRACE;

case'}':
return YRBRACE;

case'%':
return YSEP;

default:
return LINE;
}
}else if(lastchar=='/'){
savechar();
if(nextchar()=='*'){
do{
do
savechar();
while(nextchar()&&lastchar!='*');
savechar();
}while(nextchar()&&lastchar!='/');
savechar();
return COMMENT;
}else
return LINE;
}else{
savechar();
return LINE;
}
return get_token();
}

/*:34*//*35:*/
#line 463 "./yfmt.w"

int
gettkn()
{
return token= get_token();
}

/*:35*/
#line 213 "./yfmt.w"

/*36:*/
#line 471 "./yfmt.w"

void
proc_limbo()
{
return_line_info= 0;
while(state==LIMBO&&gettkn()> 0){
if(token==YLBRACE)
state= CHEAD;
else if(token==YSEP)
state= RULES;
else if(saveindex> 0&&savebuffer[0]=='%')
copychars();
else
clearsave();
}
}

/*:36*//*37:*/
#line 489 "./yfmt.w"

void
proc_chead()
{
return_line_info= 1;
copychars();
output_effective_line();
while(state==CHEAD&&gettkn()> 0){
copychars();
if(token==YRBRACE)
state= DEFNS;
}
}

/*:37*//*38:*/
#line 504 "./yfmt.w"

void
proc_defns()
{
return_line_info= 0;
while(state==DEFNS&&gettkn()> 0){
if(token==COMMENT)
fputc('\t',outfile);
copychars();
if(token==YSEP)
state= RULES;
}
}

/*:38*//*40:*/
#line 544 "./yfmt.w"

void
proc_rules()
{
int ws= 0;

return_line_info= 0;

while(state==RULES&&gettkn()> 0){
if(token==YSEP)
state= CTAIL;
else if(token==EOL)
;
else if(token==COMMENT){
fputc('\t',outfile);
copychars();
}else if(token!=EOL){
int quote= 0;
int escape= 0;

putback();
do{
nextchar();
if(escape)
escape= 0;
else if(quote){
if(lastchar==quote)
quote= 0;
}else if(lastchar=='\\')
escape= 1;
else if(lastchar=='"')
quote= '"';
else if(lastchar=='[')
quote= ']';
else if(lastchar=='\'')
quote= '\'';
else if(lastchar==' '||lastchar=='\t')
ws= 1;
else if(lastchar=='{'){
if(ws){
state= CBODY;
break;
}
}
savechar();
}while(lastchar!='\n');
ws++;
flushsave();
}
}
}

/*:40*//*41:*/
#line 597 "./yfmt.w"

void
proc_cbody()
{
int nesting= 0;
int quote= 0;

return_line_info= 1;

output_chars("\t{");

for(nextchar();lastchar==' '||lastchar=='\t';nextchar())
fputc(lastchar,outfile);

if(lastchar!='\n'){
fputc('\n',outfile);
putback_last();
}else{
fputc(lastchar,outfile);
if(gettkn()<0)
return;
putback();
}

output_effective_line();
while(1){
int escape= 0;

if(!strchr(" \t#",lastchar)&&!quote)
fputc('\t',outfile);
do{
nextchar();
if(escape)
escape= 0;
else if(quote){
if(lastchar==quote)
quote= 0;
}else if(lastchar=='\\')
escape= 1;
else if(lastchar=='"')
quote= '"';
else if(lastchar=='\'')
quote= '\'';
else if(lastchar=='{')
nesting++;
else if(lastchar=='}'){
if(nesting--==0){
fputc(lastchar,outfile);
fputc('\n',outfile);
state= RULES;
return;
}
}
fputc(lastchar,outfile);
}while(lastchar!='\n');

if(gettkn()<=0)
break;
if(lastchar=='\n')
savechar();
putback();
}
}

/*:41*//*42:*/
#line 662 "./yfmt.w"

void
proc_ctail()
{
return_line_info= 1;
copychars();
output_effective_line();
while(gettkn()> 0)
copychars();
}


/*:42*/
#line 214 "./yfmt.w"


/*:18*//*19:*/
#line 217 "./yfmt.w"

Procfun process[]= {proc_limbo,proc_chead,proc_defns,proc_rules,
proc_cbody,proc_ctail};

/*:19*//*20:*/
#line 222 "./yfmt.w"

int
convertor()
{
while(token!=EOF)
process[state]();
return 0;
}

/*:20*//*39:*/
#line 519 "./yfmt.w"

int
ctangle_comment()
{
if(saveindex> 3&&memcmp(savebuffer,"/*",2)==0){
int i;

if(savebuffer[2]==':'){
for(i= 3;i<saveindex&&savebuffer[i]!='*';i++)
if(!isdigit(savebuffer[i]))
return 0;

return i+1<saveindex&&savebuffer[i+1]=='/';
}else if(isdigit(savebuffer[2])){
for(i= 3;i<saveindex&&savebuffer[i]!=':';i++)
if(!isdigit(savebuffer[i]))
return 0;

return saveindex-i> 3&&memcmp(savebuffer+i,":*/",3)==0;
}
}
return 0;
}

/*:39*//*43:*/
#line 675 "./yfmt.w"

int
main(int argc,char**argv)
{
int c;
char*outname= "-";

/*12:*/
#line 123 "./yfmt.w"

progname= strrchr(argv[0],'/');
if(progname)
progname++;
else
progname= argv[0];

/*:12*/
#line 682 "./yfmt.w"

while((c= getopt(argc,argv,"o:h"))!=EOF){
switch(c){
case'o':
outname= optarg;
break;
case'h':
printf("usage: yfmt [-o outfile][-h] filename\n");
exit(0);
default:
exit(1);
}
}

if(optind==argc)
usage_error("Not enough arguments.");
else if(argc-optind> 1)
usage_error("Too many arguments.");

/*7:*/
#line 84 "./yfmt.w"

if(strcmp(argv[optind],"-")==0)
infile= stdin;
else if((infile= fopen(argv[optind],"r"))==NULL){
error("Cannot open input file `%s': %s",argv[optind],strerror(errno));
exit(1);
}

/*:7*/
#line 701 "./yfmt.w"

/*8:*/
#line 93 "./yfmt.w"

if(strcmp(outname,"-")==0)
outfile= stdout;
else if((outfile= fopen(outname,"w"))==NULL){
error("Cannot open output file `%s': %s",outname,strerror(errno));
exit(1);
}

/*:8*/
#line 702 "./yfmt.w"


/*5:*/
#line 75 "./yfmt.w"

real_locus.file= effective_locus.file= argv[optind];
real_locus.line= effective_locus.line= 1;

/*:5*/
#line 704 "./yfmt.w"


exit(convertor());
}


/*:43*/
