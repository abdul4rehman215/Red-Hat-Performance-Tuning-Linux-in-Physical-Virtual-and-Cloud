#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>

int main() {
    printf("Starting simple program...\n");

    // Open a file
    int fd = open("/etc/passwd", O_RDONLY);
    if (fd != -1) {
        char buffer[100];
        read(fd, buffer, sizeof(buffer));
        close(fd);
        printf("File operation completed\n");
    }

    // Sleep for demonstration
    sleep(2);

    printf("Program finished\n");
    return 0;
}
