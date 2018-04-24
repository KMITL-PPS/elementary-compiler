
%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// yylval of CMP token
enum {NOTEQ = 0, EQ, GREATER, LESS, GREATEREQ, LESSEQ};

// register $A - $z
// TODO: remove this when convert to asm
int reg[52] = {0};

%}

%start                                  input

%token                                  CONSTANT REG TEXT CMP LEFT_ARROW RIGHT_ARROW IF EL RP DOUBLEQUOTE NEWLINE TAB

%left                                   '+' '-'
%left                                   '*' '/' '%'
%precedence                             NEG
%right                                  '^'

%%

input:
  %empty
| input line                            {}
| input error line                      {
                                            YYABORT;
                                        }
;

line:
  '\n'
| exp '\n'                              { printf("EXP: %d\n", $1);                        }
| assignexp '\n'
| printexp '\n'
| specexp
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
| | '(' exp ')'                         { $$ = $2;                                      }
;

printexp:
  exp RIGHT_ARROW hex                   {
                                            if ($3) {
                                                printf("%x", $1);
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
                                            printf("REG[%d] = %d\n", $1, $3);
                                        }
;

specexp:
  IF '(' exp CMP exp ')' ':' '\n'       { printf("if %d CMP[%d] %d:\n", $3, $4, $5);    }
| EL ':' '\n'                           { printf("else:\n");                            }
| RP '(' exp '|' exp ')' ':' '\n'       { printf("repeat %d -> %d:\n", $3, $5);         }
;

%%

void yyerror(char *s) {
    fprintf(stderr, "! ERROR: %s\n", s);
    errors++;
}