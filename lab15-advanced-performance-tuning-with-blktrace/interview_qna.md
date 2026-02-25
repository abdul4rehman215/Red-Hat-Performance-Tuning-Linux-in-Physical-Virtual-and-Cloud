# 🎤 Interview Q&A — Lab 15: Advanced Performance Tuning with `blktrace`

> This set of questions focuses on block I/O tracing, interpreting blktrace/blkparse output, and making tuning decisions based on observed workload patterns.

---

## 1) What is `blktrace` and what problem does it solve?
`blktrace` traces **block layer I/O events** in the Linux kernel. It helps you see how I/O requests flow through the kernel (queue → dispatch → complete), which is useful for diagnosing storage bottlenecks that are not obvious at the filesystem level.

---

## 2) What is the difference between filesystem-level tools and block-layer tracing?
- Filesystem tools (like `df`, `du`, filesystem stats) show allocation and file activity.
- Block-layer tracing (`blktrace`) shows **actual disk request behavior**: request sizes, ordering, queueing, completion latency, merges, and scheduler behavior.

---

## 3) Why does `blktrace` usually require root privileges?
Because it reads kernel tracing data via debugfs and interacts with low-level block devices. Many environments restrict this for security and stability.

---

## 4) What is the role of `blkparse` in this lab?
`blktrace` produces **binary trace files** (`*.blktrace.*`).  
`blkparse` converts these binaries into **human-readable output** so you can search/aggregate events and compute metrics.

---

## 5) In the trace output, what do the letters like `Q`, `I`, and `C` represent?
These are common phases in block I/O:
- **Q** = request queued
- **I** = request issued to device/driver
- **C** = request completed

By comparing timestamps across these phases, you can estimate I/O latency.

---

## 6) How did you ensure you traced the real disk and not a loop device?
A naive approach selected `loop0` first.  
I fixed it by selecting the first device where `TYPE=disk` from `lsblk`, resulting in `nvme0n1` as the tracing target.

---

## 7) What does it mean that most I/O operations were “small 4KB”?
It indicates a workload with a lot of small random requests (typical of database-like access patterns). Small I/O can increase overhead and is more sensitive to latency and scheduling.

---

## 8) How do you estimate “random vs sequential” from trace data?
One method is to compare each request’s starting sector to the previous sector + previous request size.  
If it matches, it’s counted as sequential; otherwise, random.

---

## 9) How did you compute an estimated average latency from the trace?
I used a simplified approach:
- store the timestamp when a request is queued (`Q`)
- subtract it from the completion timestamp (`C`) for matching request identifiers
- average across all such samples

This gives a quick estimate of end-to-end block request time.

---

## 10) Why did you test multiple I/O schedulers?
Different schedulers optimize different workload goals:
- throughput vs latency
- fairness across processes
- interactive responsiveness vs bulk I/O

Testing `none`, `mq-deadline`, `kyber`, and `bfq` helps identify which is best for the observed access pattern on NVMe.

---

## 11) Why might `bfq` be slower on NVMe for sequential workloads?
BFQ focuses on fairness and interactive responsiveness and can add scheduling overhead.  
NVMe devices already handle queueing efficiently, so simpler schedulers (`none`, `mq-deadline`, `kyber`) often match or outperform BFQ for throughput-heavy workloads.

---

## 12) What is `read_ahead_kb` and when should you increase it?
`read_ahead_kb` controls how much the kernel prefetches when reading sequentially.  
Increasing it helps **sequential reads** and some streaming workloads, but it may not help (and can hurt) random workloads by reading data that isn’t used.

---

## 13) What is `nr_requests` and how does it relate to queue depth?
`nr_requests` controls the number of requests that can be queued in the block layer.  
Higher values can help concurrency on some workloads, but NVMe often saturates efficiently already, so changes may show minimal impact in simple sequential tests.

---

## 14) Why did you use `iostat` and `fio` along with blktrace?
- `iostat -x`: provides high-level device utilization and latency/await indicators.
- `fio`: generates controlled random/sequential patterns with measurable IOPS/BW/latency.
- `blktrace`: explains **why** the device behaves the way it does at the request level.

These together create a complete tuning workflow.

---

## 15) How did you make tuning changes persistent across reboots?
I used multiple persistence methods:
- **udev rules** to set scheduler on device add/change
- **systemd oneshot service** to apply queue depth/read-ahead and SSD tweaks
- **sysctl config** for VM dirty ratios and polling-related parameters

---

## 16) What happened with `kernel.io_delay_type` and how did you handle it?
The kernel parameter was not present in `/proc/sys/kernel/`, so `sysctl` printed an error.  
This is normal across different kernel builds; the rest of the sysctl settings still applied.

---

## 17) What’s the “right” workflow for disk tuning in production?
A safe workflow:
1. baseline metrics (fio/iostat)
2. trace and analyze (blktrace/blkparse)
3. apply one tuning change at a time
4. re-test under realistic workload
5. document changes and roll-back plan
6. make persistent only after validation

---
