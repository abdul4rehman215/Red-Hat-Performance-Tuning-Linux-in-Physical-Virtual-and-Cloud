#!/usr/bin/env bash
# Lab 07: Analyzing System Performance Using strace
# Environment: Ubuntu 20.04 LTS (Cloud Lab VM)
# User: toor

# --- Verify strace installation ---
which strace
strace --version
man strace

# --- Create + compile simple test program ---
nano simple_program.c
ls -l simple_program.c
gcc -o simple_program simple_program.c
ls -l simple_program

# --- Basic system call tracing ---
strace ./simple_program

# --- Save strace output to file ---
strace -o trace_output.txt ./simple_program
cat trace_output.txt

# --- Trace a running process (ping) ---
ping google.com > /dev/null &
PING_PID=$!
echo "Ping process PID: $PING_PID"

strace -p "$PING_PID"
strace -t -p "$PING_PID"

kill "$PING_PID"
ps -p "$PING_PID"

# --- Create + compile file operations program ---
nano file_operations.c
gcc -o file_operations file_operations.c

# --- Detailed trace for file_operations ---
strace -v -s 100 ./file_operations

# --- Filter tracing to specific syscall groups ---
strace -e trace=file ./file_operations
strace -e trace=network ping -c 3 google.com
strace -e trace=memory ./file_operations

# --- Syscall counts / summary ---
strace -c ./file_operations

# --- Advanced script with multiple system interactions ---
nano system_interaction.sh
chmod +x system_interaction.sh
strace -f -o script_trace.txt ./system_interaction.sh
grep -E "(open|read|write|execve)" script_trace.txt | head -20

# --- Create + compile performance comparison program ---
nano performance_test.c
gcc -o performance_test performance_test.c

# --- Syscall summary + timing analysis for performance_test ---
strace -c -o inefficient_trace.txt ./performance_test
cat inefficient_trace.txt

strace -T -o detailed_trace.txt ./performance_test
grep -E "(open|write|close)" detailed_trace.txt | head -10

# --- Create analyzer helper script ---
nano analyze_performance.sh
chmod +x analyze_performance.sh
./analyze_performance.sh

# --- Real-world monitoring example (service-like process) ---
pgrep sshd | head -1

nano monitor_service.sh
chmod +x monitor_service.sh
./monitor_service.sh python3 10

# --- Advanced analysis script (creates multiple .out reports) ---
nano advanced_strace_analysis.sh
chmod +x advanced_strace_analysis.sh
./advanced_strace_analysis.sh
ls -1 *.out

# --- Cleanup ---
rm -f simple_program simple_program.c
rm -f file_operations file_operations.c
rm -f performance_test performance_test.c
rm -f system_interaction.sh
rm -f *.txt *.out
rm -f analyze_performance.sh monitor_service.sh advanced_strace_analysis.sh

# --- Verify cleanup ---
ls -la | grep -E "\.(txt|out|c)$"
