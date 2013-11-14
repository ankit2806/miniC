#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct symtab{
	char *name;
	char *type;
	int sze;
	int scpe;
	struct symtab *next;
	};

typedef struct symtab symtab;

symtab *sym_table=(symtab*)0;

symtab *addToSymTab(char *typ,char *sym_name,int size,int scope)
{
	symtab *ptr;
	ptr=(symtab*)malloc(sizeof(symtab));
	ptr->name=(char*)malloc(strlen(sym_name)+1);
	strcpy(ptr->name,sym_name);
	ptr->scpe=scope;
	ptr->sze=size;
	ptr->type=typ;
	printf("Identifier: %s   Type: %s   Size: %d   Scope: %d\n\n",ptr->name,ptr->type,ptr->sze,ptr->scpe);
	ptr->next=(struct symtab*)sym_table;
	sym_table=ptr;
	return ptr;
}

symtab *getFromSymTab(char *sym_name,int scope)
{
	symtab *ptr;
	for(ptr=sym_table;ptr!=(symtab*)0;ptr=(symtab*)ptr->next)
		if(strcmp(ptr->name,sym_name)==0 && ptr->scpe==scope){
		
			return ptr;}
	
	return 0;
}

