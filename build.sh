#!/usr/bin/env bash

set -e

nasm -O3 -f elf64 print.asm -o print.o
gcc -O3 print.o main.c 
