
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

%start input

%token CONSTANT TEXT EQUALS LEFT_ARROW RIGHT_ARROW IF EL RP DOUBLEQUOTE NEWLINE REG TAB

%%

input:
  %empty
| input line
;

line:
  '\n'
| exp '\n'
| assignexp '\n'
| printexp '\n'
| specexp '\n'
;

text:
  %empty
| TEXT
;

hex:
  %empty
| '#'
;

printexp:
  exp RIGHT_ARROW hex
| text RIGHT_ARROW hex
;

exp:
  CONSTANT
| REG

| exp '+' exp			{
					//to do
				}

| exp '-' exp			{
					//to do
				}

| exp '*' exp			{
					//to do
				}

| exp '/' exp			{
					//to do 
				}

| exp '%' exp			{
					//to do
				}

| '-' exp			{
					//to do
				}		
;

assignexp:
  REG LEFT_ARROW exp		{
					//to do assign some value to $1
				}
;

specexp:
  IF '(' exp EQUALS exp ')' ':'	{
					//to do 
				}

| EL ':'				{
					//to do
				}

| RP '(' exp '|' exp ')' ':'	{
					//to do
				}
;








































