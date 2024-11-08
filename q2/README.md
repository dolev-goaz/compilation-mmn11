### How to build
* Option I: Batch file(windows only)
    Run `./build_lexer` in the current directory- which generates the cla executable file.
    
* Option II: Manual compilation
    Compile each lex file in two stages:
    1. execute: `win_flex cla.lex`
    2. execute: `gcc -o cla lex.yy.c`