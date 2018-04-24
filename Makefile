OBJS = comp.y comp.flex main.c

CC = gcc

comp: $(OBJS)
	bison -d comp.y
	flex comp.flex
	$(CC) main.c comp.tab.c lex.yy.c -o comp

clean:
	rm comp.tab.c comp.tab.h lex.yy.c comp