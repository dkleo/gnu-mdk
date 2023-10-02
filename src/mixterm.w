% This file is part of MIX
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
%
@*A MIX TERMINAL.
This provides a terminal shell for the MIX simulator. The shell supports
following commands:


\tabskip=1em \halign{%
 \strut\sc#\hfil&\strut\sc#\hfil&\strut{\raggedright#}\cr
{\bf Synopsis}    & {\bf Minimal abbreviation}& {\bf Short description}\cr
ASGN {\it devnum} {\it unix-path} & A & Assign a file to \.{MIX} device.\cr 
BREAK {\it addr}  & B & Set breakpoint on address.\cr
BREAK TEMP {\it addr} & BT {\it or} TB & Set a temporary breakpoint.\cr
CLEAR {\it n} & C & Alias for {\sc DELETE}.\cr
CONT              & CO  & Continue after a breakpoint.\cr
DELETE {\it n} & D & Clear breakpoint {\it n}.\cr
DISASSEMBLE [{\it addr} [{\it addr}]] & & Alias for {\sc UNASM}.\cr
DUMP              & DU & Dump \.{MIX} machine state.\cr 
DUMP REGISTERS    & DR & Dump \.{MIX} registers.\cr
DUMP MEMORY [{\it addr} [{\it addr}]]  & DM & Dump memory contents.\cr
IGNORE {\it n} {\it count} & IG & Ignore next {\it count} crossings of
breakpoint {\it n}.\cr
INFO              & & Alias for {\sc LIST}.\cr
GO                & G & Run program.\cr
HELP [{\it command}] & ? & Print a short usage summary.\cr
LIST BREAK        & LB & List breakpoints.\cr
LIST IO [{\it devnum}]  & LI & List {\sc I/O} devices.\cr
PASSCOUNT {\it n} {\it count} & T & Clear breakpoint {\it n} after {\it count}
crossings.\cr
NEXT [{\it count}]  & N & Execute next {\it count} instructions (default is 1).\cr
RUN               & & Run program.\cr
SHELL [{\it command}] & ! & Execute a shell command.\cr
SOURCE {\it file} & SO & Read commands from {\it file}.\cr
STEP [{\it count}] & S & Execute next {\it count} instructions,
stepping into calls.\cr
UNASM [{\it addr} [{\it addr}]] & U & Disassemble.\cr
VERSION           & V & Show program version and short licensing information.\cr
QUIT              & Q & Quit the terminal.\cr}

Breakpoint manipulation commands (\.{DELETE}, \.{IGNORE}, \.{ENABLE},
\.{DISABLE}, and \.{PASSCOUNT}) address breakpoints by their sequence number,
unless prefixed with \.{ADDRESS}, in which case breakpoints are referred to
by the \.{MIX} address they are set to. For example:

Disable breakpoint number 2:

{\parindent = 5em\indent {\sc ENABLE} 2}

Disable all breakpoints on address 1000:

{\parindent = 5em\indent {\sc ADDRESS ENABLE} 1000}

@ Definitions
@s CPPFunction int
@s token c
@s line normal
@d T_EOL          '\n'
@d T_NUMBER       256
@d T_STRING       257
@d T_BREAK        258   
@d T_TEMP         259
@d T_BT           260
@d T_DELETE       261
@d T_ENABLE       262 
@d T_DISABLE      263
@d T_IGNORE	  264
@d T_PASSCOUNT    265
@d T_LIST         266 
@d T_LB           267
@d T_NEXT         268
@d T_STEP         269
@d T_ASGN         270
@d T_GO           271
@d T_DUMP         272
@d T_REGISTERS    273
@d T_DR           274
@d T_MEMORY       275
@d T_DM           276
@d T_IO           277
@d T_LI           278
@d T_QUIT         279
@d T_CONT         280
@d T_UNASM        281
@d T_ADDRESS      282
@d T_SHELL        283 
@d T_HELP         284
@d T_SOURCE       285
@d T_VERSION	  286

@d MAX_TOKENSIZE  256

@d skipws(p) for (; *(p) && isspace(*(p)); (p)++);
@d getword(p,l) for(; (p)[l] && !isspace((p)[l]); (l)++);
@ Header files to include
@c
#ifdef HAVE_CONFIG_H
# include <config.h>
#endif
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <pwd.h>
#include <dirent.h>
#include <ctype.h>
#include <string.h>
#include <errno.h>
#include <mix.h>
#include <mixsim.h>
#ifdef WITH_READLINE
# include <readline/readline.h>
# include <readline/history.h>
#endif
#include "xalloc.h"
#include "error.h"
#include "progname.h"
@ Forward declarations.
@c
#ifdef WITH_READLINE
static char *compl_address(const char *text, int state);
static char *compl_asgn(const char *text, int state);
static char *compl_break(const char *text, int state);
static char *compl_dump(const char *text, int state);
static char *compl_list(const char *text, int state);
static char *compl_help(const char *text, int state);
static char *compl_shell(const char *text, int state);
static char *compl_source(const char *text, int state);
#else
# define compl_address NULL
# define compl_asgn NULL
# define compl_break NULL
# define compl_dump NULL
# define compl_list NULL
# define compl_help NULL
# define compl_shell NULL
# define compl_source NULL
#endif

int source_file(char *file, int quiet);

