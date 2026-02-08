// Simple kernel for testing bootloader
#define UART0_BASE 0x10000000u
#define UART0_THR (UART0_BASE + 0x00u)
#define UART0_LSR (UART0_BASE + 0x05u)
#define UART_LSR_THRE 0x20u

#define CLINT_MTIME_LOW 0x0200BFF8u
#define CLINT_MTIME_HIGH 0x0200BFFCu
#define TIMEBASE_HZ 10000000u

#define QEMU_TEST_BASE 0x100000u
#define QEMU_TEST_POWEROFF 0x5555u

static inline void uart_putc(char c) {
    volatile unsigned char *lsr = (volatile unsigned char *)UART0_LSR;
    volatile unsigned char *thr = (volatile unsigned char *)UART0_THR;
    while ((*lsr & UART_LSR_THRE) == 0) {
        // Wait for transmit holding register to empty.
    }
    *thr = (unsigned char)c;
}

static void uart_puts(const char *s) {
    while (*s) {
        if (*s == '\n') {
            uart_putc('\r');
        }
        uart_putc(*s++);
    }
}

static unsigned long long read_mtime(void) {
    volatile unsigned int *mtime_low = (volatile unsigned int *)CLINT_MTIME_LOW;
    volatile unsigned int *mtime_high = (volatile unsigned int *)CLINT_MTIME_HIGH;
    unsigned int hi1;
    unsigned int lo;
    unsigned int hi2;

    do {
        hi1 = *mtime_high;
        lo = *mtime_low;
        hi2 = *mtime_high;
    } while (hi1 != hi2);

    return ((unsigned long long)hi1 << 32) | lo;
}

static void delay_seconds(unsigned int seconds) {
    unsigned long long start = read_mtime();
    unsigned long long target = start + ((unsigned long long)seconds * TIMEBASE_HZ);
    while (read_mtime() < target) {
        // Busy wait.
    }
}

static void poweroff(void) {
    volatile unsigned int *test = (volatile unsigned int *)QEMU_TEST_BASE;
    *test = QEMU_TEST_POWEROFF;
    while (1) {
        // If poweroff fails, halt here.
    }
}

void kernel_main(void) {
    uart_puts("RalphOS: hello from RV32!\n");

    delay_seconds(10);
    uart_puts("RalphOS: shutting down.\n");
    poweroff();
}
