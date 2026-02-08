// Simple kernel for testing bootloader
void kernel_main(void) {
    // Simple kernel that prints a message
    volatile char *video = (volatile char *)0x80000000;
    
    // Simple loop to show execution
    int i;
    for (i = 0; i < 10000000; i++) {
        // Do nothing, just loop
    }
    
    // Infinite loop
    while(1) {
        // Kernel running
    }
}
