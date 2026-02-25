#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <string.h>

int main() {
    char filename[] = "test_file.txt";
    char data[] = "Hello, World! This is test data.\n";
    char buffer[1024];
    int fd;
    struct stat file_stat;

    printf("Creating and writing to file...\n");

    // Create and write to file
    fd = open(filename, O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd == -1) {
        perror("open");
        exit(1);
    }

    write(fd, data, strlen(data));
    close(fd);

    // Read from file
    printf("Reading from file...\n");
    fd = open(filename, O_RDONLY);
    if (fd == -1) {
        perror("open");
        exit(1);
    }

    ssize_t bytes_read = read(fd, buffer, sizeof(buffer));
    (void)bytes_read;
    close(fd);

    // Get file statistics
    if (stat(filename, &file_stat) == 0) {
        printf("File size: %ld bytes\n", file_stat.st_size);
    }

    // Clean up
    unlink(filename);

    printf("Operations completed\n");
    return 0;
}
