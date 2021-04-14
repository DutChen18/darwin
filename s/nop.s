.global myno
.global start
.set myno, 1

.section text, "a"
start:	movl %edi, %eax
l1:	call *probe(%ebp)
	incl %eax
	jmp l1