@ 
@c
struct command_word {
     char *longname;
     char *shortname;
     int tok;
     int first;
     char * @[@] (*compl) (const char *str, int state);
} cword[] = {@/
     { "BREAK",        "B",    T_BREAK,     1, compl_break }, @/
     { "TEMP",        NULL,    T_TEMP,      0 }, @/
     { "BT",          NULL,    T_BT,        1 }, @/
     { "TB",          NULL,    T_BT,        1 }, @/
     { "CLEAR",       "CL",    T_DELETE,    1 }, @/
     { "CB",          NULL,    T_DELETE,    1 }, @/
     { "PASSCOUNT",    "P",    T_PASSCOUNT, 1 }, @/
     { "INFO",        NULL,    T_LIST,      1, compl_list }, @/
     { "LIST",        NULL,    T_LIST,      1, compl_list }, @/
     { "LB",          NULL,    T_LB,        1 }, @/
     { "ADDRESS",     "AD",    T_ADDRESS,   1, compl_address  }, @/
     { "DELETE",       "D",    T_DELETE,    1 }, @/
     { "DISABLE",    "DIS",    T_DISABLE,   1 }, @/
     { "ENABLE",     "ENA",    T_ENABLE,    1 }, @/
     { "IGNORE",       "I",    T_IGNORE,    1 }, @/
     { "NEXT",         "N",    T_NEXT,      1 }, @/
     { "STEP",         "S",    T_STEP,      1 }, @/
     { "ASGN",         "A",    T_ASGN,      1, compl_asgn }, @/
     { "GO",           "G",    T_GO,        1 }, @/
     { "RUN",         NULL,    T_GO,        1 }, @/ 
     { "DUMP",        "DU",    T_DUMP,      1, compl_dump }, @/
     { "REGISTERS",  "REG",    T_REGISTERS, 0 }, @/
     { "DR",          NULL,    T_DR,        1 }, @/
     { "MEMORY",     "MEM",    T_MEMORY,    0 }, @/
     { "DM",          NULL,    T_DM,        1 }, @/
     { "IO",          NULL,    T_IO,        0 }, @/
     { "LIO",         NULL,    T_LI,        1 }, @/
     { "CONTINUE",     "C",    T_CONT,      1 }, @/
     { "UNASM",        "U",    T_UNASM,     1 }, @/
     { "DISASSEMBLE", NULL,    T_UNASM,     1 }, @/
     { "HELP",         "?",    T_HELP,      1, compl_help }, @/
     { "QUIT",         "Q",    T_QUIT,      1 }, @/
     { "SHELL",        "!",    T_SHELL,     1, compl_shell }, @/
     { "SOURCE",      "SO",    T_SOURCE,    1, compl_source }, @/
     { "VERSION",      "V",    T_VERSION,   1 }, @/  	     
     { 0 } @/
};

@ Find a |command_word| corresponding to command |str|, |len| bytes long.
Notice, thar |str| is not necessarily nul-terminated.

@c
struct command_word *
find_command_word (const char *str, int len)
{
     struct command_word *cp;
	  
     for (cp = cword; cp->longname; cp++) {
	  int ll = strlen (cp->longname);

	  if (cp->shortname) {
	       int sl = strlen (cp->shortname);
	       if (sl == len
		   && strncasecmp (cp->shortname, str, len) == 0)
		    return cp;
	       if (sl >= len)
		    continue;
	  }
	  if (ll >= len
	      && strncasecmp (cp->longname, str, len) == 0)
	       return cp;
     }
     return NULL;
}

@ Find a token number, corresponding to the command |str|.
@c
int
find_keyword (const char *str)
{
     struct command_word *cw = find_command_word (str, strlen(str));
     return cw ? cw->tok : 0;
}

@ Token structure.
@c
struct token {
     int type;                   /* Token type */
     int number;                 /* Numeric value if appropriate */
     char string[MAX_TOKENSIZE]; /* String value if appropriate */
};

@ Input structure.
@c
struct term_input {
     char *(*reader)(struct term_input *); /* Reader function */
     void *arg;                  /* Reader argument */
     char *input_file;           /* Input file name */
     unsigned input_line;        /* Input line number */
     int interactive;            /* T if current session is interactive,
                                    F otherwise */
     char *buffer;               /* Token buffer */ 
     char *curp;                 /* Current position in the buffer */
     struct token token;
};

@ Global variables.
@c 
char prompt[] = "MIX> ";         /* Default terminal prompt */

@*1 Readline support.
Wherever {\mc GNU} {\tt readline} is available it is used to facilitate
interaction with the terminal. The readline mode will be automatically
disabled if |interactive| is {\mc F}.

The readline specific functions are protected by |WITH_READLINE| preprocessor
variable.

@c
#ifdef WITH_READLINE

@ Readline command generator. Each invocation must return next possible
expansion of |text| or {\mc NULL} if no more expansions are available.
|state| is 0 if the function is called for the first time for given |text|.
@c
char *
mixterm_command_generator(const char *text, int state)
{
     static int i, len;
     const char *name;

     if (!state) {
	  i = 0;
	  len = strlen(text);
     }
     
     while ((name = cword[i].longname)) {
          if (!cword[i].first) {
               i++;
               continue;
          }
	  if (cword[i].shortname && strlen (cword[i].shortname) > strlen(name))
	       name = cword[i].shortname;
	  i++;
	  if (strncasecmp (name, text, len) == 0)
	       return strdup(name);
     }

     return NULL;
}

@ Save positions in the readline buffer for completer functions that may need
it.

@c
static int completion_start;
static int completion_end;

@ Prepare a NULL terminated array of possible command completions.
@c
char **
mixterm_command_completion(char *cmd, int start, int end)
{
     char **ret = NULL;
     rl_filename_completion_desired = 0;
     rl_attempted_completion_over = 1;

     if (strchr("?!", rl_line_buffer[0])
	 && rl_line_buffer[1] && !isspace(rl_line_buffer[1])) {
	  int len = strlen(rl_line_buffer);
	  rl_extend_line_buffer(len + 1);
	  memmove(rl_line_buffer+2, rl_line_buffer+1, len);
	  rl_line_buffer[1] = ' ';
	  rl_end++;
	  rl_point++;
     }
     if (start == 0) {
	  ret = rl_completion_matches (cmd, mixterm_command_generator);
     } else {
	  char *kw;
	  int len = 0;
	  struct command_word *cwp;

	  rl_completion_append_character = ' ';

	  kw = rl_line_buffer;
	  if (strchr("?!", *kw))
	       len = 1;
	  else {
	       for (;kw < rl_line_buffer + start && isspace(*kw); kw++);
	       getword(kw, len);
	  }
	  cwp = find_command_word(kw, len);
	  if (cwp && cwp->compl) {
	       completion_start = start;
	       completion_end = end;
	       ret = rl_completion_matches (cmd, cwp->compl);
	  } 
     }
     return ret;
}

