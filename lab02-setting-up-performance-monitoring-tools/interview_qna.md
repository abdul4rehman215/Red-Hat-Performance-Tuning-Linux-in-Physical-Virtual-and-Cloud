# 🎤 Interview Q&A — Lab 02: Setting Up Performance Monitoring Tools

## 1) Why should you update the system before installing monitoring tools?
Updating ensures:
- package metadata is current
- security and stability fixes are applied
- dependency resolution works correctly  
It reduces install failures and avoids running old/broken tool versions.

---

## 2) What does `procps-ng` provide, and why is it important?
`procps-ng` provides key process/system utilities such as:
- `top` (real-time process + CPU/memory view)
- `vmstat` (virtual memory + CPU + system stats)  
These are core tools for identifying CPU pressure, memory pressure, and process-level resource usage.

---

## 3) What does the `sysstat` package include?
`sysstat` provides:
- `iostat` (disk I/O and CPU usage)
- `sar` (system activity reporting for CPU/memory/disk/network and more)
It also includes background collectors that allow performance history to be recorded for later analysis.

---

## 4) Why do we enable and start the `sysstat` service?
Because `sar` relies on system activity data. Enabling sysstat ensures:
- activity logs are created automatically
- `sar` can report reliable historical data
- monitoring becomes continuous instead of one-time snapshots

---

## 5) What information does `top` provide that’s useful for performance tuning?
`top` shows:
- CPU breakdown (user/system/idle/iowait)
- memory usage (used/free/buffers/cache)
- load average
- per-process CPU and memory usage  
It’s commonly used for identifying hot processes and overall system pressure.

---

## 6) Why would you use `top -b -n 5` instead of interactive `top`?
Batch mode is useful for:
- scripting
- capturing evidence/log output
- collecting multiple snapshots without interactive UI
This makes it easier to store results for documentation and review.

---

## 7) What is the purpose of `vmstat` and what should you watch for?
`vmstat` reports:
- process states (running/blocked)
- memory and swap behavior
- I/O activity
- interrupts and context switches
- CPU utilization  
Red flags include:
- high `b` (blocked processes)
- swap-in/swap-out (`si`, `so`)
- high `wa` (I/O wait)

---

## 8) What does `iostat -x` provide compared to basic `iostat`?
`iostat -x` provides extended metrics such as:
- device utilization (`%util`)
- average wait time (`await`)
- read/write await (`r_await`, `w_await`)
- queue size (`aqu-sz`)  
These help identify disk bottlenecks and latency issues.

---

## 9) In your environment, why did `iostat -x sda` show “Device: sda not found”?
The lab VM uses NVMe storage (e.g., `nvme0n1`) rather than a SATA disk like `sda`.  
So device-specific queries must target the correct device name.

---

## 10) What does `sar` help you do that one-time tools cannot?
`sar` helps collect and report performance data over time:
- CPU usage trends
- memory usage trends
- network throughput patterns
- disk activity patterns  
This makes it useful for baseline creation, incident analysis, and capacity planning.

---

## 11) Why is `dstat` useful in performance monitoring?
`dstat` is useful because it can show multiple resources together:
- CPU + disk + network + memory in one view  
It also supports exporting to CSV (like `--output`) for later analysis.

---

## 12) What is `perf`, and when would you use it?
`perf` is an advanced performance analysis tool that can:
- profile CPU usage at kernel/user level
- capture stack traces and hotspots
- analyze events like cycles, cache misses, context switches  
You use it when you need deeper insight than high-level tools can provide.

---

## 13) Why do some `perf` commands require sudo?
Because perf may access kernel-level performance counters and trace data.  
Access can be restricted by kernel security settings (like `perf_event_paranoid`), so privileged access is often required.

---

## 14) What is the purpose of creating system load during monitoring?
Creating controlled load helps validate:
- tools are working correctly under stress
- you can observe real changes in CPU/memory/disk behavior
- baseline patterns and response under load can be compared later

---

## 15) Why are automation scripts important in performance monitoring?
Automation ensures:
- consistent sampling intervals
- repeatability across systems
- reduced human error
- easier baseline collection  
In this lab, scripts were used to collect CPU/memory/disk/network logs and generate a lightweight monitoring “dashboard.”
