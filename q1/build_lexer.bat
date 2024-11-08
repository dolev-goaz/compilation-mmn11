@echo off
win_flex q1.lex
gcc -o q1 lex.yy.c
del lex.yy.c