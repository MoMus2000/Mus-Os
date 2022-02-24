[BITS 16]
[ORG 0x7e00]

start:
	mov [DriveId], dl
	mov eax, 0x80000000
	cpuid
	cmp eax, 0x80000001
	jb NotSupport
	mov eax, 0x80000001
	cpuid 
	test edx, (1<<29)
	jz NotSupport
	test edx, (1<<26)
	jz NotSupport

LoadKernel:
    mov si,ReadPacket
    mov word[si], 0x10
    mov word[si+2], 100
    mov word[si+4], 0
    mov word[si+6], 0x1000
    mov dword[si+8], 6
    mov dword[si+0xc], 0
    mov dl,[DriveId]
    mov ah,0x42
    int 0x13
    jc ReadError

GetMemoryInfoStart:
    mov eax,0xe820
    mov edx,0x534d4150
    mov ecx,20
    mov edi,0x9000
    xor ebx,ebx
    int 0x15
    jc NotSupport

GetMemInfo:
	add edi,20
    mov eax,0xe820
    mov edx,0x534d4150
    mov ecx,20
    int 0x15
    jc print
    test ebx,ebx
    jnz GetMemInfo


GetMemDone:
	jmp print

print:
	mov ah,0x13
    mov al,1
    mov bx,0xa
    xor dx,dx
    mov bp,Message
    mov cx,MessageLen 
    int 0x10


TestA20:
    mov ax, 0xffff
    mov es, ax
    mov word[ds:0x7c00], 0xa200
    cmp word[es:0x7c10], 0xa200
    jne SetA20LineDone
    mov word[ds:0x7c00], 0xb200
    cmp word[es:0x7c10], 0xb200
    je end



SetA20LineDone:
    xor ax, ax
    mov es, ax
    mov ah,0x13
    mov al,1
    mov bx,0xa
    xor dx,dx
    mov bp,Message_A20
    mov cx,MessageLen_A20 
    int 0x10    


ReadError:
NotSupport:
end:
	hlt
	jmp end

DriveId: db 0
Message:    db "Opened loader file, long mode supported, kernel is loaded, got mem info"
MessageLen: equ $-Message
Message_A20:    db "A20 Line done"
MessageLen_A20: equ $-Message_A20
ReadPacket: times 16 db 0