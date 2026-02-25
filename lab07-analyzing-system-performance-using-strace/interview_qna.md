# 🧠 Lab 07 — Interview Q&A (strace Performance Analysis)

## 1) What is `strace` and why do we use it?
`strace` traces **system calls** and **signals** made by a process. It helps us understand how an application interacts with the Linux kernel, which is useful for debugging, performance tuning, and troubleshooting.

---

## 2) What is a “system call” in Linux?
A system call is the interface that lets user-space applications request services from the kernel (e.g., file I/O, process creation, networking, memory allocation).

---

## 3) What’s the difference between tracing a command vs attaching to a PID?
- **Tracing a command:** `strace <command>` runs the command and traces from start to finish.
- **Attaching to PID:** `strace -p <PID>` attaches to a running process and traces live system calls.

---

## 4) How do you save `strace` output to a file?
Use:
```bash
strace -o trace_output.txt <command>
````

---

## 5) How do you follow child processes created via fork/exec?

Use:

```bash
strace -f <command>
```

This is important because many programs spawn subprocesses (shell scripts, services, web servers, etc.).

---

## 6) How do you add timestamps to trace output?

Two common options:

```bash
strace -t <command>    # wall-clock timestamps
strace -r <command>    # relative timestamps between calls
```

---

## 7) How do you limit trace output to only file-related system calls?

Use syscall category filters:

```bash
strace -e trace=file <command>
```

Other common categories:

* `trace=network`
* `trace=process`
* `trace=memory`

---

## 8) What does `strace -c` do?

It prints a **summary report** of system calls:

* total time per syscall
* number of calls
* average time per call
  Useful for spotting expensive / frequent syscalls quickly.

Example:

```bash
strace -c ./file_operations
```

---

## 9) How do you identify a syscall bottleneck using `strace`?

Look for:

* **Very high call counts** (e.g., 1000+ `openat`, `close`, `write`)
* **High total time** spent in a syscall category
* Repeated **small I/O** operations (lots of tiny reads/writes)

In this lab, the inefficient program had ~1000+ `openat/close/write`, showing syscall overhead.

---

## 10) What does `strace -T` show that normal `strace` doesn’t?

`-T` adds **time spent** in each syscall:

```bash
strace -T -o detailed_trace.txt <command>
```

Example line:

```
openat(...) = 3 <0.000029>
```

---

## 11) What are common syscalls you see in file operations?

* `openat()` / `open()`
* `read()`
* `write()`
* `close()`
* `newfstatat()` / `fstat()`
* `unlink()` (delete)

---

## 12) Why does `strace` often show `openat()` instead of `open()`?

Modern libc implementations prefer `openat()` because it supports directory file descriptors (safer and more flexible). Many tools and applications use `openat()` by default.

---

## 13) What does `epoll_wait()` usually indicate in a service trace?

It indicates the process is waiting for events (typical for servers). In the lab, the HTTP server showed high time in `epoll_wait()` which is normal for event-driven services.

---

## 14) How can `strace` help with performance tuning?

It can reveal:

* excessive filesystem syscalls
* frequent context switching triggers (`futex`)
* network overhead patterns (`sendto/recvfrom`)
* expensive waits (`poll`, `epoll_wait`)
  Then we optimize code and configuration:
* buffer I/O
* reduce open/close cycles
* batch operations
* reduce failing syscalls

---

## 15) What are common reasons you get “permission denied” when using `strace -p`?

Tracing another user’s process requires permission. Fixes include:

* run as root: `sudo strace -p <PID>`
* ensure the user has sudo permission
* note: some environments require sudo password (as seen in lab)
