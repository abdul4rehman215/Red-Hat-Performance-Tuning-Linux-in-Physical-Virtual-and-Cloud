#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>

void inefficient_file_operations() {
    char filename[] = "perf_test.txt";
    int fd;
    char data[] = "X";

    printf("Starting inefficient file operations...\n");

    // Inefficient: Opening and closing file multiple times
    for (int i = 0; i < 1000; i++) {
        fd = open(filename, O_CREAT | O_WRONLY | O_APPEND, 0644);
        if (fd != -1) {
            write(fd, data, 1);
            close(fd);
        }
    }

    unlink(filename);
    printf("Inefficient operations completed\n");
}

void efficient_file_operations() {
    char filename[] = "perf_test_efficient.txt";
    int fd;
    char data[1000];

    printf("Starting efficient file operations...\n");

    // Efficient: Open once, write all data, close once
    memset(data, 'X', sizeof(data));
    fd = open(filename, O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd != -1) {
        write(fd, data, sizeof(data));
        close(fd);
    }

    unlink(filename);
    printf("Efficient operations completed\n");
}

int main() {
    printf("=== Performance Comparison ===\n");

    printf("\n1. Running inefficient version:\n");
    inefficient_file_operations();

    printf("\n2. Running efficient version:\n");
    efficient_file_operations();

    return 0;
}
