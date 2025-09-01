#!/usr/bin/env bash

set -e

nasm -g -f elf64 print.asm -o print.o
gcc -g print.o main.c 
