# This file is part of MIX
# Copyright (C) 2005, 2007 Sergey Poznyakoff
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

info_TEXINFOS=mix.texi
mix_TEXINFOS=macros.texi

EXTRA_DIST = \
 gendocs_template\
 gendocs.sh\
 mixal.1\
 mixsim.1\
 mixal.man\
 mixsim.man\
 manpage.inc

clean-local:
	rm -rf manual

GENDOCS=${top_srcdir}/doc/gendocs.sh

TEXI2DVI=texi2dvi -t '@set $(RENDITION)' -E

# Make sure you set TEXINPUTS.
# TEXINPUTS=/usr/share/texmf/pdftex/plain/misc/ is ok for most distributions
manual:
	TEXINPUTS=$(srcdir):$(top_srcdir)/build-aux:$(TEXINPUTS) \
	 MAKEINFO="$(MAKEINFO) $(MAKEINFOFLAGS)" \
	 TEXI2DVI="$(TEXI2DVI) -t @finalout" \
	 $(GENDOCS) $(PACKAGE) '$(PACKAGE_NAME) manual'

# Man pages

man_MANS=mixal.1 mixsim.1

SUFFIXES = .man .1

.man.1:
	soelim $< > $@

mixal.1:  mixal.man manpage.inc
mixsim.1:  mixsim.man manpage.inc