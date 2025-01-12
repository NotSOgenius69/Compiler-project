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
    char *string_value;
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

void set_decimal_symbol(char *name, double value, char *type) {
    for(int i = 0; i < sym_count; i++) {
        if(strcmp(symbols[i].name, name) == 0) {
            symbols[i].decimal_value = value;
            return;
        }
    }
    symbols[sym_count].name = strdup(name);
    symbols[sym_count].decimal_value = value;
    symbols[sym_count].type = strdup(type);
    sym_count++;
}

void set_string_symbol(char *name, char *value, char *type) {
    for(int i = 0; i < sym_count; i++) {
        if(strcmp(symbols[i].name, name) == 0) {
            symbols[i].string_value = strdup(value);
            return;
        }
    }
    symbols[sym_count].name = strdup(name);
    symbols[sym_count].string_value = strdup(value);
    symbols[sym_count].type = strdup(type);
    sym_count++;
}

int switch_value = 0;
int case_matched = 0;
int current_case_matches = 0;
int if_condition_met = 0;
int in_conditional = 0;
int in_loop = 0;
int should_break = 0;
int previous_condition_met = 0;
%}

%union {
    int value;
    double decimal_value;
    char* string_value;
    struct {
        int value;
        double decimal_value;
        char* string_value;
        char* type;
    } expr;
}

%token MAIN FUNCTION
%token FOR IF ELSE ELSE_IF DECLARE BREAK CONTINUE
%token PRINT INPUT RETURN WHILE SWITCH CASE DEFAULT COLON
%token EQUAL GREATER LESS GREATER_EQUAL LESS_EQUAL
%token JOG BIYOG GUN VAAG MODULO POWER
%token LOGICAL_AND LOGICAL_OR BITWISE_NOT BITWISE_AND BITWISE_OR
%token ASSIGN NOT_EQUAL LINE_END INCREMENT DECREMENT
%token TYPE_INT TYPE_CHAR TYPE_BOOL TYPE_DOUBLE TYPE_STRING TYPE_VOID
%token BOOL_TRUE BOOL_FALSE
%token LEFT_PAREN RIGHT_PAREN LEFT_BRACE RIGHT_BRACE LEFT_BRACKET RIGHT_BRACKET
%token COMMA SEMICOLON

%token <value> NUMBER
%token <decimal_value> DECIMAL
%token <string_value> IDENTIFIER STRING_LITERAL CHAR_LITERAL

%type <expr> expression function_call
%type <string_value> type
%type <expr> increment_statement

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%nonassoc ELSE_IF
%left LOGICAL_OR
%left LOGICAL_AND
%left BITWISE_OR
%left BITWISE_AND
%left EQUAL NOT_EQUAL
%left GREATER LESS GREATER_EQUAL LESS_EQUAL
%left JOG BIYOG
%left GUN VAAG MODULO
%right POWER
%right INCREMENT DECREMENT
%left LEFT_PAREN RIGHT_PAREN

%%

program:
    functions
    ;

functions:
    function
    | functions function
    ;

function:
    type FUNCTION IDENTIFIER LEFT_PAREN parameters RIGHT_PAREN LEFT_BRACE statements RIGHT_BRACE
    | type FUNCTION MAIN LEFT_PAREN RIGHT_PAREN LEFT_BRACE statements RIGHT_BRACE
    ;

parameters:
    /* empty */
    | parameter_list
    ;

parameter_list:
    type IDENTIFIER {
        set_symbol($2, 0, $1);
    }
    | parameter_list COMMA type IDENTIFIER {
        set_symbol($4, 0, $3);
    }
    ;

statements: 
    statement
    | statements statement
    ;

statement:
    simple_statement SEMICOLON
    | compound_statement
    | break_statement SEMICOLON
    | continue_statement SEMICOLON
    ;

simple_statement:
    declaration
    | print_statement
    | input_statement
    | expression_statement
    | return_statement
    ;

compound_statement:
    if_statement
    | while_statement
    | for_statement
    | switch_statement
    ;

