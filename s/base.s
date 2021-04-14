.global myno
.global start
.set myno, 0

.section prot, "a" 
.long 0, 1, 2, 3, 4
.long 20, 21, 22, 23
.long 40, 41, 42, 43
.long 60, 61, 62, 63, 64
.long 80, 81, 82, 83
.long 100, 101, 102, 103

.section text, "a"
start:	jmp start
	jmp start
	jmp start
	jmp start