@ Get next available character from the |stream|.
@c
static int
mixterm_getc(FILE *stream)
{
     unsigned char c;

     while (1) {
	  if (read(0, &c, 1) == 1)
	       return c;
	  if (errno == EINTR) {
	       rl_kill_full_line(0,0);
	       rl_newline(1, '\n');
	       rl_on_new_line();
	       rl_redisplay();
	       continue;
	  } else
	       break;
     }
     return EOF;
}

@
@c
static char *
history_file_name()
{
#define SUF_HISTORY "_history"
     static char *filename;

     if (!filename) {
	  size_t len;
	  char *home = getenv("HOME");
	  if (!home) {
	       struct passwd *pw = getpwuid (getuid ());
	       if (!pw)
		    return NULL;
	       home = pw->pw_dir;
	  }
	  len = strlen(home) + 2 + strlen(rl_readline_name)
	        + sizeof SUF_HISTORY;
	  filename = malloc(len);
	  if (filename) {
	       strcpy(filename, home);
	       strcat(filename, "/.");
	       strcat(filename, rl_readline_name);
	       strcat(filename, SUF_HISTORY);
	  }
     }
     return filename;
}

@ Initialize internal readline variables.
@c
void
mixterm_readline_init()
{
     rl_readline_name = "mixsim";
     rl_attempted_completion_function =
                         (CPPFunction*) mixterm_command_completion;
     rl_getc_function = mixterm_getc;
     read_history(history_file_name());
}

@ Return |1| if |t| is present in |0|-terminated array |tab|, and
|0| otherwise.

@c
int
member(int t, int *tab)
{
     for (; *tab; tab++)
	  if (*tab == t)
	       return 1;
     return 0;
}

@
@c
static int
match_prefix(struct command_word *cwp, const char *word, int len)
{
     return len == 0 ||
	     (strlen(cwp->longname) >= len
	      && strncasecmp(cwp->longname, word, len) == 0);
}

@ Return 1, if the token number of |cwp| is contained in |tab| and its
|longname| begins with prefix |len|-byte prefix |word|.

@c
static int
tokmatch(struct command_word *cwp, int tab[], const char *word, int len)
{
     return member(cwp->tok, tab) && match_prefix(cwp, word, len);
}

@ General-purpose function for completing subcommands (command words,
following principla commands, like "BREAK TEMP", for example).

|text| is a |len|-bytes string to find completions for.\par
|tab| is a 0-terminated array of tokens that are expected in this position.\par
|*pind| is the current index to |tab|.

The function returns the next possible completion, and update the index
in |pind|. If no more completions are left, it returns \.{NULL}.

@c
static char *
extract_next_keyword(int *pind, int *tab, const char *text, int len)
{
     char *ret = NULL;
     int i = *pind;

     if (!tab)
	  return NULL;
     for (; cword[i].longname; i++)
	  if (tokmatch(&cword[i], tab, text, len)) {
	       ret = xstrdup(cword[i++].longname);
	       break;
	  }
     *pind = i;
     return ret;
}

@ Completion after \.{ADDRESS} command.
@c
static char *
compl_address(const char *text, int state)
{
     static int addrtok[] = { T_DELETE, T_PASSCOUNT, T_DISABLE, T_ENABLE,
			     T_IGNORE, T_LIST, T_LB, 0 };
     static int infotok[] = { T_BREAK, 0 };
     static int *toktab;
     static int i;
     
     if (state == 0) {
	  char *kw = rl_line_buffer;
	  int len = 0;
	  
	  toktab = addrtok;
	  getword(kw, len);
	  kw += len;
	  skipws(kw);
	  if (kw - rl_line_buffer < completion_start) {
	       char *p;
	       struct command_word *cwp;
	       
	       len = 0;
	       getword(kw, len);
	       cwp = find_command_word(kw, len);
	       
	       p = kw + len;
	       skipws(p);
	       if (p - rl_line_buffer == completion_start
		   && cwp && cwp->tok == T_LIST)
		    toktab = infotok;
	       else
		    toktab = NULL;
	  }
	  i = 0;
     }
     return extract_next_keyword(&i, toktab, text, strlen(text));
}

@ Completion after \.{BREAK}.
@c
static char *
compl_break(const char *text, int state)
{
     static int toktab[] = { T_TEMP, 0 };
     static int i;
     
     if (state == 0)
	  i = 0;
     return extract_next_keyword(&i, toktab, text, strlen(text));
}

@ Completion after \.{DUMP}.
@c
static char *
compl_dump(const char *text, int state)
{
     static int toktab[] = { T_REGISTERS, T_MEMORY, 0 };
     static int i;
     
     if (state == 0)
	  i = 0;
     return extract_next_keyword(&i, toktab, text, strlen(text));
}

@ Completion after \.{INFO} (alias \.{LIST}).
@c
static char *
compl_list(const char *text, int state)
{
     static int toktab[] = { T_IO, T_BREAK, 0 };
     static int i;
     
     if (state == 0)
	  i = 0;
     return extract_next_keyword(&i, toktab, text, strlen(text));
}

@ Completion after \.{HELP}.
@c
static char *
compl_help(const char *text, int state)
{
     static int i;
     struct command_word *cwp;
     int len = strlen(text);
     
     if (state == 0)
	  i = 0;
     while ((cwp = &cword[i++])->longname) 
	  if (cwp->first && match_prefix(cwp, text, len))
	       return xstrdup(cwp->longname);
     return NULL;
}

@ Completion after \.{ASGN}

@c
static char *
compl_asgn(const char *text, int state)
{
     if (state == 0) {
	  char *kw = rl_line_buffer;
	  int len = 0;

	  /* Skip ASGN keyword */
	  getword(kw, len);
	  kw += len;
	  skipws(kw);

	  if (kw - rl_line_buffer < completion_start) {
	       /* Skip device number */
	       len = 0;
	       getword(kw, len);
	       kw += len;
	       skipws(kw);

	       if (kw - rl_line_buffer <= completion_start) {
		    /* Require filename completion */
		    rl_filename_completion_desired = 1;
		    rl_attempted_completion_over = 0;
	       }
	  }
     }
     return NULL;
}

