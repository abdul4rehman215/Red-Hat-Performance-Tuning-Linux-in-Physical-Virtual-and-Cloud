# 🛠️ Troubleshooting Guide - Lab 07: strace Performance Analysis

> This guide captures the **real issues observed in the lab** plus the most common `strace` problems you’ll hit in cloud/enterprise Linux environments.

---

## 1) ❌ `strace: command not found`

### Symptoms
```bash
strace --version
bash: strace: command not found
````

### Fix (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y strace
```

### Fix (RHEL/CentOS)

```bash
sudo dnf install -y strace
# or older distros:
sudo yum install -y strace
```

### Verify

```bash
which strace
strace --version
```

---

## 2) ❌ Permission denied when attaching to a process (`strace -p PID`)

### Symptoms

```bash
strace -p 1234
strace: attach: ptrace(PTRACE_SEIZE, 1234): Operation not permitted
```

### Why it happens

* You’re trying to trace a process owned by another user
* Kernel hardening may restrict ptrace
* In some lab environments, sudo requires a password

### Fix options

#### A) Use sudo

```bash
sudo strace -p 1234
```

#### B) Trace a process you own (run it yourself)

```bash
ping -c 3 google.com &
PID=$!
strace -p $PID
```

#### C) Check ptrace restrictions (Ubuntu often has Yama enabled)

```bash
cat /proc/sys/kernel/yama/ptrace_scope
```

**Temporary change (for labs/testing only):**

```bash
sudo sysctl kernel.yama.ptrace_scope=0
```

> ⚠️ Security note: lowering ptrace restrictions can weaken process isolation. Do this only in controlled lab environments.

---

## 3) ❌ "Too much output" (trace is unreadable)

### Symptoms

* Terminal floods with syscalls
* Hard to find relevant calls

### Fixes

#### A) Log output to file

```bash
strace -o trace_output.txt ./your_program
```

#### B) Follow forks but still log cleanly

```bash
strace -f -o script_trace.txt ./script.sh
```

#### C) Filter syscalls (best approach)

File calls only:

```bash
strace -e trace=file ./file_operations
```

Network calls only:

```bash
strace -e trace=network ping -c 3 google.com
```

Memory calls only:

```bash
strace -e trace=memory ./file_operations
```

#### D) Use summary statistics

```bash
strace -c ./file_operations
```

---

## 4) ❌ Placeholder commands cause shell errors (`<PID>`, `<command>`, `<process_name>`)

### Symptoms (seen in lab)

```bash
ps aux | grep <process_name>
bash: syntax error near unexpected token `newline'
```

### Why it happens

`<process_name>` and `<command>` are **placeholders** in lab guides — if typed literally, they break.

### Fix

Replace placeholders with real values:

```bash
ps aux | grep sshd
pgrep -f python3
strace -c ./file_operations
```

---

## 5) ⚠️ Tracing scripts with `-f` shows surprising errors (race/timing effects)

### Example seen in lab output

```bash
grep: file_list.txt: No such file or directory
```

### Why it can happen

When tracing with `strace -f`, the script executes quickly and spawns processes; the trace order and timing can make file creation/reads appear out of sequence during inspection.

### Fix / Mitigation

* Validate behavior without tracing first:

```bash
./system_interaction.sh
```

* Add small delays for deterministic labs (optional):

```bash
sleep 0.1
```

* Ensure file paths are correct and relative files exist when referenced.

---

## 6) ❌ `strace -p` attaches but shows nothing useful

### Symptoms

* You attach to a process and see no syscalls
* Or it looks “idle”

### Why it happens

The process might be blocked/waiting (common for daemons). Example syscalls you *may* see:

* `epoll_wait`
* `poll`
* `futex`
  These are often normal.

### Fix

Generate workload so syscalls occur:

* hit a local server endpoint
* send network traffic
* trigger a file read/write action

Example:

```bash
python3 -m http.server 8080 &
PID=$!
timeout 5 strace -c -p $PID 2> service_trace.txt
curl -s http://localhost:8080 > /dev/null
cat service_trace.txt
kill $PID
```

---

## 7) ❌ `gcc: command not found` when compiling C test programs

### Fix (Ubuntu/Debian)

```bash
sudo apt-get update
sudo apt-get install -y build-essential
```

### Fix (RHEL/CentOS)

```bash
sudo dnf groupinstall -y "Development Tools"
# or minimal:
sudo dnf install -y gcc make
```

---

## 8) ✅ Best Practices for clean, portfolio-ready traces

### Recommended patterns

* Save everything to files:

```bash
strace -o trace.txt ./program
```

* Use summaries:

```bash
strace -c -o summary.txt ./program
```

* Use filters:

```bash
strace -e trace=file -o file_trace.txt ./program
```

* Follow forks when tracing scripts:

```bash
strace -f -o forked_trace.txt ./script.sh
```

---

## ✅ Quick Validation Checklist

Use this to confirm the lab artifacts are correct:

* `strace` installed and working:

```bash
which strace && strace --version
```

* Basic trace file exists and contains syscalls:

```bash
test -s trace_output.txt && head -20 trace_output.txt
```

* Statistical summary generated:

```bash
test -s inefficient_trace.txt && cat inefficient_trace.txt | head
```

* Script tracing output present:

```bash
test -s script_trace.txt && grep -E "execve|openat|read|write" script_trace.txt | head
```

