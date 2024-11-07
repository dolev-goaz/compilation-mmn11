%{
const char *number_to_roman[] = {
    "I", "II", "III", "IV", "V",
    "VI", "VII", "VIII", "IX", "X"
};

#include <stdlib.h>

%}

%option noyywrap

%%
[0-9]{2,}   { printf("%s", yytext); }
[1-9]       { printf("%s", number_to_roman[atoi(yytext) - 1]); }
.           { putchar(*yytext); }	   
%%

int main (int argc, char **argv)
{
    if (argc > 2) {
        fprintf(stderr, "Usage: %s <input file name>\n", argv [0]);
        exit (1);
    }
    if (argc == 2) {
        yyin = fopen (argv[1], "r");
    }

    if (!yyin) {
        const char* message = (argc == 2)? "Error opening file": "No file provided";
        printf("%s. Using stdin\n", message);
        yyin = stdin;
    }

    yylex(); // since there are no returns, it will just keep lexing
    return 0;
}
