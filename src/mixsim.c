#define ADDRESS(word) (word&TWOBYTES<<3*BYTESIZE) >>3*BYTESIZE
#define INDEX(word) (word&ONEBYTE<<2*BYTESIZE) >>2*BYTESIZE
#define FIELD(word) (word&ONEBYTE<<BYTESIZE) >>BYTESIZE
#define CODE(word) (word&ONEBYTE) 
#define ONEBYTE 077
#define TWOBYTES 07777
#define FIVEBYTES 07777777777
#define WORDSIZE BYTESIZE*BYTESPERWORD
#define LDA 8
#define LDAN 16
#define STA 24
#define IOC 35
#define IN 36
#define OUT 37
#define JA 40
#define INCA 48
#define CMPA 56
#define ON 1
#define OFF 0
#define LESS -1
#define EQUAL 0
#define GREATER 1 \

#define areg reg[0]
#define i1reg reg[1]
#define i2reg reg[2]
#define i3reg reg[3]
#define i4reg reg[4]
#define i5reg reg[5]
#define i6reg reg[6]
#define xreg reg[7]
#define jreg reg[8]
#define zero reg[9]
#define signa sign[0]
#define sign1 sign[1]
#define sign2 sign[2]
#define sign3 sign[3]
#define sign4 sign[4]
#define sign5 sign[5]
#define sign6 sign[6]
#define signx sign[7]
#define signj sign[8]
#define signz sign[9] \

#define BP_SET 0x01
#define BP_ACTIVE 0x02
#define BP_IS_SET(n) (bpoint[n].flags&BP_SET) 
#define BP_IS_ACTIVE(n) (bpoint[n].flags&BP_ACTIVE)  \

#define TAPE7 7
#define DISK8 8
#define DISK15 15
#define READER 16
#define PUNCH 17
#define PRINTER 18
#define TTY 19
#define MAXUNITS 20 \

#define sch(p) (sign[p]?'-':'+')  \

/*2:*/
#line 33 "./mixsim.w"

/*9:*/
#line 101 "./mixsim.w"

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

/*:9*/
#line 34 "./mixsim.w"

/*10:*/
#line 120 "./mixsim.w"

long cell[MEMSIZE];
long reg[10]= {0,0,0,0,0,0,0,0,0,0};
long sign[10]= {0,0,0,0,0,0,0,0,0,0};

FILE*infile;
int termmode= 0;
int halt;
int running;

struct breakpoint{
int addr;
int flags;
unsigned count;
unsigned ignore;
unsigned delete_after;
int next;
};

struct breakpoint bpoint[MEMSIZE];
unsigned bpind[MEMSIZE];

int lastbreak;
int stepflag;
int interrupted;

typedef void(*PFV)(void);
typedef int BOOLEAN;

