
%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

void yyerror(char *s);

// yylval of CMP token
enum {NOTEQ = 0, EQ, GREATER, LESS, GREATEREQ, LESSEQ};

// register $A - $z
// TODO: remove this when convert to asm
int reg[52] = {0};

%}

%union {
    int i;
    char *s;
}

%start file

%token <i>  CONSTANT REG CMP
%token <s>  TEXT NEWLINE
%token      LEFT_ARROW RIGHT_ARROW IF EL RP DOUBLEQUOTE TAB END_OF_FILE

%type <i>   exp hex
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
  statement
| line NEWLINE statement                {}
| line error NEWLINE statement          {
                                            YYABORT;
                                        }
;

statement:
  %empty
| exp                                   { printf("EXP: %d\n", $1);                        }
| assignexp
| printexp
| specexp
;

inside:
  %empty
| inside TAB statement
;

text:
  %empty                                { $$ = 0;                                       }
| TEXT                                  { $$ = $1;                                      }
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

elseexp:
  %empty
| EL ':' NEWLINE inside
;

specexp:
  IF '(' exp CMP exp ')' ':' NEWLINE inside elseexp { if ($3 == $5) printf("if\n"); }
| RP '(' exp '|' exp ')' ':' NEWLINE inside    { printf("repeat %d -> %d:\n", $3, $5);         }
;

%%

void yyerror(char *s) {
    fprintf(stderr, "! ERROR: %s\n", s);
}