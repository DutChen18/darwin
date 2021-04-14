.global _start
.global maxsp
.global maxor
.global nosp
.global noor
.global sptab
.global ortab

.set maxsp, 10
.set maxor, asize / 2
.set maxs, asize / 128

.struct 0
spno:	.skip 4
spsz:	.skip 4
sporg:	.skip 4
spres:	.skip 4
spprot:	.skip maxs * 4
spdata:	.skip maxs
.set spti, .

.struct 0
orbot:	.skip 4
orsp:	.skip 4
.set orti, .

.text
_start:	addl $8, %esp
	jmp init
read:	movl $5, %eax
	movl $0, %ecx
	int $0x80
	movl %eax, %ebx
	movl nosp, %esi
	incl nosp
	imull $spti, %esi
	movl $3, %eax
	leal sptab + 0(%esi), %ecx
	movl $16, %edx
	int $0x80
	movl $3, %eax
	leal sptab + spprot(%esi), %ecx
	movl sptab + spres(%esi), %edx
	leal (, %edx, 4), %edx
	int $0x80
	movl $3, %eax
	leal sptab + spdata(%esi), %ecx
	movl sptab + spsz(%esi), %edx
	int $0x80
	shrl $2, %edx
	cmpl sptab + spres(%esi), %edx
	ja init
	movl %edx, sptab + spres(%esi)
init:	popl %ebx
	cmpl $0, %ebx
	jne read

	movl $0, %esi
	jmp sort
sort1:	pushl %eax
	incl %esi
sort:	cmpl %esi, nosp
	je load
	imull $spti, %esi, %eax
	addl $sptab, %eax
	movl %esi, %edi
insert:	subl $1, %edi
	jb sort1
	movl spsz(%eax), %ecx
	movl (%esp, %edi, 4), %ebx
	cmpl %ecx, spsz(%ebx)
	jb insert
	xchgl (%esp, %edi, 4), %eax
	jmp insert

load:	call disp
	movl nosp, %ebx
	jmp load1
load0:	popl %ebx
load1:	subl $1, %ebx
	jb run
	movl $asize, %eax
	shrl $1, %eax
	movl $0, %edx
	divl nosp
	popl %edx
	pushl %ebx
	movl %eax, %ebx
load2:	subl spsz(%edx), %ebx
	jb load0
loadr:	pushl %edx
	movl seed, %eax
	movl $1103515245, %edx
	mull %edx
	addl $12345, %eax
	movl %eax, seed
	movl $0, %edx
	movl $asize, %ecx
	divl %ecx
	leal arena(%edx), %eax
	popl %edx
	call ornew
	jc loadr
	movl spsz(%edx), %ecx
	leal spdata(%edx), %esi
	movl %eax, %edi
	rep movsb
	jmp load2

run:	call xfer
	movl $1, %eax
	movl $0, %ebx
	int $0x80

probe:	pusha
	call orget
	cmpl $0, %edx
	je probex
	movl %eax, %edi
	movl orbot(%edx), %eax
	subl %eax, %edi
	movl orsp(%edx), %edx
	movl spres(%edx), %ebp
	shll $2, %ebp
probe1:	subl $4, %ebp
	jb probee
	cmpl %edi, spprot(%edx, %ebp)
	jne probe1
	movl base, %esp

xfer:	movl %eax, %esi
	addl sporg(%edx), %eax
	movl $arena, %edi
	movl %esp, base
	pushl $claim
	pushl $kill
	pushl $probe
	pushl %edx
	pushl $0x202
	popf
	movl %esp, %ebp
	pushl %eax
	xorl %eax, %eax
	xorl %ebx, %ebx
	xorl %ecx, %ecx
	xorl %edx, %edx
	ret

probee:	movl spno(%edx), %edx
probex:	movl %ebx, 16(%esp)
	movl %ecx, 24(%esp)
	movl %edx, 20(%esp)
	popa
	testl %edx, %edx
	ret


kill:	pushf
	pusha
	pushl %ebp
	call orget
	popl %ebp
	cmpl $0, %edx
	je killx
	cmpl -4(%ebp), %ebx
	jae kill1
	cmpl -4(%ebp), %ecx
	jae killx
kill1:	decl noor
	movl noor, %ebp
	imull $orti, %ebp
	movl ortab + orsp(%ebp), %ebx
	xchgl %ebx, orsp(%edx)
	movl ortab + orbot(%ebp), %eax
	xchgl %eax, orbot(%edx)
	call dkill
killx:	popa
	popf
	ret

claim:	pushf
	pusha
	movl 0(%ebp), %edx
	call ornew
	popa
	popf
	ret

ornew:	pusha
	call orget
	cmpl $0, %edx
	jne ornewe
	subl %eax, %ecx
	movl 20(%esp), %edx
	subl spsz(%edx), %ecx
	jb ornewe
	popa
	pusha
	call dclaim
	popa
	movl noor, %ebp
	incl noor
	imull $orti, %ebp
	movl %eax, ortab + orbot(%ebp)
	movl %edx, ortab + orsp(%ebp)
	clc
	ret
ornewe:	popa
	stc
	ret

orget:	movl $arena, %ebx
	movl $arena + asize, %ecx
	movl $0, %edx
	movl noor, %ebp
	imull $orti, %ebp
orget1:	subl $orti, %ebp
	jb orgete
	movl ortab + orbot(%ebp), %esi
	movl ortab + orsp(%ebp), %edi
	cmpl %esi, %eax
	jb orget2
	addl spsz(%edi), %esi
	cmpl %esi, %eax
	jae orget3
	leal ortab(%ebp), %edx
	jmp orget1
orget2:	cmpl %esi, %ecx
	jb orget1
	movl %esi, %ecx
	jmp orget1
orget3:	cmpl %esi, %ebx
	ja orget1
	movl %esi, %ebx
	jmp orget1
orgete:	ret

.include "disp.s"

.data
nosp:	.long 0
noor:	.long 0
seed:	.long 0
base:	.long 0

.comm sptab, maxsp * spti
.comm ortab, maxor * orti

.section arena, "awx", @nobits
.skip asize