struct operation{
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

struct operation optable[64]= {
{nop,1,F},
{add,2,F},
{sub,2,F},
{mul,10,F},
{mix_div,12,F},
{spec,1,F},
{shift,2,F},
{move,1,F},
{load,2,F},
{load,2,T},
{load,2,T},
{load,2,T},
{load,2,T},
{load,2,T},
{load,2,T},
{load,2,F},
{loadn,2,T},
{loadn,2,F},
{loadn,2,F},
{loadn,2,F},
{loadn,2,F},
{loadn,2,F},
{loadn,2,F},
{loadn,2,T},
{store,2,F},
{store,2,F},
{store,2,F},
{store,2,F},
{store,2,F},
{store,2,F},
{store,2,F},
{store,2,F},
{store,2,F},
{store,2,F},
{jbus,1,F},
{ioc,1,F},
{in,1,F},
{out,1,F},
{jred,1,F},
{jump,1,F},
{regjump,1,F},
{regjump,1,F},
{regjump,1,F},
{regjump,1,F},
{regjump,1,F},
{regjump,1,F},
{regjump,1,F},
{regjump,1,F},
{addrop,1,F},
{addrop,1,T},
{addrop,1,T},
{addrop,1,T},
{addrop,1,T},
{addrop,1,T},
{addrop,1,T},
{addrop,1,F},
{compare,2,T},
{compare,2,T},
{compare,2,T},
{compare,2,T},
{compare,2,T},
{compare,2,T},
{compare,2,T},
{compare,2,T}
};

/*:10*//*11:*/
#line 258 "./mixsim.w"

void tape(void),disk(void),reader(void),punch(void),printer(void),tty(void);
const char*mix_opname(int c,int f);

#ifndef PATH_MAX
# define PATH_MAX 256
#endif
struct io_device{
PFV device;
int io_time;
int position;
int seek_pos;
int tape_end;
int seek_time;
int address;
int io_op;
mix_clock_t clock;
int complete;
int fd;
FILE*fp;
char path[PATH_MAX];
};

struct io_device*unitp,unit[MAXUNITS]= {
{tape,50,0,0,0,50,0,0,0,1,0,NULL,"tape0"},
{tape,50,0,0,0,50,0,0,0,1,0,NULL,"tape1"},
{tape,50,0,0,0,50,0,0,0,1,0,NULL,"tape2"},
{tape,50,0,0,0,50,0,0,0,1,0,NULL,"tape3"},
{tape,50,0,0,0,50,0,0,0,1,0,NULL,"tape4"},
{tape,50,0,0,0,50,0,0,0,1,0,NULL,"tape5"},
{tape,50,0,0,0,50,0,0,0,1,0,NULL,"tape6"},
{tape,50,0,0,0,50,0,0,0,1,0,NULL,"tape7"},
{disk,250,0,0,0,1,0,0,0,1,0,NULL,"disk0"},
{disk,250,0,0,0,1,0,0,0,1,0,NULL,"disk1"},
{disk,250,0,0,0,1,0,0,0,1,0,NULL,"disk2"},
{disk,250,0,0,0,1,0,0,0,1,0,NULL,"disk3"},
{disk,250,0,0,0,1,0,0,0,1,0,NULL,"disk4"},
{disk,250,0,0,0,1,0,0,0,1,0,NULL,"disk5"},
{disk,250,0,0,0,1,0,0,0,1,0,NULL,"disk6"},
{disk,250,0,0,0,1,0,0,0,1,0,NULL,"disk7"},
{reader,10000,0,0,0,0,0,0,0,1,0,NULL,"stdin"},
{punch,20000,0,0,0,0,0,0,0,1,0,NULL,"stderr"},
{printer,7500,0,0,0,10000,0,0,0,1,0,NULL,"stdout"},
{tty,0,0,0,0,0,0,0,0,1,0,NULL,"stdin"},
};


/*:11*//*12:*/
#line 306 "./mixsim.w"

int loc;
int mem;
int op;
int fld;
long inst;
int compi= EQUAL;
int ovtog= OFF;
mix_clock_t uclock;
int instime= 0;
long rA,rX;
int rI1,rI2;
void inc(),dec(),sizechk(),ovcheck(),jmp(),jsj(),jumps(),
addrerror(),indexerror(),operror(),memerror(),fielderror(),
sizeerror(),dump();

/*:12*//*63:*/
#line 1305 "./mixsim.w"

int wpn= 5;

/*:63*/
#line 35 "./mixsim.w"

/*44:*/
#line 946 "./mixsim.w"

void
do_io()
{
if(!unitp->complete){
(*unitp->device)();
unitp->complete= T;
unitp->clock= uclock+unitp->io_time/2;
}else
unitp->clock= 0;
}

/*:44*//*45:*/
#line 959 "./mixsim.w"

void
do_outstanding_io(int time)
{
int i,next,save_fld;

save_fld= fld;
next= 0;
while(next!=time){
next= time;
for(i= 0;i<MAXUNITS;i++)
if(unit[i].clock> 0&&unit[i].clock<next){
next= unit[i].clock;
fld= i;
}
if(next!=time){
unitp= &unit[fld];
uclock= unitp->clock;
do_io();
}
}
fld= save_fld;
unitp= &unit[fld];
}

/*:45*//*46:*/
#line 985 "./mixsim.w"

int
open_stream_unit(struct io_device*unitp,char*mode)
{
if(!unitp->fp){
if(strcmp(unitp->path,"stdin")==0)
unitp->fp= stdin;
else if(strcmp(unitp->path,"stdout")==0)
unitp->fp= stdout;
else if(strcmp(unitp->path,"stderr")==0)
unitp->fp= stderr;
else{
if(!(unitp->fp= fopen(unitp->path,mode))){
error(0,errno,"open failed for %s",unitp->path);
}
}
}
return unitp->fp==NULL;
}

/*:46*//*47:*/
#line 1006 "./mixsim.w"

void
close_stream_unit(struct io_device*unitp)
{
if(unitp->fp&&
!(unitp->fp==stdin||unitp->fp==stdout||
unitp->fp==stderr)){
fclose(unitp->fp);
unitp->fp= NULL;
}
}

/*:47*//*48:*/
#line 1019 "./mixsim.w"

void
stream_reader(int blocksize,char*buffer,int bufsize)
{
int i,j,l;
char*p;

fgets(buffer,bufsize,unitp->fp);
l= strlen(buffer);
for(i= 0;i<blocksize;i++){
cell[unitp->address]= 0;
for(j= 0;j<BYTESPERWORD;j++)
if(i*BYTESPERWORD+j<l
&&(p= strchr(mixalf,buffer[i*BYTESPERWORD+j])))
cell[unitp->address]|= 
(p-mixalf)<<(BYTESIZE*(BYTESPERWORD-(j+1)));
unitp->address++;
}
}

/*:48*//*49:*/
#line 1040 "./mixsim.w"

void
reader()
{
char buffer[16*BYTESPERWORD+2];

switch(unitp->io_op){
case IOC:
close_stream_unit(unitp);
break;
case IN:
if(open_stream_unit(unitp,"r"))
return;
stream_reader(16,buffer,sizeof(buffer));
break;
case OUT:
break;
}
}

/*:49*//*50:*/
#line 1061 "./mixsim.w"

void
tty()
{
char buffer[14*BYTESPERWORD+2];

switch(unitp->io_op){
case IOC:
close_stream_unit(unitp);
break;
case IN:
if(open_stream_unit(unitp,"r"))
return;
stream_reader(14,buffer,sizeof(buffer));
break;
case OUT:
break;
}
}

/*:50*//*51:*/
#line 1082 "./mixsim.w"

void
printer()
{
int i,j;

if(open_stream_unit(unitp,"a"))
return;
switch(unitp->io_op){
case IOC:
fprintf(unitp->fp,"\f");
break;
case OUT:
for(i= 0;i<24;i++)
for(j= BYTESPERWORD-1;j>=0;j--)
putc(mixalf[
(cell[unit[PRINTER].address+i]&ONEBYTE<<
BYTESIZE*j)>>BYTESIZE*j],
unitp->fp);
putc('\n',unitp->fp);
break;
}
}

/*:51*//*52:*/
#line 1107 "./mixsim.w"

void
punch()
{
int i,j;

open_stream_unit(unitp,"a");
for(i= 0;i<15;i++)
for(j= BYTESPERWORD-1;j>=0;j--)
putc(mixalf[
(cell[unit[PUNCH].address+i]&ONEBYTE<<BYTESIZE*j)
>>BYTESIZE*j],unitp->fp);
putc('\n',unitp->fp);
}
/*:52*//*53:*/
#line 1122 "./mixsim.w"

void
tape()
{
if(!unitp->fd){
unitp->position= unitp->tape_end= 0;
if(unitp->io_op==OUT){
if((unitp->fd= open(unitp->path,
O_RDWR|O_CREAT|O_TRUNC,0777))<0)
error(0,errno,"write open failed for %s",unitp->path);
}else{
if(!unitp->fd&&(unitp->fd= open(unitp->path,O_RDWR))<0)
error(0,errno,"read open failed for %s",unitp->path);
}
}

switch(unitp->io_op){
case OUT:
if(write(unitp->fd,&cell[unitp->address],400)<0)
error(0,errno,"write failed for %s",unitp->path);
unitp->position++;
unitp->tape_end= unitp->position;
break;
case IN:
if(read(unitp->fd,&cell[unitp->address],400)<=0)
error(0,errno,"read failed for %s",unitp->path);
unitp->position++;
break;
case IOC:
if(unitp->address==0){
close(unitp->fd);
unitp->fd= 0;
unitp->position= 0;
}else{
if(unitp->position+unitp->address<0){
close(unitp->fd);
unitp->position= 0;
}else{
if(lseek(unitp->fd,unitp->address*400,SEEK_CUR)<0)
error(0,errno,"IOC %d on tape %d failed",
unitp->address,fld);
unitp->position+= unitp->address;
}
}
}
}
/*:53*//*54:*/
#line 1173 "./mixsim.w"

void
disk()
{
if(!unitp->fd){
if((unitp->fd= open(unitp->path,O_RDWR|O_CREAT,0777))<0)
error(0,errno,"open failed for %s",unitp->path);
}
switch(unitp->io_op){
case IOC:
unitp->position= unitp->seek_pos;
break;
case OUT:
if(lseek(unitp->fd,unitp->seek_pos*400,SEEK_SET)<0)
error(0,errno,"seek failed for %s",unitp->path);
else
unitp->position= unitp->seek_pos;
if(write(unitp->fd,&cell[unitp->address],400)<0)
error(0,errno,"write failed for %s",unitp->path);
else
unitp->position++;
break;
case IN:
if(lseek(unitp->fd,unitp->seek_pos*400,SEEK_SET)<0)
error(0,errno,"seek failed for %s",unitp->path);
else
unitp->position= unitp->seek_pos;
if(read(unitp->fd,&cell[unitp->address],400)<=0)
error(0,errno,"read failed for %s",unitp->path);
else
unitp->position++;
break;
}
}


/*:54*/
#line 36 "./mixsim.w"

/*13:*/
#line 324 "./mixsim.w"

void
memory()
{
if(mem<0||mem>=MEMSIZE)
memerror();
rA= MAG(cell[mem]);
rX= SIGN(cell[mem]);
}
/*:13*//*14:*/
#line 336 "./mixsim.w"

void
fcheck()
{
rI1= rA= fld/8;
rI2= rX= fld%8;
if(rA> rX||rX> 5)
fielderror();
}
/*:14*//*15:*/
#line 346 "./mixsim.w"

void
sizechk()
{
if(optable[op].iflag){
if(abs(rA)> TWOBYTES)
sizeerror();
}else
ovcheck();
}

/*:15*//*16:*/
#line 358 "./mixsim.w"

void
ovcheck()
{
if(rA&(FIVEBYTES+1))
ovtog= ON;
rA&= FIVEBYTES;
}
/*:16*//*17:*/
#line 369 "./mixsim.w"

void
getav()
{
if(rI1){
rX= PLUS;
rA<<= (BYTESIZE*(rI1-1));
rA&= FIVEBYTES;
rA>>= (BYTESIZE*(rI1-1));
}
rA>>= (BYTESIZE*(BYTESPERWORD-rI2));
}
/*:17*//*18:*/
#line 383 "./mixsim.w"

void
getv()
{
fcheck();
memory();
getav();
}

/*:18*//*25:*/
#line 476 "./mixsim.w"

void
load()
{
getv();
rI1= op-LDA;
reg[rI1]= rA&FIVEBYTES;
sign[rI1]= rX;
sizechk();
}

/*:25*//*26:*/
#line 488 "./mixsim.w"

void
store()
{
long work;

fcheck();
memory();
if(!rI1){
rI1= 1;
rX= sign[op-STA];
}
rA<<= (BYTESIZE*rI2);
rA&= FIVEBYTES;
rA>>= (BYTESIZE*rI2);
work= rA;
rA= cell[mem];
rA&= FIVEBYTES;
rA>>= (BYTESIZE*(BYTESPERWORD-(rI1-1)));
rA<<= (BYTESIZE*(BYTESPERWORD-(rI1-1)));
work|= rA;
rA= reg[op-STA];
rA<<= (BYTESIZE*(BYTESPERWORD-rI2+(rI1-1)));
rA&= FIVEBYTES;
rA>>= (BYTESIZE*(rI1-1));
work|= rA;
work|= rX;
cell[mem]= work;
}
/*:26*//*27:*/
#line 518 "./mixsim.w"

void
jump()
{
if(fld> 9)
fielderror();
rA= compi;
jumps(fld);
}

/*:27*//*28:*/
#line 529 "./mixsim.w"

void
jumps(int fld)
{
switch(fld){
case 0:
jmp();
break;
case 1:
jsj();
break;
case 2:
rX= ovtog;
ovtog= OFF;
if(rX)
jmp();
break;
case 3:
rX= ovtog;
ovtog= OFF;
if(!rX)
jmp();
break;
case 4:
if(rA<0)
jmp();
break;
case 5:
if(rA==0)
jmp();
break;
case 6:
if(rA> 0)
jmp();
break;
case 7:
if(rA>=0)
jmp();
break;
case 8:
if(rA!=0)
jmp();
break;
case 9:
if(rA<=0)
jmp();
break;
}
}

/*:28*//*31:*/
#line 597 "./mixsim.w"

void
regjump()
{
rA= reg[op-JA];
rA= sign[op-JA]?-rA:rA;
if(fld> 5)
fielderror();
jumps(fld+4);
}

/*:31*//*32:*/
#line 609 "./mixsim.w"

void
addrop()
{
if(fld> 3)
fielderror();


if(!mem)
rX= SIGN(inst);
else
rX= mem<0?MINUS:PLUS;
rA= mem> 0?mem:-mem;
rI1= op-INCA;
switch(fld){
case 0:
inc();
break;
case 1:
dec();
break;
case 2:
reg[rI1]= rA&FIVEBYTES;
sign[rI1]= rX;
sizechk();
break;
case 3:
reg[rI1]= rA&FIVEBYTES;
sign[rI1]= rX?PLUS:MINUS;
sizechk();
break;
}
}

/*:32*//*35:*/
#line 671 "./mixsim.w"

void
compare()
{
long v;

getv();
v= rX?-rA:rA;
rA= reg[op-CMPA];
rX= sign[op-CMPA];
getav();
rX= rX?-rA:rA;
if(rX==v)
compi= EQUAL;
else
compi= rX> v?GREATER:LESS;
}

/*:35*//*36:*/
#line 690 "./mixsim.w"

void
shift()
{
unsigned long long work,work1;
if(mem<0)
addrerror();
if(fld> 5)
fielderror();
rA= areg;
work= areg;
work<<= WORDSIZE;
work|= xreg;

switch(fld){
case 0:
if(mem> BYTESPERWORD)
mem= BYTESPERWORD;
rA<<= mem*BYTESIZE;
areg= rA&FIVEBYTES;
break;
case 1:
if(mem> BYTESPERWORD)
mem= BYTESPERWORD;
rA>>= mem*BYTESIZE;
areg= rA;
break;
case 2:
if(mem> (2*BYTESPERWORD))
mem= (2*BYTESPERWORD);
work<<= mem*BYTESIZE;
rX= work&FIVEBYTES;
work>>= WORDSIZE;
rA= work&FIVEBYTES;
areg= rA;
xreg= rX;
break;
case 3:
if(mem> (2*BYTESPERWORD))
mem= (2*BYTESPERWORD);
work>>= mem*BYTESIZE;
rX= work&FIVEBYTES;
work>>= WORDSIZE;
rA= work&FIVEBYTES;
areg= rA;
xreg= rX;
break;
case 4:
mem%= (2*BYTESPERWORD);
work1= work;
work<<= mem*BYTESIZE;
work1>>= (((2*BYTESPERWORD)-mem)*BYTESIZE);
work|= work1;
rX= work&FIVEBYTES;
work>>= WORDSIZE;
rA= work&FIVEBYTES;
areg= rA;
xreg= rX;
break;
case 5:
mem%= (2*BYTESPERWORD);
work1= work;
work>>= mem*BYTESIZE;
work1<<= (((2*BYTESPERWORD)-mem)*BYTESIZE);
work|= work1;
rX= work&FIVEBYTES;
work>>= WORDSIZE;
rA= work&FIVEBYTES;
areg= rA;
xreg= rX;
break;
}
}
/*:36*//*37:*/
#line 764 "./mixsim.w"

void
move()
{
while(fld){
memory();
rX|= rA;
rI1= i1reg;
rA= sign1;
if(rA){
if(rI1)
memerror();
sign1= 0;
}
if(rI1> MEMSIZE)
memerror();
cell[rI1]= rX;
uclock+= 2;
rI1++;
i1reg= rI1;
mem++;
fld--;
}
}

/*:37*//*42:*/
#line 872 "./mixsim.w"

void
spec()
{
long long n,m;
char work[11];
int i;
int table[10]= {30,31,32,33,34,35,36,37,38,39};

if(fld> 2)
fielderror();
switch(fld){
case 0:
n= 0;
m= 1;
for(i= 0;i<BYTESPERWORD;i++){
n+= (xreg>>BYTESIZE*i)%64%10*m;
m*= 10;
}
for(i= 0;i<BYTESPERWORD;i++){
n+= (areg>>BYTESIZE*i)%64%10*m;
m*= 10;
}
areg= n&FIVEBYTES;
if(areg!=n)
ovtog= ON;
uclock+= 9;
break;
case 1:
sprintf(work,"%010ld",areg);
areg= xreg= 0;
for(i= 0;i<BYTESPERWORD;i++){
areg|= table[work[i]-'0']<<((BYTESPERWORD-(i+1))*BYTESIZE);
xreg|= table[work[i+BYTESPERWORD]-'0']<<((BYTESPERWORD-(i+1))*BYTESIZE);
}
uclock+= 9;
break;
case 2:
do_outstanding_io(FIVEBYTES);
dump();
if(termmode)
halt= 1;
else
exit(-1);
}
}

/*:42*//*55:*/
#line 1210 "./mixsim.w"

void
indexerror()
{
error(0,0,"invalid index register: %d",rI2);
dump();
}
/*:55*//*56:*/
#line 1218 "./mixsim.w"

void
addrerror()
{
error(0,0,"invalid address: %d",mem);
dump();
}
/*:56*//*57:*/
#line 1226 "./mixsim.w"

void
operror()
{
error(0,0,"invalid opcode: %d",op);
dump();
}
/*:57*//*58:*/
#line 1234 "./mixsim.w"

void
memerror()
{
error(0,0,"invalid memory location: %d",mem);
dump();
}
/*:58*//*59:*/
#line 1242 "./mixsim.w"

void
fielderror()
{
error(0,0,"invalid field: %d",fld);
dump();
}
/*:59*//*60:*/
#line 1250 "./mixsim.w"

void
sizeerror()
{
error(0,0,"invalid size: %ld",rA);
dump();
}

/*:60*//*68:*/
#line 1432 "./mixsim.w"

RETSIGTYPE
sig_int(int sig)
{
if(termmode){
interrupted= 1;
signal(sig,sig_int);
}else
dump();
}

/*:68*//*69:*/
#line 1444 "./mixsim.w"

void
init()
{
memset(cell,0,sizeof(cell));
memset(reg,0,sizeof(reg));
memset(sign,0,sizeof(sign));
compi= EQUAL;
ovtog= OFF;
uclock= 0;
instime= 0;
rA= rX= rI1= rI2;
}

/*:69*//*70:*/
#line 1459 "./mixsim.w"

void
done()
{
fclose(infile);
infile= 0;
}

/*:70*//*93:*/
#line 1974 "./mixsim.w"

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
printf("\n");
printf("Report bugs to <%s>\n",PACKAGE_BUGREPORT);
}