declaration:
    DECLARE type IDENTIFIER {
        if(strcmp($2, "dosomik") == 0)
            set_decimal_symbol($3, 0.0, $2);
        else if(strcmp($2, "sobdo") == 0)
            set_string_symbol($3, "", $2);
        else
            set_symbol($3, 0, $2);
    }
    | DECLARE type IDENTIFIER ASSIGN expression {
        if(strcmp($2, "dosomik") == 0)
            set_decimal_symbol($3, $5.decimal_value, $2);
        else if(strcmp($2, "sobdo") == 0)
            set_string_symbol($3, $5.string_value, $2);
        else
            set_symbol($3, $5.value, $2);
    }
    | DECLARE type IDENTIFIER ASSIGN STRING_LITERAL {
        if(strcmp($2, "sobdo") == 0) {
            char *str = strdup($5);
            str[strlen(str)-1] = '\0';
            set_string_symbol($3, str+1, $2);
            free(str);
        }
    }
    ;

expression_statement:
    IDENTIFIER ASSIGN expression {
        if(strcmp($3.type, "dosomik") == 0)
            set_decimal_symbol($1, $3.decimal_value, "dosomik");
        else if(strcmp($3.type, "sobdo") == 0)
            set_string_symbol($1, $3.string_value, "sobdo");
        else
            set_symbol($1, $3.value, "purno");
    }
    | IDENTIFIER ASSIGN STRING_LITERAL {
        char *str = strdup($3);
        str[strlen(str)-1] = '\0';
        set_string_symbol($1, str+1, "sobdo");
        free(str);
    }
    | increment_statement
    ;

print_statement:
    PRINT expression {
        if (!in_conditional || (in_conditional && if_condition_met)) {
            if(strcmp($2.type, "dosomik") == 0)
                fprintf(yyout, "%.2f\n", $2.decimal_value);
            else
                fprintf(yyout, "%d\n", $2.value);
        }
    }
    | PRINT STRING_LITERAL {
        if (!in_conditional || (in_conditional && if_condition_met)) {
            char *str = strdup($2);
            str[strlen(str)-1] = '\0';
            fprintf(yyout, "%s\n", str+1);
            free(str);
        }
    }
    | PRINT IDENTIFIER {
        if (!in_conditional || (in_conditional && if_condition_met)) {
            for(int i = 0; i < sym_count; i++) {
                if(strcmp(symbols[i].name, $2) == 0) {
                    if(strcmp(symbols[i].type, "sobdo") == 0)
                        fprintf(yyout, "%s\n", symbols[i].string_value);
                    else if(strcmp(symbols[i].type, "dosomik") == 0)
                        fprintf(yyout, "%.2f\n", symbols[i].decimal_value);
                    else
                        fprintf(yyout, "%d\n", symbols[i].value);
                    break;
                }
            }
        }
    }
    ;

input_statement:
    INPUT IDENTIFIER
    ;

if_statement:
    simple_if %prec LOWER_THAN_ELSE
    | simple_if ELSE LEFT_BRACE {
        if (!previous_condition_met) {
            if_condition_met = 1;
            in_conditional = 1;
        } else {
            in_conditional = 0;
            if_condition_met = 0;
        }
    } statements RIGHT_BRACE {
        in_conditional = 0;
        if_condition_met = 0;
        previous_condition_met = 0;
    }
    | simple_if else_if_list
    ;

simple_if:
    IF LEFT_PAREN expression RIGHT_PAREN LEFT_BRACE {
        previous_condition_met = 0;
        if_condition_met = ($3.value != 0);
        in_conditional = 1;
        if (if_condition_met) {
            previous_condition_met = 1;
        }
    } statements RIGHT_BRACE {
        in_conditional = 0;
    }
    ;

else_if_list:
    else_if_clause
    | else_if_list else_if_clause
    ;