@ Return a copy of |name|. If |isdir| is set, append a slash to the result.
@c
char *
dupname(char *name, int isdir)
{
     size_t len = strlen(name) + (isdir ? 1 : 0);
     char *p = xmalloc(len + 1);
     strcpy(p, name);
     if (isdir)
	  strcat(p, "/");
     return p;
}

@ Find in directory |dirname| any executable files (or direcories, if
|abs| is not 0) that begin with |pfx|, and store their names in
|*ptab|. |*psize| gives the size of |*ptab| in entries, |*pcount| is
the count of actually used elements.

@c
void
complete_exec_expand(char ***ptab, size_t *pcount, size_t *psize,
		     const char *dirname, const char *pfx, int abs)
{
     char **tab = *ptab;
     size_t count = *pcount;
     size_t size = *psize;
     size_t pfxlen = strlen(pfx);
     DIR *dir;

     dir = opendir(dirname);
     if (dir) {
	  char *namebuf = NULL;
	  size_t namebuflen = 0;
	  size_t dirlen = strlen(dirname);
	  struct dirent *ent;

	  if (dirname[dirlen-1] == '/')
	       dirlen--;
	  
	  while (ent = readdir(dir)) {
	       size_t nlen;
	       
	       if (strcmp(ent->d_name, ".") == 0
		   || strcmp(ent->d_name, "..") == 0)
		    continue;

	       nlen = strlen(ent->d_name);
	       if (pfxlen > 0
                   && (nlen < pfxlen || memcmp(ent->d_name, pfx, pfxlen))) 
		    continue;
	       
	       nlen += dirlen + 1 + 1;

	       if (namebuflen < nlen) {
		    namebuf = xrealloc(namebuf, nlen);
		    if (namebuflen == 0) {
			 strcpy(namebuf, dirname);
			 namebuf[dirlen] = '/';
		    }
		    namebuflen = nlen;
	       }
	       strcpy(namebuf + dirlen + 1, ent->d_name);
	       if (access(namebuf, X_OK) == 0) {
		    struct stat sb;
		    int isdir;
		    
		    if (size == count) {
                         if (size == 0) { 
                             size = 16;
                             tab = xcalloc(size, sizeof(tab[0]));
                         } else
		             tab = x2nrealloc(tab, &size, sizeof(tab[0]));
                    }

		    isdir = stat(namebuf, &sb) == 0 && S_ISDIR(sb.st_mode);
		    if (abs) {
			 tab[count++] = dupname(namebuf, isdir);
			 if (isdir)
			      rl_completion_append_character = 0;
		    } else if (!isdir)
			 tab[count++] = dupname(ent->d_name, 0);
	       }
	  }
          closedir(dir);
	  free(namebuf);
     }
     *ptab = tab;
     *pcount = count;
     *psize = size;
}

@ Return possible completions of |text|, which is supposed to be an executable
file name. Unless |text| begins with a directory separator, search for
matching files in |PATH|.

@c
char **
complete_exec_path(const char *text)
{
     char **tab = NULL;
     size_t count = 0;
     size_t size = 0;
     char *p;
     
     if (text[0] == '/') {
	  char *p = strrchr(text, '/');
	  size_t len = p - text + 1;
	  char *dir;
          dir = xmalloc(len + 1);
	  memcpy(dir, text, len);
	  dir[len] = 0;
	  complete_exec_expand(&tab, &count, &size, dir, p + 1, 1);
	  free(dir);
     } else {
	  char *path = xstrdup(getenv("PATH"));
	  for (p = strtok(path, ":"); p; p = strtok(NULL, ":"))
	       complete_exec_expand(&tab, &count, &size, p, text, 0);
	  free(path);
     }
     if (tab) {
	  if (size == count) 
	       tab = x2nrealloc(&tab, &size, sizeof(tab[0]));
	  tab[count] = NULL;
     }
     return tab;
}

@ Completion after \.{SHELL}

@c
static char *
compl_shell(const char *text, int state)
{
     static char **comptab;
     if (state == 0) {
	  char *cmd;
	  char *kw = rl_line_buffer;
	  int len = 0;

	  /* Skip SHELL keyword */
	  if (kw[len] == '!') 
	       len++;
	  else 
	       getword(kw, len);
	  cmd = kw;
	  kw += len;
	  skipws(kw);

	  /* Get command name */
	  len = 0;
	  getword(kw, len);

	  if (isspace(kw[len])
	      && kw + len - rl_line_buffer < completion_start) {
	       /* Command name already present: require filename completion */
	       rl_filename_completion_desired = 1;
	       rl_attempted_completion_over = 0;
	  } else
	       comptab = complete_exec_path(kw);
     }

     if (comptab) {
	  if (comptab[state] == NULL) {
	       free(comptab);
	       comptab = NULL;
	  } else
	       return comptab[state];
     }
     return NULL;
}

static char *
compl_source(const char *text, int state)
{
     /* Command name already present: require filename completion */
     rl_filename_completion_desired = 1;
     rl_attempted_completion_over = 0;
     return NULL;
}

@ End of readline-specific section
@c
#endif

@ Read next lineful of characters. Returns pointer to allocated memory
location, which should be freed when no longer needed. 
@c
char *
mixterm_readline_internal(FILE *fp)
{
     char *line;
     char *p;
     size_t alloclen, linelen;

     p = line = xcalloc (1, 255);
     alloclen = 255;
     linelen = 0;
     for (;;) {
	  size_t n;

	  p = fgets(p, alloclen - linelen, fp);

	  if (p)
	       n = strlen(p);
	  else if (errno == EINTR) {
	       p = line;
	       linelen = 0;
	  } else {
	       free(line);
	       return NULL;
	  }

	  linelen += n;

	  /* Error.  */
	  if (linelen == 0) {
	       free(line);
	       return NULL;
	  }

	  /* Ok.  */
	  if (line[linelen - 1] == '\n') {
	       line[linelen - 1] = '\0';
	       return line;
	  } else {
	       line = x2realloc(line, &alloclen);
	       p = line + linelen;
	  }
     }
}