/*:93*//*94:*/
#line 1994 "./mixsim.w"


struct option options[]= {
{"assign-device",required_argument,NULL,'a'},
{"terminal",no_argument,NULL,'t'},
{"help",no_argument,NULL,'h'},
{"version",no_argument,NULL,'V'},
{NULL}
};

/*:94*/
#line 37 "./mixsim.w"

/*62:*/
#line 1262 "./mixsim.w"

void
dump_status()
{
char t[4],c[8];
if(ovtog)
strcpy(t,"ON");
else
strcpy(t,"OFF");
if(!compi)
strcpy(c,"EQUAL");
else if(compi> 0)
strcpy(c,"GREATER");
else
strcpy(c,"LESS");
fprintf(stderr,"Registers A/X    %c0%010lo %c0%010lo\n",
sch(0),reg[0],sch(7),reg[7]);
fprintf(stderr,"                 %c %10ld %c %10ld\n\n",
sch(0),reg[0],sch(7),reg[7]);
fprintf(stderr,
"Index Registers  %c0%04lo  %c0%04lo  %c0%04lo  %c0%04lo  %c0%04lo  %c0%04lo \n",
sch(1),reg[1],sch(2),reg[2],
sch(3),reg[3],sch(4),reg[4],
sch(5),reg[5],sch(6),reg[6]);
fprintf(stderr,
"                 %c %4ld  %c %4ld  %c %4ld  %c %4ld  %c %4ld  %c %4ld \n\n",
sch(1),reg[1],sch(2),reg[2],
sch(3),reg[3],sch(4),reg[4],
sch(5),reg[5],sch(6),reg[6]);
fprintf(stderr,
"Jump Register    %c0%04lo     Overflow toggle:      %s\n",
sch(8),reg[8],t);
fprintf(stderr,
"                 %c %4ld     Comparison Indicator: %s\n\n",
sch(8),reg[8],c);
fprintf(stderr,
"Clock = %"PRI_MIX_CLOCK" u. "
"Location = %04d, M %d, I %ld, F %d, C %d, inst = %c %010lo \n\n",
uclock,loc,mem,INDEX(inst),fld,op,SIGN(inst)?'-':'+',
MAG(inst));
}

