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

bin_PROGRAMS = mixal mixsim
bin_SCRIPTS = mixrun
mixal_SOURCES = mixal.y lex.l symbol.c optab.c
mixsim_SOURCES = mixsim.c mixterm.c optab.c
noinst_HEADERS = mix.h mixsim.h mixasm.h mixsim.h

INCLUDES = -I../gnu -I${top_srcdir}/gnu
LDADD = ../lib/libmix.a ../gnu/libgnu.a
mixsim_LDADD = $(LDADD) $(READLINE_LIBS)

BUILT_SOURCES = mix.h mixasm.h mixsim.h mixsim.c mixterm.c symbol.c optab.c mixal.y lex.l

AM_YFLAGS = -dtv
AM_LFLAGS = -d

WEBFILES1=mix.hw mixsim.hw mixasm.hw
WEBFILES2=mixsim.w mixterm.w symbol.w optab.w
WEBFILES=$(WEBFILES1) $(WEBFILES2) mixal.yw lex.lw


## Fake configure into including srcdir to VPATH:
s=${srcdir}
VPATH = $(s)
optab.w: ${srcdir}/mixal.optab ${srcdir}/optab.awk 
	$(AWK) -f $(srcdir)/optab.awk ${srcdir}/mixal.optab > optab.w

EXTRA_DIST = mixal.h optab.awk mixal.optab $(WEBFILES) $(DOCS) mixrun

DOCS = \
 $(WEBFILES1:.hw=.tex)\
 $(WEBFILES1:.hw=.idx)\
 $(WEBFILES1:.hw=.scn)\
 $(WEBFILES2:.w=.tex)\
 $(WEBFILES2:.w=.idx)\
 $(WEBFILES2:.w=.scn)\
 mixal.tex\
 mixal.idx\
 mixal.scn\
 lex.tex\
 lex.idx\
 lex.scn

CLEANFILES = *.log *.pdf *.toc
DISTCLEANFILES = $(DOCS:.tex=.pdf)
MAINTAINERCLEANFILES = $(DOCS)

tex: $(DOCS)

pdf: $(DOCS:.tex=.pdf)

CTANGLE=${SHELL} `cd $(top_srcdir)/build-aux; pwd`/missing --run ctangle
CWEAVE=${SHELL} `cd $(top_srcdir)/build-aux; pwd`/missing --run cweave

SUFFIXES = .w .tex .dvi .pdf

mixal.h mixal.c: mixal.yw
lex.o: lex.c mixal.h

.w.c:
	ctangle $<
	$(INDENT) -kr -psl $@

.hw.h:
	ctangle $< - $@

.yw.y:
	ctangle $< - $@-t
	../yfmt/yfmt -o $@ $@-t
	rm $@-t

.lw.l: 
	ctangle $< - $@-t
	../yfmt/yfmt -o $@ $@-t
	rm $@-t

.w.tex:
	cweave $<

.hw.tex:
	cweave $<

.lw.tex:
	cweave $<

.yw.tex:
	cweave $<

.tex.dvi:
	tex $<

.dvi.pdf:
	dvipdf $<
