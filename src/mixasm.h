#define localref(name,c) (name[2]==0 \
&&name[0]>='0'&&name[0]<='9' \
&&strchr(c,name[1]) )  \

/*3:*/
#line 28 "./mixasm.hw"

typedef struct Symbol{
char*name;
int type;
int value;
int line;
struct ref*reflist;
struct ref*xref;

}Symbol;

/*:3*//*4:*/
#line 40 "./mixasm.hw"

typedef struct ref{
struct ref*next;
int address;
int line;
}ref;

/*:4*//*5:*/
#line 48 "./mixasm.hw"

Symbol*install(char*s,int v,int l),*lookup(char*s);
ref*addref(ref*p,int loc,int line);
Symbol**sort_symbols(void);
void sort_refs(Symbol*s);
struct mix_op*lookup_op(char*c);
void install_op(struct mix_op*op);
unsigned iterate(int(*fun)(Symbol*));

int yylex(void);
int yyerror(char*s);
void warning_l(int line,char*s,char*t);
void warning(char*s,char*t);
void parse_error_l(int line,char*s,char*t);
void parse_error(char*s,char*t);
void init_lex(FILE*fp,int debug);
void reset_lex(void);

void tlist(char*fmt,...);
/*:5*/
