#!/bin/sh
ASIZE=32768

as --32 -march=i386 --defsym asize=$ASIZE darwin.s -o darwin.o || exit 1
ld -melf_i386 darwin.o -o darwin || exit 1
# as --32 -march=i386 darwin.s -o darwin.o
# objcopy --redefine-sym _start=_start2 darwin.o 
# gcc -g -m32 -march=i386 darwin.o disp.c -o darwin -Wl,-e_start2 -I/usr/i686-linux-gnu/include

for file in s/*.s; do
	file="${file%.s}"
	as --32 -march=i386 "$file.s" -o "$file.o" || exit 1
	ld -melf_i386 --defsym asize=$ASIZE -T link.ld "$file.o" -o "$file.bin" || exit 1
done

if [ "$#" -ne 0 ]; then
	gnome-terminal --full-screen --zoom=0.75 -- sh -c 'sleep 0.1; ./darwin $@' -- $@
fi
