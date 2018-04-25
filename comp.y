
%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void yyerror(char *);

typedef struct block {
    struct block **back;

    int type;               // 0 = if, 1 = else, 2 = repeat
    int id;
    // int level;
} block_t;

// register $A - $z
// TODO: remove this when convert to asm
int reg[52] = {0};

// int indent_level = 0;
block_t **blocks = NULL;
int cond_id = 0, loop_id = 0;

%}

%union {
    int i;
    char *s;
}

%start file

%token <i>  CONSTANT REG CMP
%token <s>  TEXT NL
%token      LEFT_ARROW RIGHT_ARROW IF EL RP DOUBLE_QUOTE TAB
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
                                            block_t *block = (block_t *) malloc(sizeof(block_t));
                                            block->back = blocks;
                                            block->type = 0;
                                            block->id = cond_id++;
                                            // block->level = ++indent_level;

                                            blocks = &block;
                                            printf("if\n");
                                        }
| EL ':'                                {
                                            block_t *block = (block_t *) malloc(sizeof(block_t));
                                            block->back = blocks;
                                            block->type = 1;
                                            block->id = cond_id++;
                                            // block->level = ++indent_level;

                                            blocks = &block;
                                            printf("else\n");
                                        }
| RP '(' exp '|' exp ')' ':'            {
                                            block_t *block = (block_t *) malloc(sizeof(block_t));
                                            block->back = blocks;
                                            block->type = 2;
                                            block->id = loop_id++;
                                            // block->level = ++indent_level;

                                            blocks = &block;
                                            printf("repeat %d -> %d:\n", $3, $5);
                                        }
;

%%

void yyerror(char *s) {
    fprintf(stderr, "! ERROR: %s\n", s);
}