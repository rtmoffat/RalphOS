; Simple BIOS Bootloader for x86
; Displays "hello" on screen using BIOS interrupts
; Assemble with: nasm -f bin bootloader.asm -o bootloader.bin
; Test with: qemu-system-x86_64 -drive format=raw,file=bootloader.bin

BITS 16                 ; Start in 16-bit real mode (all x86 bootloaders start here)
ORG 0x7C00              ; BIOS loads bootloader at address 0x7C00

start:
    ; Set up segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00      ; Stack grows downward from bootloader

    ; List disk devices
    call list_drives

    ; Print "hello" string
    mov si, hello_msg
    call print_string

    ; Hang forever
halt:
    hlt
    jmp halt

; Function to print a null-terminated string
; Input: SI = pointer to string
print_string:
    mov ah, 0x0E        ; BIOS teletype function
.loop:
    lodsb               ; Load byte from SI into AL, increment SI
    test al, al         ; Check if null terminator
    jz .done
    int 0x10            ; Call BIOS video interrupt
    jmp .loop
.done:
    ret

; Print a single character in AL
print_char:
    mov ah, 0x0E
    int 0x10
    ret

; Print AL as two hex digits
print_hex_byte:
    push ax
    push bx
    mov bl, al
    shr al, 4
    call print_hex_nibble
    mov al, bl
    and al, 0x0F
    call print_hex_nibble
    pop bx
    pop ax
    ret

print_hex_nibble:
    cmp al, 9
    jbe .digit
    add al, 'A' - 10
    jmp .out
.digit:
    add al, '0'
.out:
    call print_char
    ret

; List BIOS disk devices using int 13h, AH=08h
list_drives:
    mov si, drives_msg
    call print_string

    mov dl, 0x00
    mov cx, 2
.floppy_loop:
    push cx
    call probe_drive
    pop cx
    inc dl
    loop .floppy_loop

    mov dl, 0x80
    mov cx, 0x10
.hdd_loop:
    push cx
    call probe_drive
    pop cx
    inc dl
    loop .hdd_loop

    mov si, newline_msg
    call print_string
    ret

probe_drive:
    push ax
    push dx
    mov ah, 0x08
    int 0x13
    jc .done

    mov al, ' '
    call print_char
    mov al, '0'
    call print_char
    mov al, 'x'
    call print_char

    pop dx
    push dx
    mov al, dl
    call print_hex_byte
.done:
    pop dx
    pop ax
    ret

; Data section
hello_msg db 'hello', 0x0D, 0x0A, 0  ; String with CR, LF, and null terminator
drives_msg db 'drives:', 0
newline_msg db 0x0D, 0x0A, 0

; Fill the rest of the 512-byte sector with zeros
times 510-($-$$) db 0

; Boot signature (required for BIOS to recognize as bootable)
dw 0xAA55