/*:62*//*64:*/
#line 1310 "./mixsim.w"

void
dump_memory(int from,int to)
{
char buff[2][132*2];
char cbuff[132*2];
char albuff[132*2];
char tbuff[64];
int a,i,j,k,flag;
char*p;
int b;

from= (from/wpn)*wpn;
to= ((to+wpn-1)/wpn)*wpn;
if(to> MEMSIZE)
to= MEMSIZE;

k= 0;
flag= 0;
a= 0;
for(i= from;i<to;i+= wpn){
k= (k+1)%2;
sprintf(buff[k],"%04d ",i);
for(j= 0;j<wpn;j++){
sprintf(buff[k]+5+j*15,
"%c%013ld ",
SIGN(cell[i+j])?'-':'+',
MAG(cell[i+j]));
}
if(strcmp(buff[0]+5,buff[1]+5)){
if(flag){
if(a-i+wpn)
fprintf(stderr,
"    Lines %04d to %04d are the same.\n",a,
i-wpn);
}
flag= 0;

for(j= 0;j<wpn;j++){
sprintf(cbuff+j*15,
"%c%04ld %02ld %02ld %02ld ",
SIGN(cell[i+j])?'-':'+',ADDRESS(cell[i+j]),
INDEX(cell[i+j]),FIELD(cell[i+j]),
CODE(cell[i+j]));

p= tbuff;
*p++= '\'';
for(b= BYTESPERWORD-1;b>=0;b--)
*p++= mixalf[(cell[i+j]&ONEBYTE<<BYTESIZE*b)
>>BYTESIZE*b];
*p++= '\'';
*p= 0;

sprintf(albuff+j*15,
"%-15.15s",tbuff);
}
fprintf(stderr,"%s\n",buff[k]);
fprintf(stderr,"%5.5s%s\n","",cbuff);
fprintf(stderr,"%5.5s%s\n","",albuff);
}else{
if(!flag)
a= i;
flag= 1;
}
}
if(flag){
if(a-i+wpn)
fprintf(stderr,"    Lines %04d to %04d are the same.\n",a,
i-wpn);
}
}

