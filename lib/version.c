/*1:*/
#line 18 "./version.w"

#include <config.h> 

/*:1*//*2:*/
#line 22 "./version.w"

void
mix_version(const char*progname)
{
printf("%s (%s)\n",progname,PACKAGE_STRING);
printf("Copyright (C) 1998,1999,2000,2005,2007 Douglas Laing, Sergey Poznyakoff\n");
printf("License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>\n");
printf("This is free software: you are free to change and redistribute it.\n");
printf("There is NO WARRANTY, to the extent permitted by law.\n");
}/*:2*/
