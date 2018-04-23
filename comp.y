
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

%token					CONSTANT TEXT LEFT_ARROW RIGHT_ARROW IF EL RP DOUBLEQUOTE COLLON NEWLINE REG TAB

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
|exp RIGHT_ARROW		{
					//print		
				}

|exp RIGHT_ARROW '#'		{
					//print base 16
				}

|exp '+' exp			{
					//to do
				}

|exp '-' exp			{
					//to do
				}

|exp '*' exp			{
					//to do
				}

|exp '/' exp			{
					//to do 
				}

|exp '%' exp			{
					//to do
				}

|exp '#'			{
					//to do (number base 16)
				}

|exp LEFT_ARROW exp		{
					//to do assign some value to $1
				}

|IF '(' exp '<->' exp ')' COLLON	{
					//to do 
				}

|EL COLLON				{
					//to do
				}
|EL '(' exp '<->' exp ')' COLLON	{
					//to do
				}
|RP '(' exp '|' exp ')' COLLON	{
					//to do
				}

|'-' exp			{
					//to do
				}			

|RIGHT_ARROW			{
					//to do
				}
;
exp:
	TEXT			{ 
					//to do
				}

|CONSTANT			{
					//to d o sdfg
				}



;









































