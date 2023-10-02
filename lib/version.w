% This file is part of MIX
% Copyright (C) 2007 Sergey Poznyakoff
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License as
% published by the Free Software Foundation; either version 3, or (at
% your option) any later version.
%
% This program is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
% General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

@
@c
#include <config.h>

@
@c
void
mix_version(const char *progname)
{
     printf("%s (%s)\n", progname, PACKAGE_STRING);
     printf("Copyright (C) 1998,1999,2000,2005,2007 Douglas Laing, Sergey Poznyakoff\n");
     printf("License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>\n");
     printf("This is free software: you are free to change and redistribute it.\n");
     printf("There is NO WARRANTY, to the extent permitted by law.\n");
}
