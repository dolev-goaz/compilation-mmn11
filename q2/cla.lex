%{

#define MAX_STRING_SIZE 512
#define MAX_CAST_TYPE_SIZE 6 // float = 5 + 1 terminating
#define MAX_RELOP_SIZE 3 // >= = 2 + 1 terminating

typedef enum {
  // keywords
  KW_BREAK = 1,
  KW_CASE,
  KW_DEFAULT,
  KW_ELSE,
  KW_FLOAT,
  KW_IF,
  KW_INPUT,
  KW_INT,
  KW_OUTPUT,
  KW_SWITCH,
  KW_WHILE,

  // symbols
  LPAREN,
  RPAREN,
  LCURLY,
  RCURLY,
  COMMA,
  COLON,
  SEMICOLON,
  EQ,

  // operators
  RELOP,
  ADDOP,
  MULOP,
  OR,
  AND,
  NOT,
  CAST,

  // identifier & number
  IDENTIFIER,
  NUMBER
} TokenType;

const char* token_strings[] = {
    "",
    "BREAK",
    "CASE",
    "DEFAULT",
    "ELSE",
    "FLOAT",
    "IF",
    "INPUT",
    "INT",
    "OUTPUT",
    "SWITCH",
    "WHILE",
    "LPAREN",
    "RPAREN",
    "LCURLY",
    "RCURLY",
    "COMMA",
    "COLON",
    "SEMICOLON",
    "EQ",
    "RELOP",
    "ADDOP",
    "MULOP",
    "OR",
    "AND",
    "NOT",
    "CAST",
    "IDENTIFIER",
    "NUMBER"
};


union token_attribute {
  float numeric_value;
  char string_value[MAX_STRING_SIZE];
  char cast_type[MAX_CAST_TYPE_SIZE];
  char single_op;
  char relop[MAX_RELOP_SIZE];
} token_attribute;

#include <string.h> 
#include <stdlib.h>
int line = 1;
%}

%option noyywrap
%option yylineno

/* exclusive start conditions -- deal with two types of comments */ 
%x C_STYLE_COMMENT

%%
 /* keywords */
break   { return KW_BREAK; }
case    { return KW_CASE; }
default { return KW_DEFAULT; }
else    { return KW_ELSE; }
float   { return KW_FLOAT; }
if      { return KW_IF; }
input   { return KW_INPUT; }
int     { return KW_INT; }
output  { return KW_OUTPUT; }
switch  { return KW_SWITCH; }
while   { return KW_WHILE; }

 /* symbols */
\( { return LPAREN; }
\) { return RPAREN; } 
\{ { return LCURLY; }
\} { return RCURLY; }
,  { return COMMA; }
:  { return COLON; }
;  { return SEMICOLON; } 
=  { return EQ; }

 /* operators */
"!="|[><]|[>=<]=  { strcpy(token_attribute.relop, yytext); return RELOP; }
[+-]              { token_attribute.single_op = yytext[0]; return ADDOP; }
[*/]              { token_attribute.single_op = yytext[0]; return MULOP; }
"||"              { return OR; }
&&                { return AND; }
!                 { return NOT; }
cast<(int|float)> { char* start = yytext + 5; size_t read_count = strlen(yytext) - 6; /* copy from offset 5(after <), and we ignore 6 characters(cast<>) */
                    strncpy(token_attribute.cast_type, start, read_count);
                    token_attribute.cast_type[read_count] = 0;
                    return CAST; }

[0-9]+(\.?[0-9]*)     { token_attribute.numeric_value = atof(yytext); return NUMBER; }
[a-zA-Z][a-zA-Z0-9]*  { strcpy (token_attribute.string_value, yytext); return IDENTIFIER; }

[\t\r ]+  { /* skip white space */ }
[\n]+     { line += yyleng; /* line += strlen(yytext); */ }

"/*"  { BEGIN(C_STYLE_COMMENT); }
<C_STYLE_COMMENT>[^*\n]+    { /* skip chars in comment */ }
<C_STYLE_COMMENT>"*"+"/"  { BEGIN(0); }  // better
<C_STYLE_COMMENT>[\n]+     { line += yyleng; }
<C_STYLE_COMMENT>"*"+    { /* skip  *'s. */ } 

.          { fprintf (stderr, "line %d: unrecognized token %c(%x)\n", 
                               line, yytext[0], yytext[0]); }
							   
%%


void print_token_attributes(TokenType type) {
    switch (type) {
        case NUMBER:
            printf("%f", token_attribute.numeric_value);
            break;
        case IDENTIFIER:
            printf("%s", token_attribute.string_value);
            break;
        case CAST:
            printf("%s", token_attribute.cast_type);
            break;
        case ADDOP:
        case MULOP:
            printf("%c", token_attribute.single_op);
            break;
        case RELOP:
            printf("%s", token_attribute.relop);
            break;
    } 
}

void print_token(TokenType type) {
    const char* token = token_strings[type];
    printf("%s, %s,", token, yytext);
    print_token_attributes(type);
}

// TODO: error token
int main (int argc, char **argv)
{
    int token;

    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file name>\n", argv [0]);
        exit (1);
    }

    yyin = fopen(argv[1], "r");

    while ((token = yylex()) != 0){
        print_token(token);
        putchar('\n');
    }
   fclose(yyin);
   exit(0);
}