@echo off
win_flex -o %1.c %1
gcc -o %1.exe %1.c
echo output file: %1.exe
del %1.c