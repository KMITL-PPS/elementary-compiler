
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
| exp '\n'                              { printf(" = %d\n", $1);                        }
| assignexp '\n'
| printexp '\n'
| specexp
;

text:
  %empty
| TEXT
;

hex:
  %empty
| '#'
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
  exp RIGHT_ARROW hex
| text RIGHT_ARROW hex
;

assignexp:
  REG LEFT_ARROW exp                    { reg[$1] = $3;                                 }
;

specexp:
  IF '(' exp CMP exp ')' ':'     {}
| EL ':'                                {}
| RP '(' exp '|' exp ')' ':'            {}
;

%%

void yyerror(char *s) {
    fprintf(stderr, "! ERROR: %s\n", s);
    errors++;
}