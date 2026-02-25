// src/comprehensive_test.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
#include <fcntl.h>
#include <string.h>

#define ARRAY_SIZE 1000000
#define NUM_THREADS 4

void* cpu_worker(void* arg) {
    int thread_id = *(int*)arg;
    printf("CPU worker %d started\n", thread_id);

    for (long i = 0; i < 100000000; i++) {
        volatile double result = i * 3.14159 / 2.71828;
    }

    return NULL;
}

void* memory_worker(void* arg) {
    int thread_id = *(int*)arg;
    printf("Memory worker %d started\n", thread_id);

    int* array = malloc(ARRAY_SIZE * sizeof(int));
    for (int i = 0; i < 1000; i++) {
        for (int j = 0; j < ARRAY_SIZE; j++) {
            array[j] = j * i;
        }
    }
    free(array);

    return NULL;
}

void* io_worker(void* arg) {
    int thread_id = *(int*)arg;
    printf("I/O worker %d started\n", thread_id);

    char filename[256];
    char buffer[4096];
    sprintf(filename, "worker_%d.dat", thread_id);

    int fd = open(filename, O_CREAT | O_WRONLY | O_TRUNC, 0644);
    for (int i = 0; i < 1000; i++) {
        write(fd, buffer, sizeof(buffer));
    }
    close(fd);
    unlink(filename);

    return NULL;
}

int main() {
    printf("Starting comprehensive performance test (PID: %d)\n", getpid());

    pthread_t threads[NUM_THREADS * 3];
    int thread_ids[NUM_THREADS * 3];

    // Create CPU workers
    for (int i = 0; i < NUM_THREADS; i++) {
        thread_ids[i] = i;
        pthread_create(&threads[i], NULL, cpu_worker, &thread_ids[i]);
    }

    // Create memory workers
    for (int i = 0; i < NUM_THREADS; i++) {
        thread_ids[NUM_THREADS + i] = i;
        pthread_create(&threads[NUM_THREADS + i], NULL, memory_worker, &thread_ids[NUM_THREADS + i]);
    }

    // Create I/O workers
    for (int i = 0; i < NUM_THREADS; i++) {
        thread_ids[2 * NUM_THREADS + i] = i;
        pthread_create(&threads[2 * NUM_THREADS + i], NULL, io_worker, &thread_ids[2 * NUM_THREADS + i]);
    }

    // Wait for all threads to complete
    for (int i = 0; i < NUM_THREADS * 3; i++) {
        pthread_join(threads[i], NULL);
    }

    printf("Comprehensive test completed\n");
    return 0;
}
