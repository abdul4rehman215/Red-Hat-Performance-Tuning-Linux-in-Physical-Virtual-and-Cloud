#!/bin/bash
echo "=== Advanced strace Analysis ==="

# Test program for analysis
cat > test_app.c << 'TESTEOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
int main() {
  pid_t pid = fork();

  if (pid == 0) {
    // Child process
    execl("/bin/ls", "ls", "-la", "/tmp", NULL);
  } else {
    // Parent process
    wait(NULL);
    printf("Child process completed\n");
  }

  return 0;
}
TESTEOF

gcc -o test_app test_app.c

echo "1. Basic trace with timestamps:"
strace -t ./test_app > basic_trace.out 2>&1

echo "2. Trace with relative timestamps:"
strace -r ./test_app > relative_trace.out 2>&1

echo "3. Trace following forks:"
strace -f ./test_app > fork_trace.out 2>&1

echo "4. Trace specific system call categories:"
strace -e trace=process ./test_app > process_trace.out 2>&1

echo "5. Statistical summary:"
strace -c ./test_app > stats_trace.out 2>&1

echo "Analysis complete. Check the generated .out files for results."

# Cleanup
rm -f test_app test_app.c
