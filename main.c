#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *get_file_name(char *);
void print(char *, char *);
void print_label(char *);
void print_ins(char *);
void print_syscall(void);
void println(char *);
void print_space(int);

extern int yyparse();
extern FILE *yyin;
extern struct buffer_t **cur_buf;

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
	println("");
	print("section", ".text");
	println("_start:");

	// initialize cur_buf
	cur_buf = malloc(sizeof(struct buffer_t *));

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
	print_ins(ins);
	fprintf(fp, "%s\n", param);
}

void print_ins(char *ins)
{
	print_space(16);
	fprintf(fp, "%-7s", ins);
	print_space(1);
}

void print_syscall()
{
	print_space(16);
	fprintf(fp, "syscall\n\n");
}

void println(char *text)
{
	fprintf(fp, "%s\n", text);
}

void print_space(int n)
{
	if (n == 0)
		return;

	fprintf(fp, " ");
	print_space(n - 1);
}