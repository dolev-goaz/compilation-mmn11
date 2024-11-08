@echo off
win_flex cla.lex
gcc -o cla lex.yy.c
del lex.yy.c