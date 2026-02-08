option casemap:none

.data
welcome_msg dw 'W','e','l','c','o','m','e',' ','t','o',' ','R','a','l','p','h','O','S',13,10,0

.code
public EFI_MAIN

EFI_MAIN proc
    sub rsp, 28h
    mov rbx, rdx

    mov rax, [rbx + 40h]
    mov rcx, rax
    lea rdx, welcome_msg
    mov rax, [rax + 8]
    call rax

    mov rax, [rbx + 60h]
    mov rax, [rax + 0F8h]
    mov rcx, 10000000
    call rax

    mov rax, [rbx + 58h]
    mov rax, [rax + 68h]
    mov rcx, 2
    xor rdx, rdx
    xor r8, r8
    xor r9, r9
    call rax

    xor eax, eax
    add rsp, 28h
    ret
EFI_MAIN endp

end
