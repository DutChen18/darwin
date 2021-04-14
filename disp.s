.global disp
.global dkill
.global dclaim

.text
disp:   movl $54, %eax
	movl $1, %ebx
	movl $21523, %ecx
	movl $ws_row, %edx
	int $0x80
	movzwl ws_row, %eax
	movzwl ws_col, %ebx
	movl %ebx, wwidth
	mull %ebx
	movl %eax, wsize

	call csi
	movl $'?', %eax
	call putc
	movl $25, %eax
	call puti
	movl $'l', %eax
	call putc
	call csi
	movl $'2', %eax
	call putc
	movl $'J', %eax
	call putc
	call csi
	movl $'3', %eax
	call putc
	movl $'J', %eax
	call putc

	movl $0, %ebx
	movl $asize, %eax
	mull wsize
disp1:	subl $asize, %eax
	jae dispc
	subl $1, %edx
	jb dispe
dispc:	call drawc
	jmp disp1
dispe:	ret

dkill:	subl $arena, %eax
	movl %eax, %ecx
	addl spsz(%ebx), %ecx
	movl $0, %ebx
	jmp draws0

dclaim:	movl %edx, %ebx
	subl $arena, %eax
	movl %eax, %ecx
	addl spsz(%edx), %ecx
draws0:	mull wsize
draws1:	call drawc
	addl $asize, %eax
	jnc drawsc
	addl $1, %edx
drawsc:	pusha
	divl wsize
	cmpl %eax, %ecx
	popa
	ja draws1
	ret

putc:	pusha
	movl $4, %eax
	movl $1, %ebx
	leal 28(%esp), %ecx
	movl $1, %edx
	int $0x80
	popa
	ret

puti:	pusha
	movl $0, %ecx
puti1:	testl %eax, %eax
	je putie
	movl $0, %edx
	movl $10, %ebx
	divl %ebx
	addl $'0', %edx
	decl %ecx
	movb %dl, buf + 10(%ecx)
	jmp puti1
putie:	movl $4, %eax
	movl $1, %ebx
	imull $-1, %ecx, %edx
	leal buf + 10(%ecx), %ecx
	int $0x80
	popa
	ret

csi:	pushl %eax
	movl $0x1B, %eax
	call putc
	movl $'[', %eax
	call putc
	popl %eax
	ret

drawc:	pusha
	movl $asize, %ecx
	divl %ecx
	movl $0, %edx
	divl wwidth
	
	call csi
	incl %eax
	call puti
	movl $';', %eax
	call putc
	leal 1(%edx), %eax
	call puti
	movl $'H', %eax
	call putc
	
	cmpl $0, %ebx
	je drawd
	movl %ebx, %eax
	subl $sptab, %eax
	movl $spti, %ecx
	movl $0, %edx
	divl %ecx
	addl $'0', %eax
	jmp draw1
drawd:	movl $'.', %eax
draw1:	call putc
	popa
	ret
	
.data
ws_row:	.short 0
ws_col:	.short 0
ws_x:	.short 0
ws_y:	.short 0
wsize:	.long 0
wwidth:	.long 0
buf:	.skip 10