else_if_clause:
    ELSE_IF LEFT_PAREN expression RIGHT_PAREN LEFT_BRACE {
        if (!previous_condition_met) {
            if_condition_met = ($3.value != 0);
            in_conditional = 1;
            if (if_condition_met) {
                previous_condition_met = 1;
            }
        } else {
            in_conditional = 0;
            if_condition_met = 0;
        }
    } statements RIGHT_BRACE {
        in_conditional = 0;
    }
    | ELSE LEFT_BRACE {
        if (!previous_condition_met) {
            if_condition_met = 1;
            in_conditional = 1;
            previous_condition_met = 1;
        } else {
            in_conditional = 0;
            if_condition_met = 0;
        }
    } statements RIGHT_BRACE {
        in_conditional = 0;
        if_condition_met = 0;
        previous_condition_met = 0;
    }
    ;

while_statement:
    WHILE LEFT_PAREN IDENTIFIER GREATER NUMBER RIGHT_PAREN LEFT_BRACE {
        in_loop = 1;
        in_conditional = 1;
        char *var_name = $3;
        int val = get_symbol_value(var_name);
        while (val > $5 && !should_break) {
            fprintf(yyout, "%d\n", val);
            val--;
            set_symbol(var_name, val, "purno");
        }
    } statements RIGHT_BRACE {
        in_loop = 0;
        in_conditional = 0;
    }
    ;

for_statement:
    FOR LEFT_PAREN IDENTIFIER ASSIGN NUMBER SEMICOLON 
        IDENTIFIER LESS_EQUAL NUMBER SEMICOLON 
        IDENTIFIER INCREMENT RIGHT_PAREN LEFT_BRACE {
        in_loop = 1;
        in_conditional = 1;
        char *var_name = $3;
        int start_val = $5;
        int end_val = $9;
        
        set_symbol(var_name, start_val, "purno");
        for (int i = start_val; i <= end_val && !should_break; i++) {
            fprintf(yyout, "%d\n", i);
            set_symbol(var_name, i + 1, "purno");
        }
    } statements RIGHT_BRACE {
        in_loop = 0;
        in_conditional = 0;
    }
    ;

increment_statement:
    IDENTIFIER INCREMENT {
        int val = get_symbol_value($1);
        set_symbol($1, val + 1, "purno");
        $$.value = val + 1;
        $$.type = "purno";
    }
    | IDENTIFIER DECREMENT {
        int val = get_symbol_value($1);
        set_symbol($1, val - 1, "purno");
        $$.value = val - 1;
        $$.type = "purno";
    }
    ;

switch_statement:
    SWITCH LEFT_PAREN IDENTIFIER RIGHT_PAREN LEFT_BRACE {
        switch_value = get_symbol_value($3);
        case_matched = 0;
        in_conditional = 1;
    } case_list RIGHT_BRACE {
        in_conditional = 0;
    }
    ;

case_list:
    case_list case_statement
    | case_statement
    | /* empty */
    ;

case_statement:
    CASE NUMBER COLON {
        current_case_matches = ($2 == switch_value && !case_matched);
        if (current_case_matches) {
            case_matched = 1;
            if_condition_met = 1;
        }
    } statements {
        if (current_case_matches) {
            if_condition_met = 0;
        }
        current_case_matches = 0;
    }
    | DEFAULT COLON {
        current_case_matches = !case_matched;
        if (current_case_matches) {
            if_condition_met = 1;
        }
    } statements {
        if (current_case_matches) {
            if_condition_met = 0;
        }
        current_case_matches = 0;
    }
    ;

break_statement:
    BREAK {
        if (in_loop) {
            should_break = 1;
        }
    }
    ;

continue_statement:
    CONTINUE
    ;

return_statement:
    RETURN expression
    | RETURN
    ;

