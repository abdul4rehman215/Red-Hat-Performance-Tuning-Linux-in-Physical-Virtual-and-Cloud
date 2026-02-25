// src/io_test.c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

#define BUFFER_SIZE 4096
#define NUM_FILES 100
#define WRITE_SIZE 1024*1024 // 1MB per file

int main() {
    printf("Starting I/O test (PID: %d)\n", getpid());

    char buffer[BUFFER_SIZE];
    char filename[256];

    // Fill buffer with test data
    memset(buffer, 'A', BUFFER_SIZE);

    // Sequential write test
    printf("Sequential write test...\n");
    for (int i = 0; i < NUM_FILES; i++) {
        sprintf(filename, "testfile_%d.dat", i);
        int fd = open(filename, O_CREAT | O_WRONLY | O_TRUNC, 0644);
        if (fd < 0) continue;

        for (int j = 0; j < WRITE_SIZE / BUFFER_SIZE; j++) {
            write(fd, buffer, BUFFER_SIZE);
        }
        close(fd);
    }

    // Sequential read test
    printf("Sequential read test...\n");
    for (int i = 0; i < NUM_FILES; i++) {
        sprintf(filename, "testfile_%d.dat", i);
        int fd = open(filename, O_RDONLY);
        if (fd < 0) continue;

        while (read(fd, buffer, BUFFER_SIZE) > 0) {
            // Process data
        }
        close(fd);
    }

    // Cleanup
    for (int i = 0; i < NUM_FILES; i++) {
        sprintf(filename, "testfile_%d.dat", i);
        unlink(filename);
    }

    printf("I/O test completed\n");
    return 0;
}
