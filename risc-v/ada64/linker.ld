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
        *(.sdata)
        *(.sdata.*)
        *(.data)
        *(.data.*)
    }

    __global_pointer$ = . + 0x800;

    .bss (NOLOAD) : {
        . = ALIGN(8);
        __bss_start = .;
        *(.sbss)
        *(.sbss.*)
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(8);
        __bss_end = .;
    }

    .stack (NOLOAD) : {
        . = ALIGN(16);
        __stack_bottom = .;
        . = . + 16384;
        __stack_top = .;
    }

    /DISCARD/ : {
        *(.comment)
        *(.gnu*)
        *(.note*)
        *(.eh_frame*)
    }
}
