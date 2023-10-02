#                                               -*- Autoconf -*-
# Copyright (C) 2000, 2005, 2007 Sergey Poznyakoff
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3, or (at
# your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

AC_PREREQ(2.59)
AC_INIT([mix], [2.0], [gray@gnu.org.ua])
AC_CONFIG_SRCDIR([src/mixsim.w])
AC_CONFIG_AUX_DIR([build-aux])
AC_CONFIG_HEADER([config.h])
AM_INIT_AUTOMAKE
	
# Checks for programs.
AC_PROG_AWK
gl_EARLY	
AC_PROG_CC
AC_PROG_LEX
AC_PROG_YACC
	
# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([fcntl.h stdlib.h string.h strings.h unistd.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_TYPE_SIGNAL
	
# Checks for library functions.
gl_INIT  
AC_TYPE_SIGNAL
AC_CHECK_FUNCS([memset strcasecmp strchr strrchr strtol])

# Special features
AC_SUBST(INDENT)
INDENT=:	
AC_ARG_WITH([indent],
	    AC_HELP_STRING([--with-indent],
	                   [preprocess ctangle output with indent, if it is available. Do not use this option, unless you are maintaining MIX sources *and* want to fiddle with ctangle output.]),
            [case "${withval}" in
	     yes) AC_CHECK_PROG([INDENT],[indent],[indent],[:]);;
	     no)  ;;
	     esac])
	     
# Special features
AC_ARG_WITH([readline],
            AC_HELP_STRING([--without-readline],
	                   [do not use readline]),
                           [case "${withval}" in
			    yes) usereadline=yes ;;
		            no)  usereadline=no ;;
                            *)   AC_MSG_ERROR(bad value ${withval} for --without-readline) ;;
			    esac],[usereadline=yes])

if test "$usereadline" = "yes"; then
  dnl FIXME This should only link in the curses libraries if it's
  dnl really needed!

  dnl Check for Curses libs.
  for lib in ncurses curses termcap
  do
     AC_CHECK_LIB($lib, tputs, [CURSES_LIBS="-l$lib"; break])
  done
	      
  saved_LIBS=$LIBS
  LIBS="$LIBS $CURSES_LIBS"
  AC_CHECK_LIB(readline, readline, mix_have_readline=yes)
  LIBS=$saved_LIBS

  if test x"$mix_have_readline" = x"yes"; then
    AC_CHECK_HEADERS([readline/readline.h],
                     AC_DEFINE(WITH_READLINE,1,[Enable use of readline]))
                     READLINE_LIBS="-lreadline $CURSES_LIBS"
                     saved_LIBS=$LIBS
                     LIBS="$LIBS $READLINE_LIBS"
                     AC_CHECK_FUNCS(rl_completion_matches)
                     LIBS=$saved_LIBS
    else
      AC_MSG_WARN(readline requested but does not seem to be installed)
    fi
fi
AH_BOTTOM([
/* Newer versions of readline have rl_completion_matches */
#ifndef HAVE_RL_COMPLETION_MATCHES
# define rl_completion_matches completion_matches
#endif])

AC_SUBST(READLINE_LIBS)

### Check for Emacs site-lisp directory
AM_PATH_LISPDIR
if test "$EMACS" != "no"; then
	lisp_LISP='$(LISPSRC)'
fi
AC_SUBST(lisp_LISP)

### Initialize the test suite.
AC_CONFIG_TESTDIR(tests)
AC_CONFIG_FILES([tests/Makefile tests/atlocal]) 
AM_MISSING_PROG([AUTOM4TE], [autom4te])
			       
AC_CONFIG_FILES([Makefile
	 yfmt/Makefile
	 lib/Makefile
	 gnu/Makefile
	 src/Makefile
	 elisp/Makefile
	 examples/Makefile
	 doc/Makefile])
	 
AC_OUTPUT
