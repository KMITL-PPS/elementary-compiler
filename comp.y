%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void yyerror(char *s);
int yyparse();
int yylex(void);
void push(int);
void pop(int);
int* getRegister(int);
void load(int, int);

typedef struct node {
	int value;
	struct node* back;
} node_t;

#define REG_TOP 27
#define REG_A 0
#define REG_Z 25

int errors = 0;
int reg[26] = {0}, acc = 0, size = 0;
node_t *top = NULL;
%}

%start  				input

%token  				CONSTANT REG ACCUMULATOR PUSH POP TOP SIZE SHOW LOAD

%left   				AND OR
%left   				'+' '-'
%left   				'*' '/' '\\'
%right					NOT
%precedence				NEG
%right					'^'

%%

input:
  %empty				{ }
| input line			{
							printf("> ");
							errors = 0;
						}
| input error line		{
							// yyclearin;
							// yyerrok;
							errors = 0;
							YYABORT;
						}
;

line:
  '\n'
| exp '\n'  			{
							if (errors == 0)
							{
								acc = $1;
								printf("= %d\n", $1);
							}
							errors = 0;
						}
| regop '\n'			{ }
;

exp:
  CONSTANT				{ $$ = $1;           						}
| REG					{
							if ($1 == REG_TOP && size <= 0)
							{
								yyerror("stack is empty");
								// errors++;
								YYACCEPT;
							}
							else
							{
								$$ = *getRegister($1);
							}
						}
| exp AND exp			{ $$ = $1 & $3;								}
| exp OR exp			{ $$ = $1 | $3;								}
| exp '+' exp			{ $$ = $1 + $3;     						}
| exp '-' exp			{ $$ = $1 - $3;      						}
| exp '*' exp			{ $$ = $1 * $3;      						}
| exp '/' exp			{
	   						if ($3)
								$$ = $1 / $3;
	   						else
							{
								yyerror("division by zero");
								YYABORT;
							}
	 					}
| exp '\\' exp			{
	   						if ($3)
								$$ = $1 % $3;
	   						else
							{
								yyerror("modulo by zero");
								YYABORT;
							}
	 					}
| NOT exp				{ $$ = ~$2;									}
| '-' exp  %prec NEG	{ $$ = -$2;          						}
| '+' exp				{
							yyerror("syntax error");
							YYERROR;
						}
| exp '^' exp			{ $$ = pow($1, $3);     					}
| '(' exp ')'			{ $$ = $2;           						}
;

regop:
  SHOW REG				{
	  						if ($2 == REG_TOP && size <= 0)
							{
								yyerror("stack is empty");
								errors = 0;
							}
							else
							{
								printf("= %d\n", *getRegister($2));
							}
						}
| LOAD REG REG			{
							if ($3 >= REG_A && $3 <= REG_Z)
								if ($2 == REG_TOP && size <= 0)
								{
									yyerror("stack is empty");
									errors = 0;
								}
								else
									load($2, $3);
							else
							{
								yyerror("destination register is read-only");
								errors = 0;
							}
						}
| PUSH REG				{
	  						if ($2 == REG_TOP && size <= 0)
							{
								yyerror("stack is empty");
								errors = 0;
							}
							else
							{
								push($2);
							}
						}
| POP REG				{
							if ($2 >= REG_A && $2 <= REG_Z)
								if (size > 0)
									pop($2);
								else
								{
									yyerror("stack is empty");
									errors = 0;
								}
							else
							{
								yyerror("destination register is read-only");
								errors = 0;
							}
						}
;

%%

void yyerror(char *s)
{
	fprintf(stderr, "! ERROR: %s\n", s);
	errors++;
}

void push(int i)
{
	node_t *tmp = (node_t *) malloc(sizeof(node_t));
	tmp->value = *getRegister(i);
	tmp->back = top;
	top = tmp;
	size++;
}

void pop(int i)
{
	node_t *tmp = top;
	*getRegister(i) = tmp->value;
	top = tmp->back;
	free(tmp);
	size--;
}

int* getRegister(int i)
{
	if (i >= 0 && i <= 25)
	{
		return &reg[i];
	}
	else if (i == 26)
	{
		return &acc;
	}
	else if (i == 27)
	{
		return &(top->value);
	}
	else if (i == 28)
	{
		return &size;
	}
	else	// ERROR
	{
		return 0;
	}
}

void load(int src, int dest)
{
	*getRegister(dest) = *getRegister(src);
}