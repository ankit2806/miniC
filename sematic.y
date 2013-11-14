//max_scope: the largest value of scope used previously in the program

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symbol.c"

int yydebug=1;
int scope,max_scope;
int errors=0;
char *tt;

mySymTab(char *type,char *sym_name,int size,int scope)
{
	symtab *s;
	s=getFromSymTab(sym_name,scope);
	if(s==0)
		s=addToSymTab(type,sym_name,size,scope);
	else
		printf("Identifier: %s is previously declared in scope: %d\n",sym_name,s->scpe);
	}

context_check(char *sym_name,int scope)
{
	symtab *s;
	s=getFromSymTab(sym_name, scope);
	if(s!=0)
	{
	}
	else
	{
		errors++;
		printf("%s is undeclared identifier!!!\n",sym_name);
		
	}
}

%}

%union{
	char *id;
	int num;
	struct decl{
		int n;
		double d;
		char *c;
		char *typ;
		}myst;
}

%token <id> ID CHAR_CONSTNT STRNG 
%token <num> Int
%token IF ELSE WHILE FOR BREAK CASE CHAR MAIN DO
%token CONTINUE DEFAULT
%token SWITCH VOID INT Error RETURN
%token  OP_INC OP_DEC OP_BITLFT OP_BITRHT OP_LE OP_GE OP_EQ OP_NOT OP_LAND OP_LOR
%token ASGN_RHT ASGN_LFT ASGN_ADD ASGN_SUB ASGN_MUL ASGN_DIV ASGN_MOD ASGN_AND ASGN_XOR ASGN_OR 

%type <myst> Type 
%type <myst> Expr Op_assign Op_if Op_or Op_and Op_pow Op_equate Op_compare Op_add Op_mult Value

%left '+' '-'
%left '*' '/' '%'
%right '^'

%start Decls

%%

Decls : Decl Decls
      |
      ;

Decl  : Func_decl 				
      | Func_proto 			
      | Var_decl 				
      ;
          
Func_proto : Func_id '(' Types  ')' ';' 
           | Func_id '(' Params ')' ';'
           | Func_id '(' ')' ';'
           ;

Func_decl  : Func_id '(' Params  ')' Block	{scope=max_scope; inc(&scope);}
           | Func_id '(' ')' Block 		{scope=max_scope; inc(&scope);}
           ;


Params     : Param ',' Params
           | Param
           ;
               
Param      : Type ID				{ mySymTab($1.typ,$<id>2,0,scope+1);}
           ;
               
Types      : Type  ',' Types			
           | Type 				
           ;

Func_id    : Type MAIN				{ FILE *fp;fp=fopen("abc.txt","w+");fprintf(fp,"%s","main");}
           | Type ID				{ mySymTab($1.typ,$<id>2,0,scope);}
           ;
 
Var_decl   : Type ID  ';'			{ mySymTab($1.typ,$<id>2,0,scope);printf("kjsokfjsojof=====%s\n",$<id>2);}
	   | Type ID '[' Expr ']' ';'		{ mySymTab($1.typ,$<id>2,$4.n,scope);}
           ;

Type     : CHAR					{ $$.typ="Char";}
         | INT					{ $$.typ="Int";} 
         ;

Stm      : Var_decl
         | IF '(' Expr ')' Stm          
         | IF '(' Expr ')' Then_stm ELSE Stm         
         | WHILE '(' Expr ')' Stm 
         | FOR '(' Arg ';' Arg ';' Arg ')' Stm
         | Normal_stm
         ;

Then_stm   : IF '(' Expr ')' Then_stm ELSE Then_stm 
           | WHILE '(' Expr ')' Then_stm 
           | FOR '(' Arg ';' Arg ';' Arg ')' Then_stm
           | Normal_stm
           ;

Normal_stm : DO Stm WHILE '(' Expr ')'
           | SWITCH '(' Expr ')' '{' Case_stms '}'
           | Block
           | Expr ';'   
           | BREAK ';'
           | CONTINUE ';'
           | RETURN Expr ';'
           | ';'              
           ;

