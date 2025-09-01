#!/usr/bin/env bash

set -e

nasm -f elf64 print.asm -o print.o
gcc print.o main.c 