@ When {\tt readline} is not available, provide a simplified version.
@c
#ifndef WITH_READLINE
char *
readline(char *prompt)
{
     if (prompt) {
	  printf("%s", prompt);
	  fflush(stdout);
     }

     return mixterm_readline_internal(stdin);
}

#define mixterm_readline_init()
#endif

@*1 Reader functions.

@ Input from |stdin|.
@c
static char *
readline_reader(struct term_input *input)
{
     if (input->interactive)
	  return readline(prompt);
     return mixterm_readline_internal(stdin);
}

@ Input from a file. |input->arg| contains a |FILE| pointer. 
@c
static char *
file_reader(struct term_input *input)
{
     return mixterm_readline_internal(input->arg);
}


@*1 Command line parser.

@ Copy current token into |token.string|.
@c
void
copy_token(struct term_input *inp)
{
    char *p;

    p = inp->token.string;
    if (*inp->curp == '?' || *inp->curp == '!')
	 *p++ = *inp->curp++;
    else {
	 while (*inp->curp && !isspace(*inp->curp))
	      *p++ = *inp->curp++;
    }
    *p = 0;
}

@ Advance |curp| to the next token. Copy the current token into
|token.string| and store its type in |token.type|. Return token
type.
@c
int
nextkn(struct term_input *inp)
{
     if (!inp->curp) {
          char *p;

	  p = inp->curp = inp->reader(inp);
	  if (inp->curp) {
		  while (*inp->curp
                         && (*inp->curp == ' ' || *inp->curp == '\t'))
		       inp->curp++;
	          if (*inp->curp == 0) {
                       /* if an empty line is given, reuse the
			  latest command */
		       if (!inp->buffer)
			    return inp->token.type = T_EOL;
		       inp->curp = inp->buffer;
	          } else {
	               free(inp->buffer);
		       inp->buffer = p;
#ifdef WITH_READLINE
                       if (inp->interactive)
		           add_history(inp->curp);
#endif
		  }
	  }
     }
     
     if (!inp->curp)
	  return 0;

     while (*inp->curp && (*inp->curp == ' ' || *inp->curp == '\t'))
	  inp->curp++;

     if (!*inp->curp || *inp->curp == '#') {
	  inp->curp = NULL;
	  return inp->token.type = T_EOL;
     }

     if (isalpha(*inp->curp) || strchr("/.?!", *inp->curp)) {
	  int len;
	  struct command_word *cp;
	  struct command_word *found = NULL;
	  int ambiguous = 0;
	  
	  copy_token(inp);
	  len = strlen(inp->token.string);
	  for (cp = cword; cp->longname; cp++) {
	       int ll = strlen (cp->longname);

	       if (cp->shortname) {
		    int sl = strlen (cp->shortname);
		    if (sl == len
			&& strcasecmp (cp->shortname, inp->token.string) == 0)
			 return inp->token.type = cp->tok;
		    if (sl >= len)
			 continue;
	       }
	       if (ll >= len
		   && strncasecmp (cp->longname,
				   inp->token.string, len) == 0) {
		    if (!found) {
			 found = cp;
			 if (ll == len)
			      break;
		    } else {
			 if (!ambiguous) {
			      printf("AMBIGUOUS COMMAND VERB: %s",
				     found->longname);
			      ambiguous = 1;
			 }
			 printf(", %s", cp->longname);
		    }
	       }
	  }
	  if (ambiguous) {
	       putchar('\n');
	       inp->curp = NULL;
	       return inp->token.type = T_EOL;
	  }
	  return inp->token.type = (found ? found->tok : T_STRING);
     }
     if (isdigit(*inp->curp)) {
	  copy_token(inp);
	  inp->token.number = strtol(inp->token.string, NULL, 0);
	  return inp->token.type = T_NUMBER;
     }
     return inp->token.type = *inp->curp++;
}

@ Get \.{MIX} memory address from |token.number|. Bail out if the address
is not valid.

@c
int
getaddr(struct term_input *inp)
{
     int addr = inp->token.number;
     
     if (addr < 0 || addr >= MEMSIZE) {
	  printf("LOCATION OUT OF ADDRESS SPACE\n");
	  return -1;
     } 
     return addr;
}

@ Return 1, if the string |p| is an affirmative reply, 0, if it is
a negative reply, and -1 if neither of these apply.

@c
static int
true_answer_p(const char *p)
{
     if (!p)
	  return -1;

     while (*p && isspace(*p))
	  p++;

     switch (*p) {
     case 'y':
     case 'Y':
	  return 1;

     case 'n':
     case 'N':
	  return 0;
    }
  return -1;
}


@ Format |ap| according to |fmt| and print it on screen. Read input 
from the user. Return 1 if the user confirmed, 0 otherwise.

@c
static int
vgetyn(const char *fmt, va_list ap)
{
     char repl[64];

     while (1) {
	  char *p;
	  int len, rc;
      
	  vprintf(fmt, ap);
	  printf("? ");
	  p = fgets(repl, sizeof repl, stdin);
	  if (!p)
	       return 0;
	  len = strlen(p);
	  if (len > 0 && p[len-1] == '\n')
	       p[len--] = 0;

	  rc = true_answer_p(p);

	  if (rc >= 0)
	       return rc;

	  printf("PLEASE ANSWER YES OR NO: ");
     }
     return 0; /* to pacify gcc */
}

@ Format arguments on screen according to |fmt|. Read input 
from the user. Return 1 if the user confirmed, 0 otherwise.

@c
int
getyn (const char *fmt, ...)
{
     va_list ap;
     int rc;
  
     va_start(ap, fmt);
     rc = vgetyn(fmt, ap);
     va_end(ap);
     return rc;
}


@ Set a breakpoint.\par
The command accepts up to three arguments. In it's simplest form it is

{\parindent = 5em\indent {\sc BREAK} {\it addr}}

where {\it addr} is a valid \.{MIX} address.

Another form

{\parindent = 5em\indent {\sc BREAK} {\sc TEMP} {\it addr}}

sets a temporary breakpoint, i.e. the one that will be removed after
it is crossed.

