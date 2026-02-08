; UEFI Bootloader - Prints "hello" to screen
; Assemble with: nasm -f bin bootloader.asm -o BOOTX64.EFI

BITS 64

; PE32+ Header for UEFI
org 0x00400000

DOS_HEADER:
    dw 'MZ'                     ; DOS signature
    times 58 db 0               ; DOS stub
    dd PE_HEADER - DOS_HEADER   ; PE header offset

PE_HEADER:
    dd 'PE'                     ; PE signature
    dw 0
    
COFF_HEADER:
    dw 0x8664                   ; Machine (x64)
    dw 1                        ; Number of sections
    dd 0                        ; TimeDateStamp
    dd 0                        ; PointerToSymbolTable
    dd 0                        ; NumberOfSymbols
    dw OPTIONAL_HEADER_END - OPTIONAL_HEADER ; SizeOfOptionalHeader
    dw 0x206                    ; Characteristics (executable, large address aware)

OPTIONAL_HEADER:
    dw 0x20b                    ; Magic (PE32+)
    db 0                        ; MajorLinkerVersion
    db 0                        ; MinorLinkerVersion
    dd CODE_END - CODE_START    ; SizeOfCode
    dd 0                        ; SizeOfInitializedData
    dd 0                        ; SizeOfUninitializedData
    dd ENTRY - DOS_HEADER       ; AddressOfEntryPoint
    dd CODE_START - DOS_HEADER  ; BaseOfCode
    dq 0x00400000               ; ImageBase
    dd 0x1000                   ; SectionAlignment
    dd 0x200                    ; FileAlignment
    dw 0                        ; MajorOperatingSystemVersion
    dw 0                        ; MinorOperatingSystemVersion
    dw 0                        ; MajorImageVersion
    dw 0                        ; MinorImageVersion
    dw 0                        ; MajorSubsystemVersion
    dw 0                        ; MinorSubsystemVersion
    dd 0                        ; Win32VersionValue
    dd IMAGE_END - DOS_HEADER   ; SizeOfImage
    dd HEADERS_END - DOS_HEADER ; SizeOfHeaders
    dd 0                        ; CheckSum
    dw 10                       ; Subsystem (EFI application)
    dw 0                        ; DllCharacteristics
    dq 0                        ; SizeOfStackReserve
    dq 0                        ; SizeOfStackCommit
    dq 0                        ; SizeOfHeapReserve
    dq 0                        ; SizeOfHeapCommit
    dd 0                        ; LoaderFlags
    dd 0                        ; NumberOfRvaAndSizes

OPTIONAL_HEADER_END:

SECTION_TABLE:
    db '.text', 0, 0, 0         ; Name
    dd CODE_END - CODE_START    ; VirtualSize
    dd CODE_START - DOS_HEADER  ; VirtualAddress
    dd CODE_END - CODE_START    ; SizeOfRawData
    dd CODE_START - DOS_HEADER  ; PointerToRawData
    dd 0                        ; PointerToRelocations
    dd 0                        ; PointerToLinenumbers
    dw 0                        ; NumberOfRelocations
    dw 0                        ; NumberOfLinenumbers
    dd 0x60000020               ; Characteristics (code, executable, readable)

HEADERS_END:

align 512, db 0

CODE_START:

ENTRY:
    ; RCX = EFI_HANDLE ImageHandle
    ; RDX = EFI_SYSTEM_TABLE *SystemTable
    
    sub rsp, 40                 ; Shadow space + alignment
    
    ; Save SystemTable pointer
    mov r15, rdx
    
    ; Get ConOut (Simple Text Output Protocol)
    ; ConOut is at offset 64 in EFI_SYSTEM_TABLE
    mov rbx, [rdx + 64]
    
    ; Clear screen
    ; ConOut->ClearScreen(ConOut)
    mov rcx, rbx                ; this pointer
    mov rax, [rbx + 48]         ; ClearScreen function pointer
    call rax
    
    ; Print "hello"
    ; ConOut->OutputString(ConOut, L"hello")
    mov rcx, rbx                ; this pointer
    lea rdx, [rel hello_msg]    ; pointer to string
    mov rax, [rbx + 8]          ; OutputString function pointer
    call rax
    
    ; Return EFI_SUCCESS
    xor rax, rax
    
    add rsp, 40
    ret

hello_msg:
    dw 'h', 'e', 'l', 'l', 'o', 0

CODE_END:

align 512, db 0

IMAGE_END: