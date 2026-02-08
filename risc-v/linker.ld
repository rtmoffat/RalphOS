ENTRY(_start)
SECTIONS
{
    . = 0x80000000;

    .text : {
        *(.text.init)
        *(.text)
        *(.text.*)
    }

    .rodata : {
        *(.rodata)
        *(.rodata.*)
    }

    .data : {
        *(.data)
        *(.data.*)
    }

    .bss (NOLOAD) : {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    }

    .stack (NOLOAD) : {
        . = ALIGN(16);
        __stack_bottom = .;
        . = . + 8192;
        __stack_top = .;
    }

    /DISCARD/ : {
        *(.comment)
        *(.gnu*)
        *(.note*)
        *(.eh_frame*)
    }
}
