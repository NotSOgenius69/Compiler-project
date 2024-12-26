%{
#include "bongo.tab.h"
#include <stdio.h>
#include <string.h>
int line_num = 1;
%}

%%
[ \t]+                      /* Skip whitespace */
[\n]                        { line_num++; }

"//".*                      /* Skip single-line comments */
"/*"([^*]|\*+[^*/])*\*+"/" /* Skip multi-line comments */

"shuru"                     { return MAIN; }
"ChalayDen"                 { return FOR; }
"hoyKi"                     { return IF; }
"nahole"                    { return ELSE; }
"nahoyKi"                   { return ELSE_IF; }
"baksho"                    { return FUNCTION; }
"dhoren"                    { return DECLARE; }
"thaman"                    { return BREAK; }
"chalan"                    { return CONTINUE; }
"dekhao"                    { return PRINT; }
"neo"                       { return INPUT; }
"ferot"                     { return RETURN; }
"jotokkhon"                 { return WHILE; }
"kono"                      { return SWITCH; }
"khetre"                    { return CASE; }

"soman"                     { return EQUAL; }
"boro"                      { return GREATER; }
"choto"                     { return LESS; }
"boroSoman"                 { return GREATER_EQUAL; }
"chotoSoman"                { return LESS_EQUAL; }
"jog"                       { return PLUS; }
"biyog"                     { return MINUS; }
"gun"                       { return MULTIPLY; }
"vaag"                      { return DIVIDE; }
"vagsesh"                   { return MODULO; }
"pow"                       { return POWER; }
"ebong"                     { return LOGICAL_AND; }
"othoba"                    { return LOGICAL_OR; }
"ones"                      { return BITWISE_NOT; }
"and"                       { return BITWISE_AND; }
"or"                        { return BITWISE_OR; }
"="                         { return ASSIGN; }
"!="                        { return NOT_EQUAL; }
"|"                         { return LINE_END; }
"barao"                     { return INCREMENT; }
"komao"                     { return DECREMENT; }

"purno"                     { return TYPE_INT; }
"okkhor"                    { return TYPE_CHAR; }
"boolean"                   { return TYPE_BOOL; }
"dosomik"                   { return TYPE_DOUBLE; }
"sobdo"                     { return TYPE_STRING; }
"sunnota"                   { return TYPE_VOID; }

"sotti"                     { return BOOL_TRUE; }
"mithya"                    { return BOOL_FALSE; }

[0-9]+                      { yylval.number = atoi(yytext); return NUMBER; }
[0-9]+"."[0-9]+            { yylval.decimal = atof(yytext); return DECIMAL; }
[a-zA-Z_][a-zA-Z0-9_]*     { yylval.string = strdup(yytext); return IDENTIFIER; }
\"([^\"\\]|\\.)*\"         { yylval.string = strdup(yytext); return STRING_LITERAL; }
\'([^\'\\]|\\.)*\'         { yylval.string = strdup(yytext); return CHAR_LITERAL; }

"("                         { return LEFT_PAREN; }
")"                         { return RIGHT_PAREN; }
"{"                         { return LEFT_BRACE; }
"}"                         { return RIGHT_BRACE; }
"["                         { return LEFT_BRACKET; }
"]"                         { return RIGHT_BRACKET; }
","                         { return COMMA; }
";"                         { return SEMICOLON; }

.                           { fprintf(stderr, "Line %d: Lexical error - unexpected character: %s\n", line_num, yytext); }

%%

int yywrap() {
    return 1;
}