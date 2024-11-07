@echo off
win_flex -o %1.cpp %1
gcc -Wno-register -o %1.exe %1.cpp
echo output file: %1.exe
del %1.cpp