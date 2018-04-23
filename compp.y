%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>



#define REG_TOP 27
#define REG_A 0
#define REG_Z 25
int errors = 0;
int reg[26] = {0}, acc = 0, size = 0;

%}

%start					input

%token					CONSTANT RIGHT_ARROW TEXT

%%

input:
	%empty			{}
| input line			{
					printf("> ");
					errors = 0;
				}
;
line:
	'\n'
|exp '\n'
|exp RIGHT_ARROW '\n'		{
					printf("%s",$1);		
				}
;
exp:
	TEXT			{ $$ = $1};








































