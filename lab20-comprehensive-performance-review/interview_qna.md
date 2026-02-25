# 🧠 Interview Q&A - Lab 20: Comprehensive Performance Review

## ✅ Core Concept Questions

### 1) What is the purpose of a “comprehensive performance review”?
A comprehensive performance review correlates **CPU, memory, disk I/O, and network** metrics together to identify **real bottlenecks** instead of guessing from a single tool. It helps in making **data-driven tuning decisions**.

---

### 2) Why is using multiple monitoring tools together better than using only one?
Because bottlenecks are often **cross-resource**:
- High CPU can be caused by **I/O wait**
- Low performance can be due to **memory pressure** causing swap
- Network slowdowns can be caused by **buffer limits**
Using multiple tools gives a **holistic view** and prevents misdiagnosis.

---

### 3) What is the difference between real-time monitoring and historical monitoring?
- **Real-time monitoring** shows what is happening **now** (e.g., `top`, `htop`, `vmstat`).
- **Historical monitoring** helps analyze trends over time (e.g., `sar` logs).

In this lab, we used both:
- Real-time style outputs (`top`, `iostat`, `vmstat`)
- Summarized activity snapshots (`sar`)

---

## 🖥️ CPU + Process Monitoring

### 4) What does `top` provide in performance review?
`top` provides:
- CPU usage breakdown (**user/system/idle/iowait**)
- Processes consuming the most CPU and memory
- Load average and task states

It’s excellent for spotting **CPU-heavy processes** quickly.

---

### 5) What does load average mean?
Load average is the number of processes:
- Running on CPU
- Waiting for CPU
- Or stuck waiting for I/O (depending on system state)

If load average is consistently **higher than CPU core count**, it indicates potential resource pressure.

---

### 6) What is the difference between `%us` and `%sy` in CPU usage?
- `%us` = CPU time spent running **user-space processes**
- `%sy` = CPU time spent running **kernel/system operations**
High `%sy` may indicate heavy kernel work like **I/O, networking, context switching**.

---

## 🧠 Memory Monitoring

### 7) What is `vm.swappiness` and why tune it?
`vm.swappiness` controls how aggressively Linux uses **swap**.
- Higher value = swaps sooner
- Lower value = prefers RAM usage first

For general performance tuning:
- Reducing it (like **10**) can reduce unnecessary swapping and improve responsiveness.

---

### 8) What do `vm.dirty_ratio` and `vm.dirty_background_ratio` do?
They control how much memory can hold “dirty” (modified) data before flushing to disk:
- `dirty_background_ratio`: when background writeback starts
- `dirty_ratio`: when processes are forced to write to disk

Tuning these helps manage **writeback bursts**, reducing stalls and improving I/O stability.

---

## 💾 Disk I/O Monitoring

### 9) What does `iostat -x` show?
`iostat -x` provides extended disk metrics like:
- `%util` (device utilization)
- `await` (average request wait time)
- `r/s`, `w/s` (IOPS)
- `rkB/s`, `wkB/s` (throughput)

It’s key for detecting **disk bottlenecks**.

---

### 10) What does high `%util` indicate?
High `%util` (close to 100%) suggests the disk is **busy** and may be a bottleneck, especially when paired with:
- high `await`
- high `iowait` in CPU metrics

---

### 11) Why did we try tuning the I/O scheduler?
Schedulers affect how I/O requests are ordered and handled.
For SSD/NVMe workloads, schedulers like:
- `none`
- `mq-deadline`
are typically preferred.

---

## 🌐 Network Monitoring

### 12) Why tune `rmem_max` and `wmem_max`?
They control maximum socket buffer sizes:
- `rmem_max` for receive
- `wmem_max` for send

Increasing buffers improves throughput stability for high bandwidth workloads and reduces drops under burst traffic.

---

### 13) What does TCP window scaling do?
TCP window scaling allows larger window sizes, improving performance on high bandwidth or higher latency paths by allowing more data in-flight.

---

## 🧪 Testing + Validation

### 14) Why do we benchmark after tuning?
Because tuning without validation is risky. Benchmarking confirms:
- performance improved
- stability did not degrade
- changes are measurable and defensible

---

### 15) Why is loopback `iperf3` used in post-tuning validation?
Loopback testing verifies **local TCP stack performance** independent of external network variables. It helps confirm system networking configuration correctness.

---

### 16) Why do we document changes before/after?
Because in real production:
- You need auditability
- You need rollback capability
- You must justify changes with evidence

Documentation is part of safe performance engineering.

---

## 🛡️ Best Practices & Production Mindset

### 17) What are safe tuning principles?
✅ Always:
- Baseline first
- Change one thing at a time (or document grouped change)
- Validate after applying changes
- Make changes persistent only after confirmation
- Keep backups for rollback

---

### 18) Why is persistence important and how was it done here?
Runtime changes under `/proc/sys/...` reset after reboot.
Persistence was done using:
- `/etc/sysctl.d/99-performance-tuning.conf`

This ensures tuning survives reboot.

---

### 19) What is the biggest mistake people make in performance troubleshooting?
Jumping directly to tuning without:
- baseline measurement
- correlating metrics
- confirming the bottleneck
This often results in “fixing” the wrong resource.

---

### 20) If performance is still bad after tuning, what next?
Next steps:
- re-run monitoring under the same load
- compare against baseline apples-to-apples
- dig deeper into:
  - per-process profiling (perf)
  - filesystem + block tracing (blktrace)
  - application profiling / logs
  - kernel messages and dmesg
  - container/K8s level throttling (if applicable)

---

## 🎯 Quick Scenario Questions (Common in Interviews)

### 21) CPU is low, but system is slow. What do you check?
Check:
- disk I/O wait (`iostat`, `%wa`)
- memory pressure (`free`, swap activity)
- load average vs CPU cores
- blocked processes (`vmstat`, `ps` state `D`)

---

### 22) Load average is high but CPU usage is low. Why?
Common reasons:
- processes blocked on disk I/O
- NFS/network storage stalls
- kernel locks / contention

Confirm using:
- `vmstat` (blocked processes)
- `iostat` (`await`, `%util`)
- `top` (wa)

---

### 23) Disk utilization is high. What do you do first?
- Identify which process is causing I/O (`iotop`, `pidstat` if available)
- Confirm if workload is expected
- Consider tuning:
  - writeback ratios
  - scheduler (SSD vs HDD)
  - application batching or caching

---
