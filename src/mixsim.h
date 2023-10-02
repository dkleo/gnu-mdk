/*1:*/
#line 2 "./mixsim.hw"

void go(void);
void run(void);
void asgn_io(int dev,char*path);
void mixterm(void);
void bp_set(int addr,int count);

void bp_delete(int n);
void bp_enable(int n,int status);
void bp_set_ignore(int n,unsigned count);
void bp_set_max_crossings(int n,unsigned count);
int bp_first(int addr);
int bp_next(int cur);

void list_bp(int n,int isloc);
void show_io(int dev);
void list_io(int dev);
void set_next(unsigned count,int step_in);
void dump(void);
void dump_memory(int from,int to);
void dump_status(void);
void disas(FILE*fp,int loc,int stop_loc);

typedef unsigned long mix_clock_t;
#define PRI_MIX_CLOCK "lu"/*:1*/
