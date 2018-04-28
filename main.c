#include <stdio.h>
#include <string.h>

char *get_file_name(char *);
void print(char *, char *);
void print_label(char *);
void print_ln(void);
void print_space(int);

extern int yyparse();
extern FILE *yyin;

FILE *fp;

char *header = "\t\tglobal\t_start\n\n\t\tsection\t.text\n_start:\n";

int main(int argc, char **argv)
{
	if (argc != 2) {
		fprintf(stderr, "please locate source code file!");
		return 0;
	}

	yyin = fopen(argv[1], "r");

	// create .asm file
	fp = fopen(get_file_name(argv[1]), "w");

	// append some assembly header code
	print("global", "_start");
	print_ln();
	print("section", ".text");
	print_label("_start");

	yyparse();

	fclose(yyin);
	fclose(fp);

	return 0;
}

char *get_file_name(char *file)
{
	char *str = strrchr(file, '.');
	strcpy(str, ".asm");
	return file;
}

void print(char *ins, char *param)
{
	print_space(16);
	fprintf(fp, "%-7s", ins);
	print_space(1);
	fprintf(fp, "%s\n", param);
}

void print_label(char *name)
{
	fprintf(fp, "%s:\n", name);
}

void print_ln()
{
	fprintf(fp, "\n");
}

void print_space(int n)
{
	if (n == 0)
		return;

	fprintf(fp, " ");
	print_space(n - 1);
}