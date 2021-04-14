.global myno
.global start
.set myno, 8

.section prot, "a" 
.long 0, end - data - 1

.section text, "a"
data:	.long -1
start:	movl data(%esi), %eax
	incl %eax
	andl $asize - 1, %eax
	movl %eax, data(%esi)
	addl %edi, %eax
l1:	call *probe(%ebp)
	je l2
	cmpl $myno, %edx
	je start
	call *kill(%ebp)
l2:	movl %ebx, %eax
	subl %ecx, %ebx
	movl $end - data, %ecx
	addl %ecx, %ebx
	jc start
	call *claim(%ebp)
	movl %eax, %edi
	rep movsb
	jmp l1
end:
