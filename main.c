#include <stdio.h>
#include <string.h>

int yyparse();

int main(int argc, char **argv)
{
  	// if ((argc > 1) && (freopen(argv[1], "r", stdin) == NULL))
  	// {
	// 	fprintf(stderr, "%s: File %s cannot be opened.", argv[0], argv[1]);
	// 	return 0;
  	// }

	printf("> ");

	while (1)
	{
		if (yyparse())
		{
			printf("> ");
		}
	}

	return 0;
}
