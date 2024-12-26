%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylex();
extern FILE *yyin;
extern FILE *yyout;
extern int line_num;
void yyerror(const char *s);

struct symbol {
    char *name;
    int value;
    double decimal_value;
    char *type;
};
struct symbol symbols[100];
int sym_count = 0;

int get_symbol_value(char *name) {
    for(int i = 0; i < sym_count; i++) {
        if(strcmp(symbols[i].name, name) == 0) return symbols[i].value;
    }
    fprintf(yyout, "Line %d: Error - undefined variable %s\n", line_num, name);
    return 0;
}

void set_symbol(char *name, int value, char *type) {
    for(int i = 0; i < sym_count; i++) {
        if(strcmp(symbols[i].name, name) == 0) {
            symbols[i].value = value;
            return;
        }
    }
    symbols[sym_count].name = strdup(name);
    symbols[sym_count].value = value;
    symbols[sym_count].type = strdup(type);
    sym_count++;
}
%}

%union {
    int number;
    double decimal;
    char* string;
}

%token MAIN FUNCTION
%token FOR IF ELSE ELSE_IF DECLARE BREAK CONTINUE
%token PRINT INPUT RETURN WHILE SWITCH CASE
%token EQUAL GREATER LESS GREATER_EQUAL LESS_EQUAL
%token PLUS MINUS MULTIPLY DIVIDE MODULO POWER
%token LOGICAL_AND LOGICAL_OR BITWISE_NOT BITWISE_AND BITWISE_OR
%token ASSIGN NOT_EQUAL LINE_END INCREMENT DECREMENT
%token TYPE_INT TYPE_CHAR TYPE_BOOL TYPE_DOUBLE TYPE_STRING TYPE_VOID
%token BOOL_TRUE BOOL_FALSE
%token LEFT_PAREN RIGHT_PAREN LEFT_BRACE RIGHT_BRACE LEFT_BRACKET RIGHT_BRACKET
%token COMMA SEMICOLON

%token <number> NUMBER
%token <decimal> DECIMAL
%token <string> IDENTIFIER STRING_LITERAL CHAR_LITERAL

%type <number> expression
%type <string> type

%left PLUS MINUS
%left MULTIPLY DIVIDE MODULO
%left POWER
%left LOGICAL_AND LOGICAL_OR
%left BITWISE_AND BITWISE_OR
%left EQUAL NOT_EQUAL
%left GREATER LESS GREATER_EQUAL LESS_EQUAL

%%

program:
    type FUNCTION MAIN LEFT_PAREN RIGHT_PAREN LEFT_BRACE statements RIGHT_BRACE
    ;

type:
    TYPE_INT    { $$ = "purno"; }
    | TYPE_CHAR { $$ = "okkhor"; }
    | TYPE_BOOL { $$ = "boolean"; }
    | TYPE_DOUBLE { $$ = "dosomik"; }
    | TYPE_STRING { $$ = "sobdo"; }
    | TYPE_VOID   { $$ = "sunnota"; }
    ;

statements: 
    /* empty */
    | statements statement
    ;

statement:
    simple_statement SEMICOLON
    | compound_statement
    ;

simple_statement:
    declaration
    | print_statement
    | expression_statement
    | return_statement
    ;

compound_statement:
    if_statement
    | while_statement
    | for_statement
    ;

declaration:
    type IDENTIFIER ASSIGN expression {
        set_symbol($2, $4, $1);
    }
    ;

expression_statement:
    IDENTIFIER ASSIGN expression {
        set_symbol($1, $3, "int");
    }
    | IDENTIFIER INCREMENT {
        int val = get_symbol_value($1);
        set_symbol($1, val + 1, "int");
    }
    | IDENTIFIER DECREMENT {
        int val = get_symbol_value($1);
        set_symbol($1, val - 1, "int");
    }
    ;

print_statement:
    PRINT expression {
        fprintf(yyout, "%d\n", $2);
    }
    | PRINT STRING_LITERAL {
        fprintf(yyout, "%s\n", $2);
    }
    ;

if_statement:
    IF LEFT_PAREN expression RIGHT_PAREN LEFT_BRACE statements RIGHT_BRACE
    | IF LEFT_PAREN expression RIGHT_PAREN LEFT_BRACE statements RIGHT_BRACE ELSE LEFT_BRACE statements RIGHT_BRACE
    ;

while_statement:
    WHILE LEFT_PAREN expression RIGHT_PAREN LEFT_BRACE statements RIGHT_BRACE
    ;

for_statement:
    FOR LEFT_PAREN expression_statement SEMICOLON expression SEMICOLON expression_statement RIGHT_PAREN LEFT_BRACE statements RIGHT_BRACE
    ;

return_statement:
    RETURN expression
    | RETURN
    ;

expression:
    NUMBER
    | DECIMAL { $$ = (int)$1; }
    | IDENTIFIER { $$ = get_symbol_value($1); }
    | expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression MULTIPLY expression { $$ = $1 * $3; }
    | expression DIVIDE expression { 
        if($3 == 0) {
            fprintf(yyout, "Line %d: Error - division by zero\n", line_num);
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | expression MODULO expression {
        if($3 == 0) {
            fprintf(yyout, "Line %d: Error - modulo by zero\n", line_num);
            $$ = 0;
        } else {
            $$ = $1 % $3;
        }
    }
    | LEFT_PAREN expression RIGHT_PAREN { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(yyout, "Line %d: Syntax error - %s\n", line_num, s);
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        printf("Usage: %s input.txt output.txt\n", argv[0]);
        return 1;
    }

    yyin = fopen(argv[1], "r");
    if (!yyin) {
        printf("Cannot open input file\n");
        return 1;
    }

    yyout = fopen(argv[2], "w");
    if (!yyout) {
        printf("Cannot open output file\n");
        return 1;
    }

    yyparse();

    fclose(yyin);
    fclose(yyout);
    return 0;
}