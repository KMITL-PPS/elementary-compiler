
%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void yyerror(char *);
void create_block(int);
int is_if_block();

extern FILE *fp;

typedef struct block {
    struct block *back;

    int type;               // 0 = if, 1 = else, 2 = repeat
    int id;
    // int right;
} block_t;

// register $A - $z
// TODO: remove this when convert to asm
int reg[52] = {0};

int indent_level = 0;
block_t *blocks = NULL;
int cond_id = 0, loop_id = 0;

%}

%union {
    int i;
    char *s;
}

%start file

%token <i>  CONSTANT REG CMP
%token <s>  TEXT NL
%token      LEFT_ARROW RIGHT_ARROW IF ELSE REPEAT DOUBLE_QUOTE TAB
%token      END_OF_FILE 0

%type <i>   exp hex tab
%type <s>   text statement assignexp printexp specexp

%left                                   '+' '-'
%left                                   '*' '/' '%'
%precedence                             NEG
%right                                  '^'

%%

file:
  line END_OF_FILE
;

line:
  %empty
| tab statement
| line NL tab statement                 {}
| line error NL tab statement           {
                                            YYABORT;
                                        }
;

tab:
  %empty                                { $$ = 0;                                       }
| tab TAB                               { $$ = $1 + 1;                                  }
;

statement:
  exp                                   { printf("EXP: %d\n", $1);                      }
| assignexp
| printexp
| specexp
;

text:
  %empty                                { $$ = 0;                                       }
| DOUBLE_QUOTE TEXT DOUBLE_QUOTE        { $$ = $2;                                      }
;

hex:
  %empty                                { $$ = 0;                                       }
| '#'                                   { $$ = 1;                                       }
;

exp:
  CONSTANT
| REG                                   { $$ = reg[$1];                                 }
| exp '+' exp                           { $$ = $1 + $3;                                 }
| exp '-' exp                           { $$ = $1 - $3;                                 }
| exp '*' exp                           { $$ = $1 * $3;                                 }
| exp '/' exp                           {
                                            if ($3)
                                                $$ = $1 / $3;
                                            else {
                                                yyerror("division by zero");
                                                YYABORT;
                                            }
                                        }
| exp '%' exp                           {
                                            if ($3)
                                                $$ = $1 % $3;
                                            else {
                                                yyerror("modulo by zero");
                                                YYABORT;
                                            }
                                        }
| '-' exp  %prec NEG                    { $$ = -$2;                                     }
| '+' exp                               {
                                            yyerror("syntax error");
                                            YYERROR;
                                        }
| exp '^' exp                           { $$ = pow($1, $3);                             }
| '(' exp ')'                           { $$ = $2;                                      }
;

printexp:
  exp RIGHT_ARROW hex                   {
                                            if ($3) {
                                                printf("%X", $1);
                                            } else {
                                                printf("%d", $1);
                                            }
                                        }
| text RIGHT_ARROW                      {
                                            if ($1) {
                                                printf("%s", $1);
                                            } else {
                                                printf("\n");
                                            }
                                        }
;

assignexp:
  REG LEFT_ARROW exp                    {
                                            reg[$1] = $3;
                                            printf("R[%d] = %d\n", $1, $3);
                                        }
;

specexp:
  IF '(' exp CMP exp ')' ':'            {
                                            create_block(0);
                                            printf("if\n");
                                        }
| ELSE ':'                              {
                                            if (is_if_block()) {
                                                create_block(1);
                                                printf("else\n");
                                            } else {
                                                yyerror("unexpected else statement");
                                            }
                                        }
| REPEAT '(' exp '|' exp ')' ':'        {
                                            create_block(2);
                                            printf("repeat %d -> %d:\n", $3, $5);
                                        }
;

%%

void yyerror(char *s) {
    fprintf(stderr, "! ERROR: %s\n", s);
}

void create_block(int type) {
    block_t *block = (block_t *) malloc(sizeof(block_t));
    block->back = blocks;
    block->type = type;
    if (type >= 0 && type <= 1)
        block->id = cond_id++;
    else if (type == 2)
        block->id = loop_id++;
    // block->level = ++indent_level;

    indent_level++;

    blocks = block;
}

int is_if_block() {
    return (blocks->type == 0 ? 1 : 0);
}