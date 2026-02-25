// src/memory_test.c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define ARRAY_SIZE 10000000
#define ITERATIONS 100

int main() {
    printf("Starting memory access test (PID: %d)\n", getpid());

    // Allocate large array
    int *array = malloc(ARRAY_SIZE * sizeof(int));
    if (!array) {
        printf("Memory allocation failed\n");
        return 1;
    }

    // Sequential access pattern
    printf("Sequential access pattern...\n");
    for (int iter = 0; iter < ITERATIONS; iter++) {
        for (int i = 0; i < ARRAY_SIZE; i++) {
            array[i] = i * 2;
        }
    }

    // Random access pattern
    printf("Random access pattern...\n");
    for (int iter = 0; iter < ITERATIONS; iter++) {
        for (int i = 0; i < ARRAY_SIZE / 10; i++) {
            int index = rand() % ARRAY_SIZE;
            array[index] = index * 3;
        }
    }

    free(array);
    printf("Memory test completed\n");
    return 0;
}