/*:64*//*65:*/
#line 1384 "./mixsim.w"

void
dump()
{
dump_status();
dump_memory(0,MEMSIZE);
if(!termmode)
exit(-1);
}

/*:65*//*86:*/
#line 1801 "./mixsim.w"

void
show_io(int dev)
{
struct io_device*dp= &unit[dev];

printf("%4d  %5d  %5d  %4d %4d  %3s  %10"PRI_MIX_CLOCK" %s\n",
dev,
dp->io_time,
dp->seek_time,
dp->address,
dp->position,
dp->complete?"N/A":mix_opname(dp->io_op,0),
dp->clock,
dp->path);
}

/*:86*//*87:*/
#line 1820 "./mixsim.w"

void
list_io(int dev)
{
if(dev>=MAXUNITS){
printf("INVALID UNIT NUMBER\n");
return;
}
printf("UNIT    IOT    SKT  ADDR  POS   OP       CLOCK ASGN\n");
if(dev==-1){
for(dev= 0;dev<MAXUNITS;dev++)
show_io(dev);
}else
show_io(dev);
}

/*:87*/
#line 38 "./mixsim.w"

/*73:*/
#line 1535 "./mixsim.w"

void
set_next(unsigned count,int step_in)
{
int opcode;
int br_loc= loc+count-1;
int c,f,cc,a;
#define isproccall(c) \
 (CODE(cell[c]) == 39 && FIELD(cell[c]) == 0 && \
  CODE(cell[ADDRESS(cell[c])]) == 32)

opcode= CODE(cell[br_loc]);
c= CODE(cell[br_loc]);
f= FIELD(cell[br_loc]);
a= ADDRESS(cell[br_loc]);
cc= CODE(ADDRESS(cell[br_loc]));

if(!step_in&&isproccall(br_loc)){

br_loc++;
if(br_loc>=MEMSIZE){
printf("CAN'T SET BREAKPOINT\n");
return;
}
bpoint[0].flags= BP_SET|BP_ACTIVE;
bpoint[0].addr= br_loc;
bpoint[0].ignore= 0;
bpoint[0].delete_after= 1;
bpoint[0].next= bpind[br_loc];
bpind[br_loc]= 0;
}else
stepflag= count;
}