@c
int
m_break(struct term_input *inp)
{
     int addr;
     int count = 0;

     if (nextkn(inp) == T_TEMP) {
	  count = 1;
	  nextkn(inp);
     }
     if (inp->token.type != T_NUMBER) {
	  return 1;
     }
     if ((addr = getaddr(inp)) == -1)
	  return 1;

     if (nextkn(inp) != T_EOL)
	  return 1;
     bp_set(addr, count);
     return 0;
}

@ A shorthand notation for \.{BREAK TEMP}.
@c
int
m_bt(struct term_input *inp)
{
     int addr;
    
     if (nextkn(inp) != T_NUMBER) 
	  return 1;
     if ((addr = getaddr(inp)) == -1)
	  return 1;
     bp_set(addr, 1);
     return 0;
}

@ This variable controls whether breakpoints are addressed by their number of
by the address they are set to. If |address_mode| is 1, the addresses are
used.

@c
static int address_mode;

@ A prefix for any breakpoint manipulation command:\par
{\parindent=5em\indent{\sc ADDRESS [{\it breakpoint-command}]}}.

When used, specifies that the breakpoints are addressed by the address they
are set to, instead of breakpoint number. E.g.:

{\parindent=5em\indent{\sc ADDRESS ENABLE 1000}}.

@c
int
m_address(struct term_input *inp)
{
     address_mode = 1;
     return 0;
}

@ Clear a breakpoint.\par
{\parindent=5em\indent{\sc DELETE {\it n}}}

Deletes a breakpoint with the given sequence number {\it n}.

When prefixed with {\sc ADDRESS}, deletes all breakpoints set on address
{\it n}.

Several breakpoint numbers or addresses can be given.

@c
int
m_delete(struct term_input *inp)
{
     if (nextkn(inp) == T_EOL) {
	  if (!inp->interactive || getyn("DELETE ALL BREAKPOINTS")) 
	       bp_delete(-1);
	  return 0;
     }
     
     do {
	  if (inp->token.type != T_NUMBER) 
	       return 1;
	  if (address_mode) {
               int cur;
	       if (getaddr(inp) == -1)
		    return 1;
	       for (cur = bp_first(inp->token.number); cur;) {
		    int next = bp_next(cur);
		    bp_delete(cur);
		    cur = next;
	       }
	  } else
	       bp_delete(inp->token.number);
     } while (nextkn(inp) != T_EOL); 
     return 0;
}

@ Auxiliar function for \.{ENABLE} and \.{DISABLE} command.
Parses the rest of command line, and for each breakpoint specified there
(either by its number or address, depending on the |address_mode| setting)
sets its status to |status|.

@c
int
change_breakpoint_status(struct term_input *inp, int status)
{
     if (nextkn(inp) == T_EOL) {
	  bp_enable(-1, status);
	  return 0;
     }
     
     do {
	  if (inp->token.type != T_NUMBER) 
	       return 1;
	  if (address_mode) {
	       int n;
	       
	       if (getaddr(inp) == -1)
		    return 1;
	       for (n = bp_first(inp->token.number); n; n = bp_next(n)) 
		    bp_enable(inp->token.number, status);
	  } else
	       bp_enable(inp->token.number, status);
     } while (nextkn(inp) != T_EOL);
     return 0;
}

@ Enable a breakpoint.\par
{\parindent=5em\indent{\sc ENABLE {\it n}}}

Disable a breakpoint with the given sequence number {\it n}.

When prefixed with {\sc ADDRESS}, changes all breakpoints set on
address {\it n}.

Several breakpoint numbers or addresses can be given.

@c
int
m_enable(struct term_input *inp)
{
     return change_breakpoint_status(inp, 1);
}

@ Disable a breakpoint.\par
{\parindent=5em\indent{\sc DISABLE {\it n}}}

Disable a breakpoint with the given sequence number {\it n}.

When prefixed with {\sc ADDRESS}, changes all breakpoints set on
address {\it n}.

Several breakpoint numbers or addresses can be given.

@c
int
m_disable(struct term_input *inp)
{
     return change_breakpoint_status(inp, 0);
}


@ Ignore next {\it count} crossings of breakpoint {\it n}.\par
{\parindent=5em\indent{\sc IGNORE {\it n} {\it count}}}

When prefixed with {\sc ADDRESS}, changes all breakpoints set on
address {\it n}.

@c
int
m_ignore(struct term_input *inp)
{
     int n;
     unsigned count;
     
     if (nextkn(inp) != T_NUMBER)
	  return 1;
     n = inp->token.number;
     if (nextkn(inp) != T_NUMBER) 
	  return 1;
     count = inp->token.number;
     if (address_mode) {
	  int i;
	  for (i = bp_first(n); i; i = bp_next(i)) 
	       bp_set_ignore(i, count);
     } else
	  bp_set_ignore(n, count);  	
     return 0; 
}

@ Disable breakpoint {\it n} after next {\it count} crossings.\par
{\parindent=5em\indent{\sc PASSCOUNT {\it n} {\it count}}}

When prefixed with {\sc ADDRESS}, changes all breakpoints set on
address {\it n}.

@c
int
m_passcount(struct term_input *inp)
{
     int n;
     unsigned max_hits;
     
     if (nextkn(inp) != T_NUMBER)
	  return 1;
     n = inp->token.number;
     if (nextkn(inp) != T_NUMBER) 
	  return 1;
     max_hits = inp->token.number;
     if (address_mode) {
	  int i;
	  for (i = bp_first(n); i; i = bp_next(i)) 
	       bp_set_max_crossings(i, max_hits);  	
     } else
	  bp_set_max_crossings(n, max_hits);  	
     return 0;
}

@ List breakpoints.
@c
int
m_lb(struct term_input *inp)
{
     int n = -1;
     
     if (nextkn(inp) == T_NUMBER) {
	  n = inp->token.number;
	  nextkn(inp);
     }
     if (inp->token.type != T_EOL) 
	  return 1;
     list_bp(n, address_mode);
     return 0;
}

