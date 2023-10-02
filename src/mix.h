#define MEMSIZE 4000
#define BYTESIZE 6
#define BYTESPERWORD 5
#define B1 (1<<BYTESIZE) 
#define B2 B1*B1
#define B3 B2*B1
#define B5 B2*B3
#define MINUS ((unsigned) 2*B5) 
#define PLUS 0
#define SIGN(a) (a&(MINUS) ) 
#define MAG(a) (a&(B5-1) ) 
#define T 1
#define F 0 \

/*2:*/
#line 50 "./mix.hw"

struct mix_op{
char*name;
int f;
int c;
int notation;
};

/*:2*//*3:*/
#line 59 "./mix.hw"

extern struct mix_op mix_optab[];
extern int op_count;
extern int dd_cnt[];
extern int dd_ent[];
extern char mixalf[];/*:3*/
