# 🎤 Interview Q&A — Lab 01: Introduction to Performance Tuning Concepts

## 1) What is Linux performance tuning?
Linux performance tuning is the practice of **measuring, analyzing, and optimizing** system behavior so workloads run efficiently. It usually involves improving **throughput**, lowering **response time**, reducing **resource contention**, and ensuring the system remains stable under load.

---

## 2) What are the primary goals of performance tuning?
The main goals are:
- **Maximizing Throughput:** Doing more work per unit time
- **Minimizing Response Time:** Lower latency and faster user/system response
- **Optimizing Resource Utilization:** Efficient CPU/memory/disk/network usage
- **Ensuring Scalability:** Maintaining acceptable performance as load increases

---

## 3) Why do we create a baseline before tuning?
A baseline is the “known good” reference of system performance. Without it:
- You can’t prove improvement
- You can’t detect regressions
- You can’t compare before/after results reliably  
Baseline metrics also help identify what is “normal” for the system.

---

## 4) What baseline metrics did you capture in this lab?
I captured:
- Kernel and system info (`uname -a`)
- CPU topology and model (`lscpu`)
- Memory and swap status (`free -h`)
- Disk space usage (`df -h`)
- Current system load averages (`uptime`)  
These were stored in `baseline_report.txt`.

---

## 5) What is the difference between throughput and response time?
- **Throughput:** How much work gets done per second/minute (e.g., requests/sec).
- **Response time:** How long it takes for a single request to complete (latency).  
A system can have high throughput but poor response times if it is overloaded or queueing heavily.

---

## 6) What does “load average” represent, and how should it be interpreted?
Load average represents the number of tasks that are **running or waiting** for CPU time (and sometimes I/O).  
It should be interpreted relative to CPU cores:
- Load ≈ number of cores → generally acceptable
- Load >> number of cores → system likely overloaded

In the lab, load was low (~0.03–0.06) on a 2-core system.

---

## 7) How did you monitor system performance in this lab?
I used:
- Tools: `htop`, `iostat`, `sysstat`, `iftop`, `iotop`, `nethogs`
- Custom script `system_monitor.sh` to log snapshots of:
  - CPU usage (`top`)
  - Memory usage (`free -h`)
  - Disk I/O (`iostat -x`)
  - Network counters (`/proc/net/dev`)
  - Load (`uptime`)  
Output stored in `system_performance.log`.

---

## 8) What is a bottleneck in system performance?
A bottleneck happens when one resource becomes the limiting factor that slows overall performance (CPU, memory, disk I/O, or network). Even if other resources are idle, the bottleneck resource restricts throughput and increases latency.

---

## 9) How did you simulate CPU, memory, and disk bottlenecks?
I created scripts:
- `cpu_bottleneck.sh`: CPU-heavy infinite bc loops
- `memory_bottleneck.sh`: `stress-ng --vm ... --vm-bytes 75%`
- `disk_bottleneck.sh`: repeated `dd` writes and deletes in loops  
These tests help observe symptoms and learn to identify bottlenecks using monitoring tools.

---

## 10) What checks did your bottleneck analysis script perform?
`analyze_bottlenecks.sh` checked:
- CPU usage threshold (alert if > 80%)
- Memory usage percentage (alert if > 85%)
- Load per core (alert if > 1.0)
- Root filesystem usage (alert if > 90%)  
It prints a quick diagnostic summary.

---

## 11) How did you measure “responsiveness” in the lab?
Using `responsiveness_test.sh`, I measured:
- Filesystem response time via create/write/read/delete loops
- Process creation time (simple execution timing)
- Network latency (ping localhost RTT)  
This gives a practical view of system responsiveness under minimal load.

---

## 12) What does scalability mean in Linux performance testing?
Scalability is the system’s ability to handle **increasing workload** while maintaining acceptable performance. It can involve:
- Increasing concurrency (more processes/threads)
- Larger memory allocations
- More I/O operations  
In this lab, scalability tests were done using CPU concurrency, memory allocation size, and concurrent I/O operations.

---

## 13) Why is monitoring during stress tests important?
Because stress tests can:
- Increase load rapidly
- Trigger resource exhaustion
- Cause performance degradation or instability  
Monitoring helps validate the bottleneck type, understand system limits, and safely stop tests if needed.

---

## 14) What was the purpose of generating a consolidated performance report?
The report (`performance_tuning_report.txt`) combines:
- Baseline data
- Monitoring confirmation
- Bottleneck analysis output
- Recommendations and next steps  
This makes the lab repeatable and creates a single artifact useful for documentation and future comparisons.

---

## 15) What are realistic next steps after this introductory lab?
- Tune kernel parameters (`sysctl`, `/proc/sys/*`)
- Use workload-specific tuning (databases, web servers)
- Apply tuned profiles (`tuned-adm`)
- Implement continuous monitoring (`sar`, dashboards, alerting)
- Measure performance before/after changes and document results