@ List \.{I/O} devices.
@c
int
m_lio(struct term_input *inp)
{
     int dev = -1;
     
     if (nextkn(inp) == T_NUMBER) {
	  dev = inp->token.number;
	  nextkn(inp);
     }
     if (inp->token.type != T_EOL) 
	  return 1;
     list_io(dev);
     return 0;
}

@ List command.

There are three variants of this command:

\tabskip=1em \halign{%
 \strut\sc#\hfil&\strut{\raggedright#}\cr
LIST IO & Lists all existing I/O devices\cr
LIST IO {\it num} & lists the device number {\it num}\cr
LIST BREAK &  lists all breakpoints\cr}

For compatibility with \.{GDB}, \.{INFO} may be used instead of \.{LIST}.

@c
int
m_list(struct term_input *inp)
{
     switch (nextkn(inp)) {
     case T_IO:
	  return m_lio(inp);

     case T_BREAK:
	  return m_lb(inp);

     default:
	  return 1;
     }
}

@ Auxiliary function for \.{NEXT} and \.{STEP}.

@c
int
next_or_step(struct term_input *inp, int step_into)
{
     unsigned count = 1;	
     
     nextkn(inp);
     if (inp->token.type == T_NUMBER) {
	  if (inp->token.number > 0)
	       count = inp->token.number;
	  nextkn(inp);
     }
     if (inp->token.type != T_EOL) 
	  return 1;
     set_next(count, step_into);
     run();
     return 0;
}

@ Execute next \.{MIX} instruction.
@c
int
m_next(struct term_input *inp)
{
     return next_or_step(inp, F);
}

@ Execute next \.{MIX} instruction. If it is a call, step into the called
function.
@c
int
m_step(struct term_input *inp)
{
     return next_or_step(inp, T);
}

@ Continue after crossing a breakpoint.
@c
int
m_cont(struct term_input *inp)
{
     if (nextkn(inp) != T_EOL) 
	  return 1;
     run();
     return 0;
}

@ Assign \UNIX/ file name to \.{MIX} device number
@c
int
m_asgn(struct term_input *inp)
{
     int devno;
     
     if (nextkn(inp) != T_NUMBER) 
	  return 1;
     devno = inp->token.number;
     if (nextkn(inp) == T_EOL) 
	  return 1;
     asgn_io(devno, inp->token.string);
     return 0;
}

@ Emulate \.{MIX} \.{GO} button.
@c
int
m_go(struct term_input *inp)
{
     if (nextkn(inp) != T_EOL) 
	  return 1; 
     go();
     return 0;
}

@ Dump registers.
@c
int
m_dr(struct term_input *inp)
{
     if (nextkn(inp) != T_EOL) 
	  return 1;
     dump_status();
     return 0;
}

@ Dump memory range.\par
{\parindent=5em\indent{\sc DM} [{\it addr} [{\it addr}]]}
Optional arguments specify start and end addresses of
the memory block to be displayed. The addresses are rounded to the nearest
memory boundary divisible by 5 (see |@<Diagnostic functions@>|.)

If no arguments are given, prints the entire \.{MIX} memory.

@c
int
m_dm(struct term_input *inp)
{
     int start_loc = 0, end_loc = MEMSIZE;
     
     if (nextkn(inp) == T_NUMBER) {
	  if ((start_loc = getaddr(inp)) == -1) {
	       return 1;
	  }
	  if (nextkn(inp) == T_NUMBER) {
	       if ((end_loc = getaddr(inp)) == -1) 
		    return 1;
	       nextkn(inp);
	  }
     }
     if (end_loc < start_loc) {
	  printf("BAD RANGE\n");
	  return 0;
     }
     if (inp->token.type != T_EOL) 
	  return 1;

     dump_memory(start_loc, end_loc);
     return 0;
}

@ Dump memory or registers
@c
int
m_dump(struct term_input *inp)
{
     switch (nextkn(inp)) {
     case T_MEMORY:
	  return m_dm(inp);

     case T_REGISTERS:
	  return m_dr(inp);

     case T_EOL:
	  dump();
	  return 0;

     default:
          return 1;
     }
}

@ Disassemble a memory range.\par
{\parindent=5em{\sc UNASM} [{\it addr} [{\it addr}]]}
If no arguments are specified, disassembles the next instruction.
Short notation: {\sc U}.

@c
int
m_unasm(struct term_input *inp)
{
     extern int loc;
     int start_loc = loc, end_loc = loc+5;
     
     if (nextkn(inp) == T_NUMBER) {
	  if ((start_loc = getaddr(inp)) == -1) 
	       return 1;
	  if (nextkn(inp) == T_NUMBER) {
	       if ((end_loc = getaddr(inp)) == -1) 
		    return 1;
	       nextkn(inp);
	  } else
	       end_loc = start_loc + 5;
     }
     if (end_loc < start_loc) {
	  printf("BAD RANGE\n");
	  return 0;
     }
     if (inp->token.type != T_EOL) 
	  return 1;
     disas(stdout, start_loc, end_loc);
     return 0;
}

@ Exit the terminal.
@c
int
m_quit(struct term_input *inp)
{
     exit(0);
}

@ Execute a shell command.
@c
int
m_shell(struct term_input *inp)
{
     while (*inp->curp && isspace(*inp->curp))
	  inp->curp++;
     if (*inp->curp)
	  system(inp->curp);
     else {
	  char *sh = getenv("SHELL");
	  if (!sh)
	       sh = "/bin/sh";
	  system(sh);
     }
     *inp->curp = 0;
     return 0;
}

@ Source a file.
@c
int
m_source(struct term_input *inp)
{
     if (nextkn(inp) == T_EOL) 
	  return 1;
     source_file(inp->token.string, 0);
     if (nextkn(inp) != T_EOL) 
	  return 1;
     return 0;
}

@ Show program version and short licensing information.

@c
int
m_version(struct term_input *inp)
{
     if (nextkn(inp) != T_EOL) 
	  return 1;
     mix_version(program_name);
     return 0;
}

@ Process end of line.

@c
int
m_eol(struct term_input *inp)
{
     address_mode = 0;
     return 0;
}

