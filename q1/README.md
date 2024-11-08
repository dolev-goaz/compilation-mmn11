### How to build
* Option I: Batch file(windows only)
    Run `./build_lexer` in the current directory- which generates the q1 executable file.
    
* Option II: Manual compilation
    Compile each lex file in two stages:
    1. execute: `win_flex q1.lex` (or with flex if you're on linux)
    2. execute: `gcc -o q1 lex.yy.c`