Arg       : Expr 
          | 
          ;

Case_stms : CASE Value ':' Stm_list Case_stms
          | DEFAULT ':' Stm_list                  
          |
          ;

Block     : '{' Stm_list '}'
	  ;
	      
Stm_list  :  Stm Stm_list 
          | 
          ;

Expr       : Expr ',' Op_assign   
           | Op_assign				{ $$ = $1 }
           ;

Op_assign  : Op_if '='   Op_assign		{ $$ = $1 = $3; }
           | Op_if ASGN_ADD  Op_assign		{ $1.n  = $1.n + $3.n; $$.n = $1.n; }
           | Op_if ASGN_SUB  Op_assign		{ $1.n = $1.n - $3.n; $$.n = $1.n }
           | Op_if ASGN_MUL  Op_assign		{ $$.n = $1.n * $3.n; $$.n = $1.n }
           | Op_if ASGN_DIV  Op_assign		{ $$.n = $1.n / $3.n; $$.n = $1.n }
           | Op_if ASGN_XOR  Op_assign		//{ $$.n = $1.n ^ $3.n; $$.n = $1.n }
           | Op_if				{ $$ = $1 }
           ;

Op_if      : Op_or '?' Op_if ':' Op_if
           | Op_or				{ $$ = $1 }
           ;

Op_or      : Op_or OP_LOR Op_and		
           | Op_and				{ $$ = $1 }
           ;

Op_and     : Op_and OP_LAND Op_pow		
           | Op_pow				{ $$ = $1 }
           ;

Op_pow     : Op_pow '^' Op_equate		//{ $$.n = pow($1.n,$3.n); printf("cdskcs===%d\n",$$.n); }
           | Op_equate				{ $$ = $1 }
           ;

Op_equate  : Op_equate OP_EQ Op_compare		
           | Op_equate OP_NOT Op_compare	
           | Op_compare				{ $$ = $1 }
           ;

Op_compare : Op_compare '<'  Op_add		
           | Op_compare '>'  Op_add		
           | Op_compare OP_LE Op_add		
           | Op_compare OP_GE Op_add		
           | Op_add				{ $$ = $1 }
           ;

Op_add     : Op_add '+' Op_mult			{ $$.n = $1.n + $3.n; printf("%d + %d = %d \n",$1.n,$3.n,$$.n);}
           | Op_add '-' Op_mult			{ $$.n = $1.n - $3.n; printf("%d - %d = %d \n",$1.n,$3.n,$$.n);}
           | Op_mult				{ $$ = $1 }
           ;

Op_mult    : Op_mult '*' Value			{ $$.n = $1.n * $3.n; printf("%d * %d = %d \n",$1.n,$3.n,$$.n);}
           | Op_mult '/' Value			{ $$.n = $1.n / $3.n; printf("%d / %d = %d \n",$1.n,$3.n,$$.n);}
           | Op_mult '%' Value			{ $$.n = $1.n % $3.n; printf("%d % %d = %d \n",$1.n,$3.n,$$.n);}
           | Value				{ $$ = $1; }
           ;

Value      : Int				{ $$.n=$<num>1;}
           | STRNG				{ $$.c=$<id>1;}
           | CHAR_CONSTNT			{ $$.c=$<id>1;}
           | ID '(' Expr ')'			{ context_check($<id>1,scope); $$.n=$<num>3; $$.c=$<id>1;}	//function call
           | ID '(' ')'          		{ context_check($<id>1,scope);}
           | ID					{ context_check($<id>1,scope);}
           | '(' Expr ')'			{ $$.n=$<num>2; $$.c=$<id>2;}
           ;
%%


extern char* yytext[];

extern void yyerror(char *s)
{
fprintf(stderr,"%s\n",s);
return;
}

void main(int argc, char **argv)
{

extern FILE *yyin;
yyin=fopen(argv[1],"r");
yyparse();
return;
}