@ Indicate syntax error.
@c
int
m_err(struct term_input *inp)
{
     if (inp->interactive)
         printf("NOT RECOGNIZED\n");
     else  
         printf("%s:%u: %s\n", inp->input_file, inp->input_line,
                "NOT RECOGNIZED");
     inp->curp = NULL;
     return 0;
}

@ Structure of the dispatcher table.
@c
struct disp {
     int tok;                                  /* Token type */
     int @[@] (*fun)(struct term_input *inp);  /* Handler function */
     char *help;                               /* Usage description */
};

@ Return a dispatcher structure for the token |tok|.
@c
struct disp *
find_disp(struct disp *dsp, int tok)
{
     for (; dsp->tok; dsp++) {
	  if (tok == dsp->tok)
	       return dsp;
     }
     return NULL;
}

@ Default help function.
@c
static void help_kw(int tok);
static void help_all(void);

int
m_help(struct term_input *inp)
{
     if (nextkn(inp) == T_EOL) 
	  help_all();
     else
	  help_kw(inp->token.type);
     return 0;
}


@ Dispatcher table for MIX terminal commands.
@c
struct disp main_disp[] = {
     { T_ADDRESS,   m_address, "ADDRESS <BREAKPOINT COMMAND>" },
     { T_BREAK,     m_break,   "BREAK [TEMP] <NUM> [<NUM>...]" }, @/ 
     { T_BT,        m_bt,      "BT <ADDR>"  }, @/
     { T_DELETE,    m_delete,  "DELETE [<NUM>...]" }, @/
     { T_ENABLE,    m_enable,  "ENABLE [<NUM>...]" }, @/
     { T_DISABLE,   m_disable, "DISABLE [<NUM>...]" }, @/
     { T_IGNORE,    m_ignore,  "IGNORE <NUM> <COUNT>" }, @/
     { T_PASSCOUNT, m_passcount, "PASSCOUNT <NUM> <COUNT>" }, @/
     { T_LIST,      m_list,    "INFO [BREAK|IO] [<NUM>]" }, @/
     { T_LB,        m_lb,      "LB [<NUM>]" }, @/
     { T_LI,        m_lio,     "LI [<DEVICE>]" }, @/  
     { T_NEXT,      m_next,    "NEXT [<NUM>]" }, @/
     { T_STEP,      m_step,    "STEP [<NUM>]"  }, @/
     { T_ASGN,      m_asgn,    "ASGN <DEVICE> <FILE>" }, @/
     { T_GO,        m_go,      "GO" }, @/
     { T_DUMP,      m_dump,    "DUMP [REGISTERS|MEMORY [<ADDR> [<ADDR>]]]" }, @/
     { T_DR,        m_dr,      "DR" }, @/
     { T_DM,        m_dm,      "DM [<ADDR> [<ADDR>]]" }, @/
     { T_QUIT,      m_quit,    "QUIT" }, @/
     { T_EOL,       m_eol,     NULL }, @/
     { T_CONT,      m_cont,    "CONTINUE"  }, @/
     { T_UNASM,     m_unasm,   "DISASSEMBLE [<ADDR> [<ADDR>]]" }, @/
     { T_HELP,      m_help,    "HELP [<COMMAND>]" }, @/
     { T_SHELL,     m_shell,   "SHELL [<COMMAND> [<ARGS>]]" }, @/
     { T_SOURCE,    m_source,  "SOURCE <FILE>" }, @/
     { T_VERSION,   m_version, "VERSION" }, @/
     { 0 } @/
};

@ Produce a help summary for all commands.
@c
static void
help_all()
{
     struct disp *dsp;
     for (dsp = main_disp; dsp->tok; dsp++) {
	  if (dsp->help)
	       printf("%s\n", dsp->help);
     }
}

@ Produce a help summary for the token |tok|.
@c
static void
help_kw(int tok)
{
     struct disp *dsp = find_disp(main_disp, tok);
     if (!dsp)
	  printf("NO HELP FOR THIS COMMAND\n");
     else
	  printf("%s\n", dsp->help);
}

@ \.{MIX} terminal prompt. In homage to \.{IBM} 360.

@c
char init_prompt[] = "\nMIX TERMINAL STATION READY FOR COMMUNICATION\n";

@ Main loop. Reads and executes commands.

@c
void
read_and_do_loop(struct term_input *inp)
{
     while (nextkn(inp)) {
	  struct disp *dsp = find_disp(main_disp, inp->token.type);
	  if (dsp) {
	       if ((*dsp->fun)(inp)) {
                  if (inp->interactive && dsp->help)
		       printf("USAGE: %s\n", dsp->help);
                  else
                       error_at_line(0, 0, inp->input_file, inp->input_line,
                                     "SYNTAX ERROR");
		  if (!inp->interactive)
		       break;
               }
	  } else {
               m_err(inp);
	       if (!inp->interactive)
		    break;
	  }
          inp->input_line++;
     }
}

@ Read commands from |file|. If |quite| is 1, do not bail out on non-existing
files.

Return 1 if |file| does not exist, and 0 otherwise.

@c
int
source_file(char *file, int quiet)
{
     struct term_input inp;
     FILE *fp = fopen(file, "r");
     if (!fp) {
	  if (!quiet)
	       error(0, errno, "CANNOT OPEN FILE `%s'", file);
	  return 1;
     }

     memset(&inp, 0, sizeof inp);
     inp.reader = file_reader;
     inp.arg = fp;
     inp.input_file = file;
     inp.input_line = 1;
     inp.interactive = 0;
     read_and_do_loop(&inp);
     free(inp.buffer);
     fclose(fp);
     return 0;
}

@ Main terminal function.
@c
void
mixterm()
{
     struct term_input inp;
     memset(&inp, 0, sizeof inp);
     inp.reader = readline_reader;
     inp.input_file = "<stdin>";
     inp.input_line = 1;
     inp.interactive = isatty(0);

     if (inp.interactive) {
          mixterm_readline_init();
	  printf("%s\n", init_prompt);
     }
     source_file(".mixsim", 1);
     read_and_do_loop(&inp);
#ifdef WITH_READLINE
     if (inp.interactive)
	  write_history(history_file_name());
#endif
}