expression:
    NUMBER {
        $$.value = $1;
        $$.type = "purno";
    }
    | DECIMAL {
        $$.decimal_value = $1;
        $$.type = "dosomik";
    }
    | STRING_LITERAL {
        $$.string_value = $1;
        $$.type = "sobdo";
    }
    | IDENTIFIER {
        for(int i = 0; i < sym_count; i++) {
            if(strcmp(symbols[i].name, $1) == 0) {
                if(strcmp(symbols[i].type, "sobdo") == 0) {
                    $$.string_value = symbols[i].string_value;
                    $$.type = "sobdo";
                } else if(strcmp(symbols[i].type, "dosomik") == 0) {
                    $$.decimal_value = symbols[i].decimal_value;
                    $$.type = "dosomik";
                } else {
                    $$.value = symbols[i].value;
                    $$.type = "purno";
                }
                break;
            }
        }
    }
    | function_call {
        $$.value = $1.value;
        $$.type = $1.type;
    }
    | expression JOG expression {
        $$.value = $1.value + $3.value;
        $$.type = "purno";
    }
    | expression BIYOG expression {
        $$.value = $1.value - $3.value;
        $$.type = "purno";
    }
    | expression GUN expression {
        $$.value = $1.value * $3.value;
        $$.type = "purno";
    }
    | expression VAAG expression {
        if($3.value == 0) {
            fprintf(yyout, "Line %d: Error - division by zero\n", line_num);
            $$.value = 0;
            $$.type = "purno";
        } else {
            $$.value = $1.value / $3.value;
            $$.type = "purno";
        }
    }
    | expression MODULO expression {
        if($3.value == 0) {
            fprintf(yyout, "Line %d: Error - modulo by zero\n", line_num);
            $$.value = 0;
            $$.type = "purno";
        } else {
            $$.value = $1.value % $3.value;
            $$.type = "purno";
        }
    }
    | expression GREATER expression {
        $$.value = $1.value > $3.value;
        $$.type = "boolean";
    }
    | expression LESS expression {
        $$.value = $1.value < $3.value;
        $$.type = "boolean";
    }
    | expression GREATER_EQUAL expression {
        $$.value = $1.value >= $3.value;
        $$.type = "boolean";
    }
    | expression LESS_EQUAL expression {
        $$.value = $1.value <= $3.value;
        $$.type = "boolean";
    }
    | expression LOGICAL_AND expression {
        $$.value = $1.value && $3.value;
        $$.type = "boolean";
    }
    | expression LOGICAL_OR expression {
        $$.value = $1.value || $3.value;
        $$.type = "boolean";
    }
    | LEFT_PAREN expression RIGHT_PAREN {
        $$.value = $2.value;
        $$.type = $2.type;
    }
    | increment_statement {
        $$ = $1;
    }
    ;

function_call:
    IDENTIFIER LEFT_PAREN expression RIGHT_PAREN {
        if(strcmp($1, "amarBiyog") == 0) {
            $$.value = $3.value;
            $$.type = strdup("purno");
        } else {
            $$.value = 0;
            $$.type = strdup("purno");
            fprintf(yyout, "Line %d: Warning - unknown function %s\n", line_num, $1);
        }
    }
    | IDENTIFIER LEFT_PAREN expression COMMA expression RIGHT_PAREN {
        if(strcmp($1, "amarBiyog") == 0) {
            if ($3.value > $5.value) {
                $$.value = $3.value - $5.value;
            } else {
                $$.value = $5.value - $3.value;
            }
            $$.type = strdup("purno");
        } else if(strcmp($1, "jogKoro") == 0) {
            $$.value = $3.value + $5.value;
            $$.type = strdup("purno");
        } else {
            $$.value = 0;
            $$.type = strdup("purno");
            fprintf(yyout, "Line %d: Warning - unknown function %s\n", line_num, $1);
        }
    }
    ;

type:
    TYPE_INT    { $$ = "purno"; }
    | TYPE_CHAR { $$ = "okkhor"; }
    | TYPE_BOOL { $$ = "boolean"; }
    | TYPE_DOUBLE { $$ = "dosomik"; }
    | TYPE_STRING { $$ = "sobdo"; }
    | TYPE_VOID   { $$ = "sunnota"; }
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