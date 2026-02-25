# 🎤 Interview Q&A — Lab 14: Performance Analysis with `perf`

> This Q&A focuses on practical profiling using **perf**: collecting counters, recording profiles, interpreting call graphs, analyzing cache + memory behavior, and tracing I/O/syscalls.

---

## 1) What is `perf` and why is it used?
`perf` is a Linux performance analysis tool that uses kernel performance counters and tracepoints to measure:
- CPU cycles/instructions,
- cache behavior,
- context switches,
- syscalls,
- block I/O and scheduler activity.

It helps identify bottlenecks using real measurements instead of guesses.

---

## 2) What is the difference between `perf stat` and `perf record`?
- **`perf stat`**: collects *aggregate counters* (e.g., cycles, instructions, cache misses) for a command.
- **`perf record`**: samples performance events over time and saves them to `perf.data` for deeper analysis (hot functions, call graphs).

---

## 3) What does IPC mean and why is it important?
**IPC = Instructions Per Cycle**.  
Higher IPC generally indicates more efficient CPU usage. Low IPC may suggest:
- memory stalls,
- cache misses,
- branch mispredicts,
- inefficient code or pipeline stalls.

---

## 4) Why do we care about cache-references and cache-misses?
Because cache misses force the CPU to fetch data from slower memory levels (L2/L3/RAM), increasing latency and reducing throughput. High miss rates often indicate poor locality or random access patterns.

---

## 5) How did the CPU-intensive program appear in perf outputs?
In `perf report` and `perf top`, the program’s `main` function dominated the sample percentages (~98%), confirming it was CPU-bound with most time spent in the loop.

---

## 6) What is a call graph in perf profiling?
A call graph shows the function call relationships and where time is spent in the call stack.  
Using `perf record -g` + `perf report`, you can see the chain leading to hotspots.

---

## 7) Why did you use `perf top`?
`perf top` provides real-time profiling of hotspots while a process runs, similar to `top` but focused on performance events (like cycles). It’s useful for quick “live” diagnosis.

---

## 8) What did the memory test demonstrate?
It demonstrated how access patterns affect performance:
- Sequential access tends to be cache-friendly.
- Random access increases cache misses and can trigger more memory stalls.

Perf counters showed higher cache miss rates during memory workloads.

---

## 9) What is LLC and why do LLC-load-misses matter?
LLC = Last Level Cache (often L3).  
LLC misses are expensive because they usually require fetching data from RAM. A high LLC miss rate often indicates memory-bound behavior.

---

## 10) What are `cpu/mem-loads/` and `cpu/mem-stores/` events?
These events count memory load and store operations at the CPU level (when supported). They help estimate memory access intensity and approximate bandwidth pressure.

---

## 11) Why did NUMA node events fail in this lab?
Events like `node-loads` weren’t available on this kernel (common in cloud builds). Also, the host had only **one NUMA node**, so node-level analysis is limited anyway.

---

## 12) How did you analyze I/O behavior using perf?
Using syscall tracepoints:
- `syscalls:sys_enter_read`
- `syscalls:sys_enter_write`
- `syscalls:sys_enter_open`
- `syscalls:sys_enter_close`

And block layer tracepoints:
- `block:block_rq_issue`
- `block:block_rq_complete`

This showed syscall frequency and kernel block I/O activity.

---

## 13) Why do block I/O tracepoints often require sudo?
Because kernel tracepoints can require elevated privileges for security and system stability. Many environments restrict these events unless running as root.

---

## 14) Why were perf stat counters missing when redirected to a file?
Because `perf stat` writes counters to **stderr** by default.  
To capture output, you must redirect stderr too:
```bash
perf stat ... command > file.txt 2>&1
````

---

## 15) What does `perf script` output enable?

`perf script` outputs raw sample traces that can be used for:

* flamegraph pipelines,
* custom analysis,
* or advanced profiling workflows beyond perf report.

---

