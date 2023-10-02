%a 4000
%e 4000
%p 4000
%{
#line 30 "./lex.lw"
#ifdef HAVE_CONFIG_H
#include <config.h> 
#endif
#include <mixasm.h> 
#include <mixal.h> 
#include <string.h> 
#include <ctype.h> 

/*:2*//*3:*/
#line 38 "./lex.lw"


char label[11]= " ";

/*:3*//*4:*/
#line 46 "./lex.lw"


static char*
copy_alf(char*ptr,int size)
{
int i;
for(i= 0;i<size;i++)
yylval.literal[i]= ptr[i];
for(;i<sizeof(yylval.literal)-1;i++)
yylval.literal[i]= ' ';
yylval.literal[i]= 0;
return yylval.literal;
}

/*:4*//*5:*/
#line 80 "./lex.lw"


int local_num[10]= {1,1,1,1,1,1,1,1,1,1};

/*:5*//*7:*/
#line 86 "./lex.lw"


static char*
localname(int n,int bias)
{
static char name[64];
sprintf(name,"|%d-%d|",n,local_num[n]+bias);
return name;
}

/*:7*//*8:*/
#line 96 "./lex.lw"


%}

	/*:8*//*9:*/

symbol [A-Z0-9]*[A-Z][A-Z0-9]*
pseudo EQU|ORIG|CON|END
number [0-9]+
asterisk \*
slashes \/\/

	/*:9*//*10:*/

%s COMMENT
%s OP
%s ADDRESS

	/*:10*//*12:*/

%%
	/*:12*//*13:*/
^{symbol} 	{
#line 123 "./lex.lw"
	if(strlen(yytext)> 10){
	yyerror("Symbol longer than 10 characters");
	yytext[10]= '\0';
	}
	if(localref(yytext,"H")){
	char*name= localname(yytext[0]-'0',0);
	local_num[yytext[0]-'0']++;
	if(!(yylval.symp= lookup(name))){
	yylval.symp= install(name,0,0);
	yylval.symp->type= DEF;
	}
	}else if((yylval.symp= lookup(yytext))){
	if(yylval.symp->type!=UNDEF)
	parse_error("duplicate symbol: %s",yytext);
	}else{
	yylval.symp= install(yytext,0,0);
	yylval.symp->type= UNDEF;
	}
	strcpy(label,yytext);
	return LOC;
	}
	/*:13*//*14:*/
^\*       	{
#line 147 "./lex.lw"
	BEGIN(COMMENT);tlist("*");return ASTERISK;}
	/*:14*//*15:*/
<COMMENT>[^\n]* 	{
#line 152 "./lex.lw"
	yylval.txt= yytext;
	tlist("%s",yytext);
	return TEXT;
	}
	/*:15*//*16:*/
<COMMENT>\n 	{
#line 160 "./lex.lw"
	BEGIN(INITIAL);
	tlist("\n");
	return yytext[0];
	}
	/*:16*//*17:*/
<INITIAL>[ \t]+ 	{
#line 168 "./lex.lw"
	tlist("%-10s ",label);
	strcpy(label," ");
	BEGIN(OP);
	}
	/*:17*//*18:*/
<OP>{pseudo} 	{
#line 176 "./lex.lw"
	strcpy(yylval.literal,yytext);
	tlist("%-4s ",yytext);
	return PSEUDO;
	}
	/*:18*//*19:*/
<OP>{symbol} 	{
#line 184 "./lex.lw"
	yylval.opcode= lookup_op(yytext);
	if(!yylval.opcode){
	yyerror("Invalid op code");
	return BOGUS;
	}
	tlist("%-4s ",yytext);
	return OPCODE;
	}
	/*:19*//*20:*/
