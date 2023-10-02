# Create MIX opcode tables from mixal.optab
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

BEGIN {
    abind = 0
    lastop=-1
    MIXCHARSET=" ABCDEFGHInJKLMNOPQRepSTUVWXYZ0123456789.,()+-*/=$<>@@;:'abcdfghi"	 
}

/^#.*/ { next }

NF>=3 {
        if ($1 > lastop)
	    lastop = $1
		
	rab[abind] = $2
        # flg[abind] = $3
        opc[abind] = $1
	count[ $1 ] ++
        if (match($3, "[0-9]:[0-9]")) {
	    L = substr($3, 1, 1)+0
	    R = substr($3, 3, 1)+0
	    def[ abind ] = 8*L + R
            fld[ abind ] = 1
	} else {
	    def[ abind ] = $3+0
	    fld[ abind ] = 0
	}
	abind++
}

END {
     opcode_comment = "@ \\.{MIXAL} table. Each row consists of following elements:\
\n\
\\tabskip=1em \\halign{\
 \\strut\\sc#\\hfil&\\strut{\\raggedright#}\\cr\n\
OP & Opcode mnemonics\\cr\n\
(F) & Default field specification\\cr\n\
C  & \\.{MIX} operation code\\cr\n\
FLD & Field notation type. |0| means |(n)|, |1| means |(L:R)|\\cr}"

     dd_comment = "@ The following two tables are used when disassembling \\.{MIX} code.\n\
Let |C| be the operation code read from the input program,\n\
|F| be the field specification and |I| be the index of |mix_optab| entry,\n\
describing the instruction in question.\n\
Then, |I = dd_ent[C]|, if |dd_cnt[C] == 1|. Otherwise, if |F < dd_cnt[C]|,\n\
|I = dd_ent[C] + F|."
     print "% This file is generated automatically. Please do not edit"
     print "@* OPTAB FOR MIXAL."
     print "@c" 	  
     print "#include \"mix.h\""
     print ""
     print "@ \\.{MIX} character set."
     print "@c"	  
     print "char mixalf[] = "
     print "  \"" MIXCHARSET "\";"
     print opcode_comment 	  
     print "@c"
     print "struct mix_op mix_optab[] = {@/";	   
     for (n = 0; n < abind; n++) {
	  printf("@t\\hskip 5em@>{ %6s, %4d, %4d, %4d },@/\n", "\"" rab[n] "\"" , def[n], opc[n], fld[n]);
     }
     print "};"
     print "int op_count = sizeof(mix_optab)/sizeof(mix_optab[0]);"
     print ""
     print dd_comment
     print ""	  
     print "@ count"
     print "@c"
     printf "int dd_cnt[] = {"
     elcnt = 0
     ind = 0
     for (n = 0; n <= lastop; n++) {
	if (elcnt++ % 10 == 0)
	    printf "@/\n\t@t\\hskip 5em@>"
        printf "%4d, ", count[n]
	entry[n] = ind
        ind += count[n]
     }
     printf "@/\n};\n";

     print "@ entry points."
     print "@c"	  
     printf "int dd_ent[] = {"
     elcnt = 0;
     for (n = 0; n <= lastop; n++) {
	if (elcnt++ % 10 == 0)
	    printf "@/\n\t@t\\hskip 5em@>"
        printf "%4d, ", entry[n]
     }
     printf "@/\n};\n";
}








