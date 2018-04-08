D			[0-9]
L			[a-zA-Z]
H			[a-fA-F0-9]

%option noyywrap
%{
#include <stdio.h>
#include <string.h>
#include "comp.tab.h"

int hexToDec(char *);
%}

%%

"+"							{ return '+'; }
"-"							{ return '-'; }
"*"							{ return '*'; }
"/"							{ return '/'; }
"%"							{ return '%'; }
"("							{ return '('; }
")"							{ return ')'; }
"<->"						{ return '=' }

{H}+[#]						{ yylval = hexToDec(yytext); return CONSTANT; }
{D}+						{ yylval = atoi(yytext); return CONSTANT; }

"$"{L}						{ yylval = yytext[1] - 'A'; return REG; }

"<-"						{ return LEFT_ARROW; }
"->"						{ return RIGHT_ARROW; }
("if"|"IF"|"iF"|"If")		{ return IF; }
("el"|"EL"|"eL"|"El")		{ return EL; }
("rp"|"RP"|"rP"|"Rp")		{ return RP; }

"\""						{ return DOUBLEQUOTE; }
":"							{ return COLLON; }

[\v\f]						{ /* ignore whitespace */ }

\t							{ return TAB; }
\n							{ yylineno++; return NEWLINE; }

.							{ return yytext[0]; }

%%

int hexToDec(char *s)
{
	int i = 0, value = 0;
	for (i = 0; s[i] != 'h' && s[i] != 'H'; i++)
	{
		value *= 16;
		if (s[i] >= '0' && s[i] <= '9')
		{
			value += s[i] - '0';
		}
		else
		{
			if (s[i] >= 65 && s[i] <= 90)
				s[i] = s[i] + 32;
			value += s[i] - 'A' + 10;
		}
	}

	return value;
}