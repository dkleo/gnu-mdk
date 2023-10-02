% This file is part of MIX
% Copyright (C) 2005, 2007 Sergey Poznyakoff
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3, 
% or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

@* YFMT -- CTANGLE TO YACC/LEX REFORMATTER.

{\sl Ctangle\/} was not designed to produce other files, than \CEE/ sources.
However, it can, with certain precautions, be used to produce \.{YACC} or
\.{LEX} source files as well. \.{MIX} project explores this
possibility. 

Apart from some minor formatting hacks (see {\tt src/mixal.w} and
{\tt src/mixlex.w}), reformatting of the resulting {\sl ctangle\/} output is
needed. This program is designed to take care of it.

One major problem are {\tt \#line} preprocessor directives inserted by
{\sl ctangle.} These are allowed only in \CEE/ parts of a \.{YACC} or
\.{LEX} source. {\sl Yfmt\/} removes these from where they do not
belong and inserts additional {\tt \#line} directives after opening
braces of \CEE/ blocks to keep the line numbering correct.

Another problem are {\sl ctangle\/} comments. These are inserted at
column |0| and confuse {\sl lex} when they are encountered in the
rule section. When processing rule sections, {\sl yfmt\/} prepends
with a tab character any comments and any \CEE/ code it encounters.

\def\ysep/{{\tt \%\%}}
\def\ylbrace/{{\tt \%$\{$}}
\def\yrbrace/{{\tt \%$\}$}}

@s line c

@ Header files to include.
@c
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

@ This structure represents a location in the source file.
@c
typedef struct {
     char *file;
     int line;
} Locus;

@ These two variables represent the ``real'' and ``original''
location. |real_locus| is the location relative to the current input
file. |effective_locus| is the location based on the recent |#line| 
directive.
@c
Locus real_locus, effective_locus;

@ The following code is used to initialize these variables.
@<Initialize locus...@>=
real_locus.file = effective_locus.file = argv[optind];
real_locus.line = effective_locus.line = 1;

@ Input and output file descriptors.
@c
FILE *infile, *outfile;

@ Usual code for opening the input line.
@<Open input file@>=
if (strcmp(argv[optind], "-") == 0)
     infile = stdin;
else if ((infile = fopen(argv[optind], "r")) == NULL) {
     error("Cannot open input file `%s': %s", argv[optind], strerror(errno));
     exit(1);
}

@
@<Open output file@>=
if (strcmp(outname, "-") == 0)
    outfile = stdout;
else if ((outfile = fopen(outname, "w")) == NULL) {
     error("Cannot open output file `%s': %s", outname, strerror(errno));
     exit(1);
}

@ Output effective line number
@c
void
output_effective_line()
{
     fprintf(outfile, "#line %d \"%s\"\n",
	     effective_locus.line, effective_locus.file);
}

@
@c
void
output_chars(char *p)
{
     fprintf(outfile, "%s", p);
}

@ Program name for error reporting.
@c
char *progname;

@ It is set in |main| using the following code.
@<Set progname@>=
progname = strrchr(argv[0], '/');
if (progname)
    progname++;
else
    progname = argv[0];

@ Error reporting function
@c
void
error(char *fmt, ...)
{
     va_list ap;

     fprintf(stderr, "%s: ", progname);
     va_start(ap, fmt);
     vfprintf(stderr, fmt, ap);
     va_end(ap);
     fprintf(stderr, "\n");
}

@ Report usage error
@c
void
usage_error(char *msg)
{
     error(msg);
     fprintf(stderr, "Try `%s -h' for more information.\n", progname);
     exit(1);
}

@ Report input file error
@c
void
input_error(char *msg)
{
     error("%s:%d: %s", effective_locus.file, effective_locus.line, msg);
}

@ Each Yacc/Lex source file contains at most 5 sections:

|LIMBO| - Initial section before the first \ylbrace/ or \ysep/.

|CHEAD| - Optional \CEE/ header enclosed between \ylbrace/ and \yrbrace/. 

|DEFNS| - Optional source-specific defines. The exact format depends on whether
 it is a {\tt .y} or {\tt .l} source. The section ends with the first
 \ysep/.

|RULES| - Rules section. It starts after first \ysep/ and ends with the
 second \ysep/ or end of file, whichever is encountered first.

|CBODY| - A \CEE/ code part in |RULES| section. It starts with the first $\{$
character after the first unescaped whitespace on the line, and ends when a
matching $\}$ is encountered.

Within both |RULES| and |CBODY| sections a limited \CEE/ lexical
support is enabled, namely, \CEE/ strings are understood and `$\{$', 
`$\}$' are matched.

|CTAIL| - \CEE/ tail section. It starts after the second \ysep/, if it
 is present, and extends to the end of file.

Among these sections, only |RULES| is obligatory.

@d LIMBO 0
@d CHEAD 1
@d DEFNS 2 
@d RULES 3
@d CBODY 4
@d CTAIL 5

@d EOL   1
@d LINE  2
@d YSEP  3
@d YLBRACE 4
@d YRBRACE 5
@d COMMENT 6


@c
@h
int state; /* Current input file state */

@ Type of process function.
@c
typedef void @[@] (*Procfun)(void);

@
@c
@<Basic input functions@>@/
@<Process functions@>

@ Table of processing functions for each state.
@c
Procfun process[] = { proc_limbo, proc_chead, proc_defns, proc_rules,
                      proc_cbody, proc_ctail };

@ Main processing function.
@c
int
convertor()
{
     while (token != EOF)
	process[state]();
     return 0;    
}

@ Input token
@<Basic input functions@>=
int token;                 /* Last input token as read by |gettkn| */
int lastchar = '\n';       /* Last input character returned by |nextchar| */

@ |return_line_info| controls the behavior of |gettkn| after processing
a |#line| directive. If |return_line_info == 0|, |gettkn| will attempt to
read next token after the directive was handled. Otherwise, |gettkn| will
return |LINE|.
@<Basic input functions@>=
int return_line_info = 0;  

@ The putback buffer is used when it is necessary to return several characters
to the input stream. The buffer is filled from left to right and read from
right to left.

@d MAXSAVECHARS 128

@<Basic input functions@>=
char pbuffer[MAXSAVECHARS];   /* Putback buffer */
int pindex = 0;               /* Index of the next available slot in |pbuffer| */

@ Read next character from the input. Update source locations if necessary.
@<Basic input functions@>=
int
nextchar()
{
     if (pindex > 0) 
          lastchar = pbuffer[--pindex];
     else {
	  lastchar = fgetc(infile);
	  if (lastchar == '\n') {
	       real_locus.line++;
	       effective_locus.line++;
	  }
     }
     return lastchar;
}

@ A save buffer, used to keep the characters read for eventual future use.
The buffer is filled and read from left to right.
@<Basic input functions@>=
char savebuffer[MAXSAVECHARS];
int saveindex;

@ Put the current save buffer contents back into the input stream.
@<Basic input functions@>=
void
putback()
{
    while (saveindex > 0)
        pbuffer[pindex++] = savebuffer[--saveindex];
}

@ Put the last read character back into the input stream. 
@<Basic input functions@>=
void
putback_last()
{
    pbuffer[pindex++] = lastchar;
}

@ Clear the save buffer.
@<Basic input functions@>=
void
clearsave()
{
    saveindex = 0;
}

@ Save the current character.
@<Basic input functions@>=
void
savechar()
{
    if (saveindex == MAXSAVECHARS) {
        input_error("Save buffer overflow");
        abort();
    }
    savebuffer[saveindex++] = lastchar;
}

@ Skip all characters up to the end of line.
@<Basic input functions@>=
void
skipchars()
{
     while (nextchar() != EOF && lastchar != '\n')
	  ;
}

@ Format the effective code location as |#line| preprocessor directive
and place it into the save buffer.
@<Basic input functions@>=
void
save_effective_line()
{
    saveindex = sprintf(savebuffer, "#line %d \"%s\"\n",
                        effective_locus.line, effective_locus.file);
    if (saveindex == MAXSAVECHARS) {
        input_error("Save buffer overflow");
        abort();
    }
}

@ Flush save buffer.
@<Basic input functions@>=
void
flushsave()
{
     if (saveindex) {
	  fwrite(savebuffer, saveindex, 1, outfile);
	  clearsave();
     }
}

@ Copy to output all characters from the current position up to the end of
line.
@<Basic input functions@>=
void
copychars()
{
     if (token == EOL)
          fputc('\n', outfile);
     else {
          flushsave();
          while (nextchar() != EOF && lastchar != '\n')
	       fputc(lastchar, outfile);
          if (lastchar == '\n')
               fputc(lastchar, outfile);
     }
}

@ Read next token from the input stream.
@<Basic input functions@>=
int
get_token()
{
     static char *linestr = "line";

     if (lastchar != '\n')
	  skipchars();

     if (nextchar() == EOF)
	  return EOF;

     if (lastchar == '\n')
          return EOL;
     else if (lastchar == '#') {
	  int n;
          char *p;
	  
	  savechar();
	  while (nextchar() && isspace(lastchar))
	       /* Skip optional whitespace */;
	  
	  for (p = linestr; *p; p++, nextchar()) {
	       savechar();
	       if (lastchar != *p) 
		    return LINE;
	  }
	  
	  while (nextchar() && isspace(lastchar))
	       /* Skip whitespace */;

	  clearsave();
	  if (!isdigit(lastchar)) 
	       input_error("Invalid #line directive");
	  else {
	       for (n = 0; isdigit(lastchar); nextchar()) 
		    n = n * 10 + lastchar - '0';

	       effective_locus.line = n - 1; /* Compensate for the next newline */
	       
	       while ((lastchar != '\n' && isspace(lastchar)) && nextchar())
		    /* Skip whitespace */;

	       if (lastchar == '"') {
		    /* Collect the file name */
		    while (nextchar() && lastchar != '"')
			 savechar();

		    effective_locus.file = malloc(saveindex+1);
                    assert(effective_locus.file != NULL);
                    memcpy(effective_locus.file, savebuffer, saveindex);
                    effective_locus.file[saveindex] = 0;

 		    clearsave();
	       }
               if (return_line_info) {
                   save_effective_line();
                   return LINE;
               }
	  }
     } else if (lastchar == '%') {
	  savechar();
	  nextchar();
	  savechar();
	  switch (lastchar) {
	  case '{':
	       return YLBRACE;

	  case '}':
	       return YRBRACE;

	  case '%':
	       return YSEP;

	  default:
	       return LINE;
	  }
     } else if (lastchar == '/') {
	  savechar();
	  if (nextchar() == '*') {
	       do {
		    do
			 savechar();
		    while (nextchar() && lastchar != '*');
		    savechar();
	       } while (nextchar() && lastchar != '/');
	       savechar();
	       return COMMENT;
	  } else
	       return LINE;
     } else {
          savechar();
	  return LINE;
     }
     return get_token(); /* Tail recursion */
}

@
@<Basic input functions@>=
int
gettkn()
{
     return token = get_token();
}

@ Ignore everything found in the limbo section.
@<Process...@>=
void
proc_limbo()
{
     return_line_info = 0;
     while (state == LIMBO && gettkn() > 0) {
	  if (token == YLBRACE)
	       state = CHEAD;
	  else if (token == YSEP)
	       state = RULES;
	  else if (saveindex > 0 && savebuffer[0] == '%')
	       copychars();
          else
               clearsave();
     }
}

@ Process a \CEE/ heading section.
@<Process...@>=
void
proc_chead()
{
     return_line_info = 1;
     copychars();
     output_effective_line();
     while (state == CHEAD && gettkn() > 0) {
	  copychars();
	  if (token == YRBRACE)
	       state = DEFNS;
     }
}

@ Process input-specific definitions.
@<Process...@>=
void
proc_defns()
{
     return_line_info = 0;
     while (state == DEFNS && gettkn() > 0) {
	  if (token == COMMENT)
	       fputc('\t', outfile);
	  copychars();
	  if (token == YSEP)
	       state = RULES;
     }
}

@ Return |1| if the save buffer contains a valid {\sl ctangle\/} comment.
@c
int
ctangle_comment()
{
     if (saveindex > 3 && memcmp(savebuffer, "/*", 2) == 0) {
	  int i;

	  if (savebuffer[2] == ':') {
	       for (i = 3; i < saveindex && savebuffer[i] != '*'; i++)
		    if (!isdigit(savebuffer[i]))
			 return 0;

	       return i + 1 < saveindex && savebuffer[i+1] == '/';
	  } else if (isdigit(savebuffer[2])) {
	       for (i = 3; i < saveindex && savebuffer[i] != ':'; i++)
		    if (!isdigit(savebuffer[i]))
			 return 0;
	       
	       return saveindex - i > 3 && memcmp(savebuffer + i, ":*/", 3) == 0;
	  }
     }
     return 0;
}

@ Handle rules section.
@<Process...@>=
void
proc_rules()
{
     int ws = 0;
     
     return_line_info = 0;
     /* FIXME! */
     while (state == RULES && gettkn() > 0) {
	  if (token == YSEP)
	       state = CTAIL;
	  else if (token == EOL)
	       ;
	  else if (token == COMMENT) {
	       fputc('\t', outfile);
	       copychars();
	  } else if (token != EOL) {
	       int quote = 0;
	       int escape = 0;
	       
	       putback();
	       do {
		    nextchar();
		    if (escape)
			 escape = 0;
		    else if (quote) {
			 if (lastchar == quote)
			      quote = 0;
		    } else if (lastchar == '\\')
			 escape = 1;
		    else if (lastchar == '"')
			 quote = '"';
		    else if (lastchar == '[')
			 quote = ']';
		    else if (lastchar == '\'')
			 quote = '\'';
		    else if (lastchar == ' ' || lastchar == '\t')
			 ws = 1;
		    else if (lastchar == '{') {
			 if (ws) {
			      state = CBODY;
			      break;
			 }
		    }
		    savechar();
	       } while (lastchar != '\n');
	       ws++;
	       flushsave();
	  }
     }
}

@ Process \CEE/ material from rules section.
@<Process...@>=
void
proc_cbody()
{
     int nesting = 0;
     int quote = 0;
     
     return_line_info = 1;

     output_chars("\t{");

     for (nextchar(); lastchar == ' ' || lastchar == '\t'; nextchar()) 
	  fputc(lastchar, outfile);
     
     if (lastchar != '\n') {
	  fputc('\n', outfile);
	  putback_last();
     } else {
	  fputc(lastchar, outfile);
	  if (gettkn() < 0)
	       return;
	  putback();
     }
     
     output_effective_line();
     while (1) {
	  int escape = 0;

	  if (!strchr(" \t#", lastchar) && !quote)
	       fputc('\t', outfile); /* To keep lex happy */
	  do {
	       nextchar();
	       if (escape)
		    escape = 0;
	       else if (quote) {
		    if (lastchar == quote)
			 quote = 0;
	       } else if (lastchar == '\\')
		    escape = 1;
	       else if (lastchar == '"')
		    quote = '"';
	       else if (lastchar == '\'')
		    quote = '\'';
	       else if (lastchar == '{')
		    nesting++;
	       else if (lastchar == '}') {
		    if (nesting-- == 0) {
			 fputc(lastchar, outfile);
			 fputc('\n', outfile);
			 state = RULES;
			 return;
		    }
	       }
	       fputc(lastchar, outfile);
	  } while (lastchar != '\n');

	  if (gettkn() <= 0)
	       break;
	  if (lastchar == '\n')
	       savechar();
	  putback();
     }
}

@ Process \CEE/ tail part.
@<Process...@>=
void
proc_ctail()
{
     return_line_info = 1;
     copychars();
     output_effective_line();
     while (gettkn() > 0) 
	  copychars();
}


@ Main function.
@c
int
main(int argc, char **argv)
{
     int c;
     char *outname = "-";

     @<Set progname@>@;
     while ((c = getopt(argc, argv, "o:h")) != EOF) {
	  switch (c) {
	  case 'o':
	       outname = optarg;
	       break;
	  case 'h':
	       printf("usage: yfmt [-o outfile][-h] filename\n");
	       exit(0);
	  default:
	       exit(1);
	  }
     }

     if (optind == argc) 
	  usage_error("Not enough arguments.");
     else if (argc - optind > 1)
	  usage_error("Too many arguments.");

     @<Open input file@>@;
     @<Open output file@>@;

     @<Initialize locus variables@>@;

     exit(convertor());
}
	  
	  

