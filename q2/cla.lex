%{
// table printing
#define TRUNCATE_SIZE 3
#define TOKEN_WIDTH 15
#define LEXEME_WIDTH 20
#define ATTRIBUTE_WIDTH 20

// buffer sizes for attributes
#define MAX_STRING_SIZE 512
#define MAX_CAST_TYPE_SIZE 6 // float = 5 + 1 terminating
#define MAX_RELOP_SIZE 3 // >= = 2 + 1 terminating

// #define USE_STDOUT // can toggle this on or off
#ifdef USE_STDOUT
    #define OUTPUT_STREAM stdout
#else
    #define OUTPUT_STREAM yyout
    #define OUTPUT_FILENAME "output.txt"
#endif

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
  NUMBER,

  // unknown token
  UNKNOWN
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
    "NUMBER",
    "UNKNOWN"
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
<C_STYLE_COMMENT>"*"+"/"  { BEGIN(INITIAL); }  // better
<C_STYLE_COMMENT>[\n]+     { line += yyleng; }
<C_STYLE_COMMENT>"*"+    { /* skip  *'s. */ } 

. { return UNKNOWN; }
							   
%%

// prints a string at the center of 'width', padded by white-spaces
void print_centered(const char* str, size_t width) {
    size_t length = strlen(str);
    if (length > width) {
        // leave space for truncation, and separator
        for (int i = 0; i < width - TRUNCATE_SIZE - 1; i++) {
            fputc(str[i], OUTPUT_STREAM);
        }
        for (int i = 0; i < TRUNCATE_SIZE; i++) {
            fputc('.', OUTPUT_STREAM);
        }
        fputc(' ', OUTPUT_STREAM); // separator
        return;
    }

    size_t lpadding = (width - length) / 2;
    size_t rpadding = width - length - lpadding;
    fprintf(OUTPUT_STREAM, "%*s%.*s%*s", lpadding, "", length, str, rpadding, "");
}

// prints the header of the 'token info table'
void print_header() {
    print_centered("token", TOKEN_WIDTH);
    print_centered("lexeme", LEXEME_WIDTH);
    print_centered("attribute", ATTRIBUTE_WIDTH);
    fputc('\n', OUTPUT_STREAM);

    print_centered("-----", TOKEN_WIDTH);
    print_centered("------", LEXEME_WIDTH);
    print_centered("---------", ATTRIBUTE_WIDTH);
    fputc('\n', OUTPUT_STREAM);
}

// gets called when an unknown token was found. Error message
void print_unknown_token() {
    fprintf(stderr, "Unrecognized token '%c'(%d) at line %d.", *yytext, *yytext, line);
}

// extracts the relevant token attribute and prints it, centered.
void print_token_attributes(TokenType type) {
    char attribute_str[MAX_STRING_SIZE]; // longest buffer
    switch (type) {
        case NUMBER:
            snprintf(attribute_str, sizeof(attribute_str), "%.6g", token_attribute.numeric_value);
            break;
        case IDENTIFIER:
            snprintf(attribute_str, sizeof(attribute_str), "%s", token_attribute.string_value);
            break;
        case CAST:
            snprintf(attribute_str, sizeof(attribute_str), "%s", token_attribute.cast_type);
            break;
        case ADDOP:
        case MULOP:
            snprintf(attribute_str, sizeof(attribute_str), "%c", token_attribute.single_op);
            break;
        case RELOP:
            snprintf(attribute_str, sizeof(attribute_str), "%s", token_attribute.relop);
            break;
        default:
            attribute_str[0] = '\0';  // unexpected type
            break;
    }
    print_centered(attribute_str, ATTRIBUTE_WIDTH);
}

// prints the data of the token
void print_token(TokenType type) {
    if (type == UNKNOWN) {
        print_unknown_token();
        return;
    }
    const char* token = token_strings[type];
    print_centered(token, TOKEN_WIDTH);
    print_centered(yytext, LEXEME_WIDTH);
    print_token_attributes(type);
}

// if the filename doesnt end with ".ou", exit the program.
void assert_validate_file_extension(const char* filename) {
    const char* dot = strrchr(filename, '.');
    if (dot && (strcmp(dot + 1, "ou") == 0)) {
        // dot exists, extension matches
        return;
    }
    fprintf(stderr, "ERROR: Input file extension should be .ou\n", filename);
    exit (1);
}

int main (int argc, char **argv)
{
    TokenType token;
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <input file name>.ou\n", argv [0]);
        exit (1);
    }
    assert_validate_file_extension(argv[1]);

#ifndef USE_STDOUT
    // if we use file output, open the file handler
    yyout = fopen(OUTPUT_FILENAME, "w");
    if (!yyout) {
        fprintf(stderr, "Error while opening output file %s\n", OUTPUT_FILENAME);
        return 1;
    }
#endif


    yyin = fopen(argv[1], "r");

    print_header();
    while ((token = yylex()) != 0){
        print_token(token);
        fputc('\n', yyout);
    }
   fclose(yyin);

#ifndef USE_STDOUT
    fclose(yyout);
#endif

   exit(0);
}
