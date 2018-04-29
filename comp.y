
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

void yyerror(char *);
void create_block(int);
int is_if_block();
int create_text(char *);

extern void print(char *, char *);
extern void print_label(char *);
extern void print_ins(char *);
extern void print_syscall(void);
extern void println(char *);
extern void print_space(int);
extern FILE *fp;

typedef struct block_t {
    struct block_t *back;

    int type;               // 0 = if, 1 = else, 2 = repeat
    int id;
    // int right;
} block_t;

typedef struct text_t {
    int id;
    char *msg;

    struct text_t *next;
} text_t;

// register $A - $z
// TODO: reMOVe this when convert to asm
int reg[52] = {0};

int indent_level = 0;
block_t *blocks = NULL;
text_t *texts = NULL;
int cond_id = 0, loop_id = 0;

%}

%union {
    int i;
    char *s;
}

%start file

%token <i>  CONSTANT REG
%token <s>  TEXT NL
%token      '(' ')'
%token      '^' NEG '*' '/' '%' '+' '-'
%token <i>  CMP
%token      LEFT_ARROW RIGHT_ARROW
%token      IF ELSE REPEAT
%token      TAB
%token      END_OF_FILE 0

%type <i>   exp hex tab
%type <s>   text statement assignexp printexp specexp

%left                                   '+' '-'
%left                                   '*' '/' '%'
%precedence                             NEG
%right                                  '^'

%%

file:
  line END_OF_FILE                      {
                                            // append exit to assembly
                                            print("MOV", "RAX, 60");
                                            print("MOV", "RDI, 0");
                                            print_syscall();
                                            println("");

                                            // data section
                                            print("section", ".data");

                                            // append register data ($rA - $rz)
                                            fprintf(fp, "reg             DQ      52 DUP(0)\n");
                                            println("");

                                            // append newline
                                            fprintf(fp, "nl              DB      10\n");
                                            println("");

                                            // append text data
                                            text_t *t;
                                            for (t = texts; t != NULL; t = t->next) {
                                                fprintf(fp, "t%-14d DB      ", t->id);
                                                fprintf(fp, "%s\n", t->msg);
                                                // TODO: print NEWLINE?
                                            }
                                        }
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
  assignexp
| printexp
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
| '(' exp ')'                           { $$ = $2;                                      }
;

printexp:
  exp RIGHT_ARROW hex                   {
                                            // print HEX
                                            if ($3) {
                                                printf("%X", $1);
                                            // print DEC
                                            } else {
                                                printf("%d", $1);
                                            }
                                        }
| text RIGHT_ARROW                      {
                                            // TODO: ->>  |  - > >   println()
                                            // print TEXT
                                            if ($1) { // TODO: recheck this
                                                int id = create_text($1);

                                                print("MOV", "RAX, 1");
                                                print("MOV", "RDI, 1");
                                                print_ins("MOV");
                                                fprintf(fp, "RSI, t%d\n", id);
                                                print_ins("MOV");
                                                fprintf(fp, "RDX, %lu\n", strlen($1) - 2);
                                                print_syscall();
                                                println("");

                                            // print NEWLINE
                                            } else {
                                                print("MOV", "RAX, 1");
                                                print("MOV", "RDI, 1");
                                                print("MOV", "RSI, nl");
                                                print("MOV", "RDX, 1");
                                                print_syscall();
                                                println("");
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

int create_text(char *msg) {
    text_t *t = texts;

    if (t == NULL) {
        texts = (text_t *) malloc(sizeof(text_t));
        t = texts;
        t->id = 0;
    } else {
        while (t->next != NULL)
            t = t->next;
        t->next = (text_t *) malloc(sizeof(text_t));
        t->next->id = t->id + 1;
        t = t->next;
    }
    t->msg = strdup(msg);
    t->next = NULL;

    return t->id;
}