/*:73*//*74:*/
#line 1570 "./mixsim.w"

int
bp_allocate()
{
int i;
for(i= 1;i<sizeof(bpoint)/sizeof(bpoint[0]);i++)
if(!BP_IS_SET(i)){
memset(bpoint+i,0,sizeof(bpoint[0]));
bpoint[i].flags= BP_SET;
return i;
}
return 0;
}

/*:74*//*75:*/
#line 1586 "./mixsim.w"

void
bp_set(int addr,int count)
{
int i;

if(loc<0||loc>=MEMSIZE){
printf("LOCATION OUT OF ADDRESS SPACE\n");
return;
}
i= bp_allocate();
if(i==0){
printf("OUT OF BREAKPOINT SPACE\n");
return;
}
bpoint[i].addr= addr;
bpoint[i].flags|= BP_ACTIVE;
bpoint[i].delete_after= count;
bpoint[i].next= bpind[addr];
bpind[addr]= i;
printf("BREAKPOINT %d IS SET AT ADDRESS %d\n",i,addr);
while(i= bpoint[i].next){
if(BP_IS_ACTIVE(i))
printf("WARNING: BREAKPOINT %d IS ALSO SET AT ADDRESS %d\n",
i,addr);
else
printf("WARNING: BREAKPOINT %d (DISABLED) IS ALSO SET AT ADDRESS %d\n",
i,addr);
}
}

/*:75*//*76:*/
#line 1618 "./mixsim.w"

static int
bp_verify(int n)
{
if(n<0||n>=MEMSIZE){
printf("NUMBER OUT OF BREAKPOINT SPACE\n");
return 1;
}
if(!BP_IS_SET(n)){
printf("BREAKPOINT %d IS NOT SET\n",n);
return 1;
}
return 0;
}

/*:76*//*77:*/
#line 1634 "./mixsim.w"

int
bp_first(int addr)
{
if(addr<0||addr>=MEMSIZE){
printf("LOCATION OUT OF ADDRESS SPACE\n");
return 0;
}
return bpind[addr];
}

/*:77*//*78:*/
#line 1647 "./mixsim.w"

int
bp_next(int cur)
{
if(cur<1||cur>=MEMSIZE+1){
printf("LOCATION OUT OF ADDRESS SPACE\n");
return 0;
}
return bpoint[cur].next;
}

/*:78*//*79:*/
#line 1660 "./mixsim.w"

void
bp_delete(int n)
{
int i;

if(n==-1){

memset(bpoint,0,sizeof bpoint);
memset(bpind,0,sizeof bpind);
return;
}

if(bp_verify(n))
return;

i= bpind[bpoint[n].addr];
if(i==n)
bpind[bpoint[n].addr]= bpoint[n].next;
else{
for(;i;i= bpoint[i].next){
if(bpoint[i].next==n){
bpoint[i].next= bpoint[n].next;
break;
}
}
}
bpoint[n].flags= 0;
}

/*:79*//*80:*/
#line 1692 "./mixsim.w"

void
bp_enable(int n,int status)
{
if(n==-1){
for(n= 0;n<sizeof(bpoint)/sizeof(bpoint[0]);n++)
if(BP_IS_SET(n))
bp_enable(n,status);
return;
}

if(bp_verify(n))
return;
if(status)
bpoint[n].flags|= BP_ACTIVE;
else
bpoint[n].flags&= ~BP_ACTIVE;
}

/*:80*//*81:*/
#line 1712 "./mixsim.w"

void
bp_set_ignore(int n,unsigned count)
{
if(bp_verify(n))
return;
bpoint[n].ignore= count;
}

/*:81*//*82:*/
#line 1722 "./mixsim.w"

void
bp_set_max_crossings(int n,unsigned count)
{
if(bp_verify(n))
return;
bpoint[n].delete_after= count;
}

/*:82*//*83:*/
#line 1734 "./mixsim.w"

void
print_breakpoint(int n)
{
if(n==-1)
printf("%4s %4s %4s %4s %4s %4s\n",
"NUM","LOC","ENB","CNT","IGN","PAS");
else
printf("%4d %4d %4s %4u %4u %4u\n",
n,bpoint[n].addr,
BP_IS_ACTIVE(n)?"Y":"N",
bpoint[n].count,bpoint[n].ignore,
bpoint[n].delete_after);
}

/*:83*//*84:*/
#line 1750 "./mixsim.w"

void
list_bp(int n,int isloc)
{
if(n==-1){
print_breakpoint(-1);
for(n= 1;n<sizeof(bpoint)/sizeof(bpoint[0]);n++){
if(BP_IS_SET(n))
print_breakpoint(n);
}
}else if(isloc){
n= bp_first(n);
if(n){
print_breakpoint(-1);
do
print_breakpoint(n);
while(n= bp_next(n));
}
}else if(bp_verify(n)==0){
print_breakpoint(-1);
print_breakpoint(n);
}
}

/*:84*//*85:*/
#line 1776 "./mixsim.w"