<OP>ALF[ ][^\n]+/\n 	{
#line 196 "./lex.lw"
	int i= (yytext[4]==' ')?5:4;
	int length= yyleng-i;
	char*s;
	if(length> 5){
	if(isspace(yytext[i]))
	warning("Literal sequence too long (Too many spaces after ALF?)",
	NULL);
	else
	warning("Literal sequence too long",NULL);
	length= 5;
	}
	s= copy_alf(yytext+i,length);
	tlist("ALF  %s",s);
	BEGIN(COMMENT);
	return ALF;
	}
	/*:20*//*21:*/
<OP>[ \t]+ 	{
#line 216 "./lex.lw"
	BEGIN(ADDRESS);}
	/*:21*//*22:*/
<OP>[^ \t\n]+ 	{
#line 220 "./lex.lw"
	yyerror("Invalid op code");}
	/*:22*//*23:*/
<ADDRESS>{symbol} 	{
#line 225 "./lex.lw"
	if(strlen(yytext)> 10){
	yyerror("Symbol longer than 10 characters");
	yytext[10]= '\0';
	}
	tlist("%s",yytext);
	if(localref(yytext,"B")){
	char*name= localname(yytext[0]-'0',-1);
	if(!(yylval.symp= lookup(name))){
	yyerror("missing backward 'here'");
	yylval.symp= install(name,0,0);
	yylval.symp->type= UNDEF;
	local_num[yytext[0]-'0']++;
	}
	return LOCAL_SYMBOL;
	}else if(localref(yytext,"F")){
	char*name= localname(yytext[0]-'0',0);
	if(!(yylval.symp= lookup(name))){
	yylval.symp= install(name,0,0);
	yylval.symp->type= UNDEF;
	}
	return FUTURE_REFERENCE;
	}else if(!(yylval.symp= lookup(yytext))){
	yylval.symp= install(yytext,0,0);
	yylval.symp->type= UNDEF;
	return FUTURE_REFERENCE;
	}else if(yylval.symp->type==UNDEF)
	return FUTURE_REFERENCE;
	else
	return DEFINED_SYMBOL;
	}
	/*:23*//*24:*/
<ADDRESS>{number}   	{
#line 260 "./lex.lw"
	if(strlen(yytext)> 10){
	yyerror("Number greater than 10 digits");
	yytext[10]= '\0';
	}
	tlist("%s",yytext);
	yylval.val= atoi(yytext);
	if(yylval.val> 1073741823)
	yyerror("Number greater than 1073741823");
	return NUMBER;
	}
	/*:24*//*25:*/
<ADDRESS>{asterisk} 	{
#line 273 "./lex.lw"
	tlist("*");return ASTERISK;}
	/*:25*//*26:*/
<ADDRESS>{slashes}  	{
#line 277 "./lex.lw"
	tlist("//");return SLASHES;}
	/*:26*//*27:*/
<ADDRESS>[^ \t\n] 	{
#line 281 "./lex.lw"
	tlist("%c",*yytext);return yytext[0];}
	/*:27*//*28:*/
<ADDRESS>[ \t]*  	{
#line 285 "./lex.lw"
	tlist("%s",yytext);BEGIN(COMMENT);}
	/*:28*//*29:*/
<ADDRESS>[\n] 	{
#line 289 "./lex.lw"
	BEGIN(INITIAL);tlist("\n");return yytext[0];}
	/*:29*//*30:*/
[ \t\n]       	{
#line 293 "./lex.lw"
	BEGIN(INITIAL);tlist("%c",yytext[0]);return yytext[0];}
	/*:30*//*31:*/
.	        	{
#line 297 "./lex.lw"
	parse_error("invalid input:",yytext);}
	/*:31*//*32:*/
%%
#line 302 "./lex.lw"

/*:32*//*33:*/
#line 304 "./lex.lw"


int
yywrap()
{
return 1;
}

/*:33*//*34:*/
#line 312 "./lex.lw"


void
init_lex(FILE*fp,int debug)
{
#ifdef FLEX_DEBUG
yy_flex_debug= debug;
#endif
yyin= fp;
}

/*:34*//*35:*/
#line 323 "./lex.lw"


void
reset_lex()
{
BEGIN(INITIAL);
}

/*:35*/
