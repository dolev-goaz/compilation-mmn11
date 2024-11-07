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

union {
  double numeric_value;
  char string_value[MAX_STRING_SIZE];
  char cast_type[MAX_CAST_TYPE_SIZE];
  char single_op;
  char relop[MAX_RELOP_SIZE];
} attribute;

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
"!="|[><]|[>=<]=  { strcpy(attribute.relop, yytext); return RELOP; }
[+-]              { attribute.single_op = yytext[0]; return ADDOP; }
[*/]              { attribute.single_op = yytext[0]; return MULOP; }
"||"              { return OR; }
&&                { return AND; }
!                 { return NOT; }
cast<(int|float)> { char* start = yytext + 5; size_t read_count = strlen(yytext) - 6; /* copy from offset 5(after <), and we ignore 6 characters(cast<>) */
                    strncpy(attribute.cast_type, start, read_count);
                    attribute.cast_type[read_count] = 0;
                    return CAST; }

[0-9]+(\.?[0-9]*)     { attribute.numeric_value = atof(yytext); return NUMBER; }
[a-zA-Z][a-zA-Z0-9]*  { strcpy (attribute.string_value, yytext); return IDENTIFIER; }

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

int main (int argc, char **argv)
{
   extern FILE *yyin;
   int token;

   if (argc != 2) {
      fprintf(stderr, "Usage: %s <input file name>\n", argv [0]);
      exit (1);
   }

   yyin = fopen (argv[1], "r");

  // TODO: test the tokenizing
   while ((token = yylex ()) != 0) {}
  //    switch (token) {
	//  case NUM: printf("NUMBER : %d\n", attribute.ival);
	//               break;
  //        case ID:     printf ("ID  : %s\n", attribute.name);
	//               break;
	//  case STRING: printf ("STRING: %s\n", attribute.str);
	//               break;
  //        default:     fprintf (stderr, "error ... \n"); exit (1);
  //    } 
   fclose (yyin);
   exit (0);
}
