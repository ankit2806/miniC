%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"

int scope=0;
int max_scope=0;

void inc(int *j)
{
	(*j)++;
}

void dec(int *j)
{
	(*j)--;
}

%}
	
A		[a-zA-Z_]
N		[0-9]
E		[Ee][+-]?{N}+

%%

[ \t\n]+

("//")(\\.|[^\'\n'])*					printf("COMMENT\n");
\/\*([^\*]|[\r\n]|(\*+([^\*\/]|[\r\n])))*\*+\/	 printf("MULTI_COMMENT\n");


"if"		return (IF);
"else"		return(ELSE);
"while"		return(WHILE);
"for"		return(FOR);
"do"		return(DO);
"int"		return(INT);
"main"		return(MAIN);
"break"		return(BREAK);
"case"		return(CASE);
"char"		return(CHAR);
"continue"	return(CONTINUE);
"default"	return(DEFAULT);
"return"	return(RETURN);
"switch"	return(SWITCH);
"void"		return(VOID);

{N}+					{ yylval.num=atoi(yytext);			//Integers
					  return Int;
					  }	 

{A}({A}|{N})*				{  yylval.id=strdup(yytext);		//Identifiers
					   return ID;
					   }

{A}?'(\\.|[^\\'])+'			{ yylval.id=strdup(yytext);		//Character constants
					  return CHAR_CONSTNT;
					  }

{A}?\"(\\.|[^\\"])*\" 			{ yylval.id=strdup(yytext);		//String constants
					  return STRNG;
					  }

"+"		return('+');
"-"		return('-');
"/"		return('/');
"*"		return('*');
"^"		return('^');
"%"		return('%');

"("		return('(');
")"		return(')');
"["		return('[');
"]"		return(']');
"{"		{inc(&scope); if(scope>max_scope) max_scope=scope; return('{');}
"}"		{dec(&scope); return('}');}

"."		return('.');
"!"		return('!');
"~"		return('~');

"<"		return('<');
">"		return('>');
"<="		return(OP_LE);
">="		return(OP_GE);
"=="		return(OP_EQ);
"!="		return(OP_NOT);

"="		return('=');
"+="		return(ASGN_ADD);
"-="		return(ASGN_SUB);
"*="		return(ASGN_MUL);
"/="		return(ASGN_DIV);
"%="		return(ASGN_MOD);
"^="		return(ASGN_XOR);

","		return(',');
";"		return(';');
":"		return(':');

%%

int yywrap(void)
{
	return(1);
}
