.global myno
.global start
.set myno, 2

.section prot, "a" 
.long 0

.section text, "a"
data:	.long 0
start:	movl data(%esi), %eax
	subl $1, %eax
	jae l1
	movl $asize - 1, %eax
l1:	movl %eax, data(%esi)
	addl %edi, %eax
	call *probe(%ebp)
	cmpl $myno, %edx
	je start
	testl %edx, %edx
	je start
	call *kill(%ebp)
	jmp start
