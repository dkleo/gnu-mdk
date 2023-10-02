# Copyright (C) 2005, 2007 Sergey Poznyakoff
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

noinst_PROGRAMS = yfmt

BUILT_SOURCES = yfmt.c
WEBFILES=yfmt.w
EXTRA_DIST = $(WEBFILES) $(DOCS)
DOCS = $(WEBFILES:.w=.tex) $(WEBFILES:.w=.idx) $(WEBFILES:.w=.scn)
CLEANFILES = *.log *.pdf *.toc
DISTCLEANFILES = $(DOCS:.tex=.pdf)
MAINTAINERCLEANFILES = $(DOCS)

tex: $(DOCS)

pdf: $(DOCS:.tex=.pdf)

SUFFIXES = .w .tex .dvi .pdf

.w.c:
	ctangle $<
	$(INDENT) -kr -psl $@

.w.tex:
	cweave $<

.tex.dvi:
	tex $<

.dvi.pdf:
	dvipdf $<