int
bp_hit(int addr)
{
int n;
int rc= 0;
for(n= bpind[addr];n;n= bpoint[n].next){
if(BP_IS_SET(n)){
bpoint[n].count++;
if(!BP_IS_ACTIVE(n))
continue;
if(bpoint[n].ignore){
--bpoint[n].ignore;
continue;
}
printf("BREAKPOINT %d\n",n);
rc= 1;
if(bpoint[n].delete_after&&--bpoint[n].delete_after==0)
bp_delete(n);
}
}
return rc;
}

/*:85*/
#line 39 "./mixsim.w"

/*90:*/
#line 1865 "./mixsim.w"

const char*
mix_opname(int c,int f)
{
int i;

if(c<=63){
if(dd_cnt[c]==1)
i= dd_ent[c];
else if(f<dd_cnt[c])
i= dd_ent[c]+f;
return mix_optab[i].name;
}
return"??";
}

/*:90*//*91:*/
#line 1882 "./mixsim.w"

char*
sprintop(char*buf,int loc)
{
int c,f,i,addr,ind;
char*p= buf;

c= CODE(cell[loc]);
f= FIELD(cell[loc]);
addr= ADDRESS(cell[loc]);
if(SIGN(cell[loc]))
addr= -addr;
i= INDEX(cell[loc]);
if(c<=63){
if(dd_cnt[c]==1)
ind= dd_ent[c];
else if(f<dd_cnt[c])
ind= dd_ent[c]+f;
else
goto badop;

p+= sprintf(p,"%s ",mix_optab[ind].name);
if(addr==loc)
p+= sprintf(p+14,"*");
else
p+= sprintf(p,"%d",addr);
if(i!=0)
p+= sprintf(p,",%d",i);
if(f!=mix_optab[ind].f){
if(mix_optab[ind].notation==0)
p+= sprintf(p,"(%d)",f);
else
p+= sprintf(p,"(%d:%d)",f/8,f%8);
}
}else{
badop:
sprintf(p,"%c%04ld %02ld %02ld %02ld",
SIGN(cell[loc])?'-':'+',ADDRESS(cell[loc]),
INDEX(cell[loc]),FIELD(cell[loc]),
CODE(cell[loc]));
}
return buf;
}

/*:91*//*92:*/
#line 1928 "./mixsim.w"

void
disas(FILE*fp,int loc,int stop_loc)
{
int c,f,i,addr,ind;

for(;loc<stop_loc;loc++){
c= CODE(cell[loc]);
f= FIELD(cell[loc]);
addr= ADDRESS(cell[loc]);
if(SIGN(cell[loc]))
addr= -addr;
i= INDEX(cell[loc]);
if(c<=63){
if(dd_cnt[c]==1)
ind= dd_ent[c];
else if(f<dd_cnt[c])
ind= dd_ent[c]+f;
else
goto badop;

fprintf(fp,"%-8d%-6.6s",loc,mix_optab[ind].name);
if(addr==loc&&mix_optab[ind].name[0]=='J')
fprintf(fp,"*");
else
fprintf(fp,"%d",addr);
if(i!=0)
fprintf(fp,",%d",i);
if(f!=mix_optab[ind].f){
if(mix_optab[ind].notation==0)
fprintf(fp,"(%d)",f);
else
fprintf(fp,"(%d:%d)",f/8,f%8);
}
fprintf(fp,"\n");
}else{
badop:
fprintf(fp,"%c%04ld %02ld %02ld %02ld",
SIGN(cell[loc])?'-':'+',ADDRESS(cell[loc]),
INDEX(cell[loc]),FIELD(cell[loc]),
CODE(cell[loc]));
}
}
}

/*:92*/
#line 40 "./mixsim.w"

/*66:*/
#line 1395 "./mixsim.w"

void
go()
{
unit[READER].address= 0;
unitp= &unit[READER];
unitp->io_op= IOC;
reader();
uclock+= unitp->io_time;
unitp->io_op= IN;
reader();
loc= 0;
lastbreak= -1;
run();
}

/*:66*//*67:*/
#line 1413 "./mixsim.w"

int
source_deck(char*name)
{
FILE*infile;

if(name){
infile= fopen(name,"r");
if(!infile){
error(0,errno,"can't load card deck %s",name);
return-1;
}
fclose(infile);
asgn_io(16,name);
}
return 0;
}

/*:67*//*71:*/
#line 1468 "./mixsim.w"

void
run()
{
running= 1;
halt= 0;
while(!halt&&loc<MEMSIZE){
if(bp_hit(loc)){
if(lastbreak==loc){
lastbreak= 0;
}else{
lastbreak= loc;
disas(stdout,loc,loc+1);
stepflag= 0;
return;
}
}else if(interrupted){
interrupted= 0;
printf("interrupted at %d\n",loc);
return;
}

uclock+= instime;
for(fld= 0;fld<MAXUNITS;fld++){
unitp= &unit[fld];
if(unitp->clock> 0&&unitp->clock<=uclock){

do_io();
}
}
inst= cell[loc];
loc++;
if(loc>=MEMSIZE)
addrerror();
mem= ADDRESS(inst);
if(SIGN(inst))
mem= -mem;
rI2= INDEX(inst);
if(rI2){
if(rI2> 6)
indexerror();
mem+= sign[rI2]?-reg[rI2]:reg[rI2];
if(abs(mem)> TWOBYTES)
addrerror();
}
fld= FIELD(inst);
op= CODE(inst);
if(op>=64)
operror(op);
instime= optable[op].time;
unitp= &unit[fld];
(*optable[op].fn)();

if(stepflag){
disas(stdout,loc,loc+1);
if(--stepflag==0)
return;
}

}
running= 0;
}

/*:71*//*88:*/
#line 1837 "./mixsim.w"

void
asgn_io(int dev,char*path)
{
struct io_device*dp;

if(dev<0||dev>=MAXUNITS){
printf("INVALID UNIT NUMBER\n");
return;
}
if(strlen(path)> PATH_MAX){
printf("PATHNAME TOO LONG\n");
return;
}
dp= &unit[dev];
if(dev<16){
if(dp->fd> 0){
close(dp->fd);
dp->fd= 0;
}
}else{
close_stream_unit(dp);
}
strcpy(dp->path,path);
}

