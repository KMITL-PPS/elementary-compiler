D               [0-9]
L               [a-zA-Z]
H               [a-fA-F0-9]

%option noyywrap
%{
#include <stdio.h>
#include <string.h>
#include "comp.tab.h"

int hexToDec(char *);
int getReg(char);
%}

%%

"<->>"                      { yylval.i = 4; return CMP;                        }
"<<->"                      { yylval.i = 5; return CMP;                        }
">-<"                       { yylval.i = 0; return CMP;                        }
"<->"                       { yylval.i = 1; return CMP;                        }

"<-"                        { return LEFT_ARROW;                                }
"->"                        { return RIGHT_ARROW;                               }

">"                         { yylval.i = 2; return CMP;                        }
"<"                         { yylval.i = 3; return CMP;                        }

"+"                         { return '+';                                       }
"-"                         { return '-';                                       }
"*"                         { return '*';                                       }
"/"                         { return '/';                                       }
"%"                         { return '%';                                       }
"("                         {
                                return '('; // ) for dummy purpose
                            }
")"                         { return ')';                                       }

{H}+[#]                     {
                                yylval.i = hexToDec(yytext);
                                return CONSTANT;
                            }
{D}+                        {
                                yylval.i = atoi(yytext);
                                return CONSTANT;
                            }
"$"{L}                      {
                                yylval.i = getReg(yytext[1]);
                                return REG;
                            }

[iI][fF]                    { return IF;                                        }
[eE][lL]                    { return EL;                                        }
[rR][pP]                    { return RP;                                        }

"\""                        { return DOUBLEQUOTE;                               }
":"                         { return ':';                                       }

(\"([^\"])*\")              {
                                yylval.s = yytext;
                                return TEXT;
                            }

[ \v\f]                     { /* ignore whitespace */                           }

\t                          { return TAB;                                       }
\n                          {
                                yylineno++;
                                return NEWLINE;
                            }

<<EOF>>                     { return END_OF_FILE;                               }

.                           { return yytext[0];                                 }

%%

int hexToDec(char *s)
{
    // } for dummy purpose
    int i = 0, value = 0;
    for (i = 0; s[i] != 'h' && s[i] != 'H'; i++) {
        value *= 16;
        if (s[i] >= '0' && s[i] <= '9') {
            value += s[i] - '0';
        } else {
            if (s[i] >= 65 && s[i] <= 90)
                s[i] = s[i] + 32;
            value += s[i] - 'A' + 10;
        }
    }

    return value;
}

int getReg(char c)
{
    // } for dummy purpose
    if (c >= 'A' && c <= 'Z') {
        return c - 'A';
    } else if (c >= 'a' && c <= 'z') {
        return c - 'a' + 26;
    }
    return -1;
}

// test flex
// int main(int argc, char **argv)
// {
//     // yyin = fopen(argv[1], "r");
    
//     int token;

//     while((token = yylex())) {
//         printf("[%d", token);

//         if (token == 300 || token == 301) {
//             printf(", %s", yytext);
//         }

//         printf("]\n");
//     }

//     // fclose(yyin);

//     return 0;
// }