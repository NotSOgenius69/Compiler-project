CC = gcc
CFLAGS = -w

bongo: lex.yy.c bongo.tab.c
	$(CC) $(CFLAGS) -o bongo lex.yy.c bongo.tab.c -lfl

bongo.tab.c: bongo.y
	bison -d bongo.y

lex.yy.c: bongo.l
	flex bongo.l

clean:
	rm -f bongo lex.yy.c bongo.tab.c bongo.tab.h