/*:88*/
#line 41 "./mixsim.w"

/*19:*/
#line 394 "./mixsim.w"

void
nop()
{

if(fld==63)
uclock= 0;
}
/*:19*//*20:*/
#line 403 "./mixsim.w"

void
add()
{
getv();
rI1= 0;
inc();
}
/*:20*//*21:*/
#line 412 "./mixsim.w"

void
sub()
{
getv();
rI1= 0;
dec();
}
/*:21*//*22:*/
#line 421 "./mixsim.w"

void
mul()
{
long long work;

getv();
if(rX==signa)
rX= PLUS;
else
rX= MINUS;
signa= signx= rX;
work= rA*(long long int)areg;
xreg= work&FIVEBYTES;
work>>= WORDSIZE;
areg= work&FIVEBYTES;
}

/*:22*//*23:*/
#line 440 "./mixsim.w"

void
mix_div()
{
long long work;

signx= signa;
getv();
if(rX==signa)
rX= PLUS;
else
rX= MINUS;
signa= rX;
if(areg> rA)
ovtog= ON;
work= areg;
work<<= WORDSIZE;
work|= xreg;
areg= (work/rA)&FIVEBYTES;
xreg= work%rA;
}

/*:23*//*24:*/
#line 463 "./mixsim.w"

void
loadn()
{
getv();
rI1= op-LDAN;
rX= rX?PLUS:MINUS;
reg[rI1]= rA&FIVEBYTES;
sign[rI1]= rX;
sizechk();
}

/*:24*//*29:*/
#line 580 "./mixsim.w"

void
jmp()
{
jreg= loc;
jsj();
}
/*:29*//*30:*/
#line 588 "./mixsim.w"

void
jsj()
{
memory();
loc= mem;
}

/*:30*//*33:*/
#line 644 "./mixsim.w"

void
dec()
{
rX= rX?PLUS:MINUS;
inc();
}

/*:33*//*34:*/
#line 653 "./mixsim.w"

void
inc()
{
if(rX!=sign[rI1]){
rA-= reg[rI1];
if(rA> 0)
sign[rI1]= rX;
else
rA= -rA;
}
else
rA+= reg[rI1];
reg[rI1]= rA&FIVEBYTES;
sizechk();
}

/*:34*//*38:*/
#line 790 "./mixsim.w"

void
jbus()
{
if(unitp->clock> uclock){
if(loc-1==mem){
do_outstanding_io(unitp->clock);
uclock= unitp->clock;
}
jmp();
}
}

/*:38*//*39:*/
#line 804 "./mixsim.w"

void
ioc()
{
if(fld==PUNCH||fld==READER)
return;
if(unitp->clock> uclock){
do_outstanding_io(unitp->clock);
uclock= unitp->clock;
do_io();
}
if(unitp->clock> uclock){
do_outstanding_io(unitp->clock);
uclock= unitp->clock;
do_io();
}
unitp->io_op= op;
unitp->address= mem;
if(fld<=TAPE7){
if(mem)
unitp->clock= uclock+abs(mem)*unitp->seek_time;
else
unitp->clock= uclock+unitp->position*unitp->seek_time;
}
if(DISK8<=fld&&fld<=DISK15){
unitp->clock= uclock+abs(xreg-unitp->position)*unitp->seek_time;
unitp->seek_pos= xreg;
}
if(fld==PRINTER){
unitp->clock= uclock+unitp->seek_time;
}
}

/*:39*//*40:*/
#line 838 "./mixsim.w"

void
in()
{
if(unitp->clock> uclock){
do_outstanding_io(unitp->clock);
uclock= unitp->clock;
do_io();
}
if(unitp->clock> uclock){
do_outstanding_io(unitp->clock);
uclock= unitp->clock;
do_io();
}
unitp->io_op= op;
unitp->address= mem;
unitp->clock= uclock+unitp->io_time/2;
unitp->complete= F;
if(fld>=DISK8&&fld<=DISK15){
unitp->clock+= abs(xreg-unitp->position)*unitp->seek_time;
unitp->seek_pos= xreg;
}
}

/*:40*//*41:*/
#line 863 "./mixsim.w"

void
jred()
{
if(unitp->clock<=uclock)
jmp();
}

/*:41*//*43:*/
#line 920 "./mixsim.w"


void
out()
{
if(unitp->clock> uclock){
do_outstanding_io(unitp->clock);
uclock= unitp->clock;
do_io();
}
if(unitp->clock> uclock){
do_outstanding_io(unitp->clock);
uclock= unitp->clock;
do_io();
}
unitp->io_op= op;
unitp->address= mem;
unitp->clock= uclock+unitp->io_time/2;
unitp->complete= F;
if(fld>=DISK8&&fld<=DISK15){
unitp->clock+= abs(xreg-unitp->position)*unitp->seek_time;
unitp->seek_pos= xreg;
}
}

/*:43*/
#line 42 "./mixsim.w"

/*95:*/
#line 2005 "./mixsim.w"

int
main(int argc,char*argv[])
{
int i,n;
char*p;

set_program_name(argv[0]);
while((i= getopt_long(argc,argv,"a:htV",options,NULL))!=EOF){
switch(i){
case'a':
n= strtol(optarg,&p,10);
if(*p!='=')
error(1,0,"device assignment syntax error (near %s)",p);

if(n<0||n>=MAXUNITS)
error(1,0,"invalid unit number");

asgn_io(n,p+1);
break;

case't':
termmode++;
break;

case'V':
mix_version(program_name);
exit(0);

case'h':
usage();
exit(0);

default:
exit(1);
}
}

signal(SIGINT,sig_int);
if(argv[optind]&&source_deck(argv[optind]))
exit(1);
if(argc-optind> 1)
error(0,0,"excess arguments ignored");

if(termmode)
mixterm();
else
go();
return 0;
}
/*:95*/
#line 43 "./mixsim.w"


/*:2*/
