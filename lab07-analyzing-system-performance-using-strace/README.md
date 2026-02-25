# 🧪 Lab 07: Analyzing System Performance Using `strace`

**Environment:** Ubuntu 20.04 LTS (Cloud Lab VM)  
**User:** `toor`  
**Tool Focus:** `strace` (system call + signal tracing)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Trace **system calls** and **signals** for programs and running processes using `strace`
- Understand how applications interact with the **Linux kernel**
- Identify **performance bottlenecks** caused by excessive/inefficient system calls
- Interpret `strace` output (including timing + syscall summaries) to diagnose system-level issues
- Apply tuning ideas based on syscall patterns (reduce syscall frequency, batch I/O, avoid failures)

---

## ✅ Prerequisites

- Comfortable with Linux CLI and basic process management
- Familiar with file and network operations
- Basic system administration awareness (permissions, services, etc.)
- Able to edit files using `nano` and compile C programs with `gcc`

---

## 🧰 Lab Setup Notes

- `strace` was already available:
  - `/usr/bin/strace`
  - `strace --version` → `5.5`
- Work was performed on a cloud environment (no local VM build required)

---

## 🧠 What I Did (Task Overview)

### ✅ Task 1 — Trace system calls of programs and running processes
- Verified `strace` installation and reviewed the manual.
- Created and compiled a small C program (`simple_program.c`) to trace:
  - file open/read/close
  - stdout writes
  - sleep behavior (`nanosleep`)
- Saved trace output into a file (`trace_output.txt`) for offline inspection.
- Started a long-running process (`ping`) and attached `strace` to it by PID.
- Added timestamps to live tracing to correlate behavior over time.

---

### ✅ Task 2 — Analyze how applications interact with the kernel
- Built a more complete file workflow program (`file_operations.c`) to trigger:
  - create/write
  - open/read
  - stat
  - unlink (delete)
- Used `strace` filters to focus only on relevant syscall groups:
  - file syscalls (`-e trace=file`)
  - network syscalls (`-e trace=network`)
  - memory syscalls (`-e trace=memory`)
- Generated syscall statistics with `strace -c` to identify the most expensive/frequent calls.

---

### ✅ Task 3 — Identify syscall-related performance bottlenecks
- Created a performance comparison C program (`performance_test.c`) that demonstrates:
  - **inefficient pattern:** open/write/close in a loop (1000 times)
  - **efficient pattern:** open once, write in bulk, close once
- Used:
  - `strace -c` for syscall summary totals
  - `strace -T` for per-call timing visibility
- Built a helper script (`analyze_performance.sh`) to summarize syscall counts and patterns.

---

### ✅ Task 4 — Real-world monitoring with `strace`
- Traced a running service-like process (demo `python3 -m http.server`) via PID attachment.
- Captured a short syscall profile using `timeout ... strace -c -p <PID>`.

---

### ✅ Task 5 — Advanced tracing techniques and methodology
- Created a scripted workflow (`system_interaction.sh`) containing:
  - file listing + grep
  - ping test
  - process snapshot
  - memory snapshot
- Traced with fork-following (`-f`) to see child processes like `ls`, `grep`, `ping`, etc.
- Built an advanced analysis script (`advanced_strace_analysis.sh`) to generate:
  - timestamped trace output
  - relative timestamp trace
  - fork-following traces
  - syscall-category traces (process-related)
  - syscall stats summary

---

## 📌 Key Observations

- Syscall summaries (`strace -c`) made bottlenecks obvious:
  - Inefficient approach caused **1000+ openat/close/write** syscalls.
- Timing mode (`-T`) showed syscall cost per operation.
- Attaching to a running process (`-p`) was useful for profiling “live” behavior.
- Fork-following (`-f`) is essential for shell scripts, because the interesting syscalls often happen in child processes.

---

## 💡 Why This Matters (Real-World Relevance)

`strace` is practical for:

- Debugging slow applications caused by **excessive syscalls**
- Diagnosing issues like **permission errors**, missing files (`ENOENT`), and unexpected retries
- Profiling services for heavy polling (`epoll_wait`), file churn, or network behavior
- Building a mental map of how user-space programs talk to the kernel (I/O, memory, process creation)

---

## ✅ Result

At the end of this lab I had:

- Multiple reproducible syscall traces saved to files
- A clear example showing how syscall frequency impacts performance
- Reusable helper scripts to run syscall profiling quickly

---

## 🧹 Cleanup

All compiled binaries, source files, trace outputs, and temporary logs were removed and verified.

---

## 📂 Repo Structure (Lab 07)

```text
labs/
└── lab07-analyzing-system-performance-using-strace/
    ├── README.md
    ├── commands.sh
    ├── output.txt
    ├── interview_qna.md
    ├── troubleshooting.md
    └── scripts/
        ├── simple_program.c
        ├── file_operations.c
        ├── performance_test.c
        ├── system_interaction.sh
        ├── analyze_performance.sh
        ├── monitor_service.sh
        └── advanced_strace_analysis.sh
````

---

## 📝 Files Included

* **`README.md`** → Lab overview and outcomes (this file)
* **`commands.sh`** → Only the commands executed during the lab (in order)
* **`scripts/`** → C programs + helper scripts used in tracing and analysis
* **`output.txt`** → All command outputs + trace snippets captured during the lab
* **`interview_qna.md`** → 10–15 interview questions/answers based on this lab
* **`troubleshooting.md`** → Common errors + fixes (permissions, noisy output, PID attach issues)

---


