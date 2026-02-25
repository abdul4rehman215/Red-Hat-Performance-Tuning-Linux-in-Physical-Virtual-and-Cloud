// src/cpu_intensive.c
#include <stdio.h>
#include <unistd.h>

int main() {
    printf("Starting CPU-intensive task (PID: %d)\n", getpid());

    // CPU-intensive loop
    for (long i = 0; i < 1000000000; i++) {
        // Perform some calculations
        volatile double result = i * 3.14159 / 2.71828;
    }

    printf("CPU-intensive task completed\n");
    return 0;
}
