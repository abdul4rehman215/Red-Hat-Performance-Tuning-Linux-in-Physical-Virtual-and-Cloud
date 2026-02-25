# 🧪 Lab 01: Introduction to Performance Tuning Concepts

## 🧾 Lab Summary
This lab introduces the **core goals and principles of Linux performance tuning** and builds a practical foundation for later tuning work.
I established a **baseline system profile**, installed common **monitoring + stress tools**, created reusable **monitoring and testing scripts**, simulated bottlenecks, and generated a consolidated performance report.

Performance tuning goals covered:
- **Throughput** (work completed per unit time)
- **Response time** (latency between request and result)
- **Resource utilization** (CPU, memory, disk, network efficiency)
- **Scalability** (maintaining performance as load increases)

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Understand goals/principles of performance tuning in Linux
- Identify common bottlenecks and resource constraints
- Analyze system performance metrics using monitoring tools
- Evaluate responsiveness and scalability characteristics
- Apply basic optimization techniques
- Interpret performance data to support tuning decisions

---

## ✅ Prerequisites
Before starting this lab, I had:

- Basic Linux command-line knowledge
- Understanding of Linux filesystem structure
- Familiarity with process concepts
- Basic understanding of CPU, memory, disk, and network resources
- Experience with a text editor (vim/nano)

---

## 🖥️ Lab Environment
**Environment:** Cloud-based Linux lab VM  
**OS Family:** CentOS/RHEL 9 (Kernel 5.14.x)  
**User:** `centos`  
**Privileges:** sudo/root available  
**Tools Used:** `htop`, `iotop`, `nethogs`, `stress-ng`, `sysstat`, `iostat`, `iftop`

Baseline identifiers (as observed during lab):
- Hostname: `ip-172-31-10-214`
- Kernel: `5.14.0-427.16.1.el9_4.x86_64`
- CPU: `2 vCPU` (Intel Xeon Platinum 8259CL)
- RAM: `~3.7GiB`
- Disk: `~32G` root volume

---

## 📁 Repository Structure
```text
lab01-introduction-to-performance-tuning-concepts/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── performance_demo.sh
    ├── system_monitor.sh
    ├── cpu_bottleneck.sh
    ├── memory_bottleneck.sh
    ├── disk_bottleneck.sh
    ├── analyze_bottlenecks.sh
    ├── responsiveness_test.sh
    ├── scalability_test.sh
    └── generate_performance_report.sh
````

---

## 🧩 Lab Tasks Overview (What I Did)

### ✅ Task 1: Understanding Performance Tuning Goals

**Goal:** Establish baseline metrics and understand tuning targets.

What I did:

* Collected baseline system data:

  * Kernel/system info (`uname -a`)
  * CPU specs (`lscpu`)
  * Memory usage (`free -h`)
  * Disk usage (`df -h`)
  * System load (`uptime`)
* Created `~/performance_lab/` workspace
* Generated a baseline report file: `baseline_report.txt`
* Installed tuning and monitoring tools:

  * `stress-ng`, `htop`, `iotop`, `nethogs`
* Built a demo script (`performance_demo.sh`) to show:

  * Throughput via CPU-heavy calculations
  * Response time via file creation timing

---

### ✅ Task 2: Resource Optimization & Bottleneck Identification

**Goal:** Measure resource usage and practice identifying bottlenecks.

What I did:

* Installed monitoring tooling:

  * `sysstat`, `iftop`
* Enabled sysstat collection (service enable)
* Built and executed a monitoring script (`system_monitor.sh`) that logs:

  * CPU usage snapshot
  * Memory usage (`free -h`)
  * Disk I/O metrics (`iostat -x`)
  * Network interface counters (`/proc/net/dev`)
  * Load average (`uptime`)
* Created bottleneck simulation scripts:

  * `cpu_bottleneck.sh` (CPU saturation using bc loops)
  * `memory_bottleneck.sh` (memory pressure using `stress-ng`)
  * `disk_bottleneck.sh` (I/O churn using repeated `dd` writes)
* Built a bottleneck analysis tool (`analyze_bottlenecks.sh`) to detect:

  * High CPU usage thresholds
  * High memory usage thresholds
  * High load per core
  * High disk usage thresholds

---

### ✅ Task 3: Responsiveness & Scalability Assessment

**Goal:** Test response-time behavior and scaling under load.

What I did:

* Created a responsiveness testing framework (`responsiveness_test.sh`) to measure:

  * Filesystem response latency (create/write/read/delete loops)
  * Process creation latency (tiny process exec timing)
  * Network responsiveness (localhost ping RTT)
* Created a scalability testing suite (`scalability_test.sh`) to test:

  * CPU scalability via concurrent compute jobs (1, 2, 4 workers)
  * Memory allocation scaling (10MB, 50MB, 100MB)
  * I/O scaling via concurrent write/delete (1, 5, 10 ops)
* Generated a consolidated report (`generate_performance_report.sh`)

  * Output report: `performance_tuning_report.txt`

---

## ✅ Verification & Validation

I verified lab completion by confirming:

* Scripts exist and are executable:

  * `ls -la *.sh`
* Logs and reports were generated:

  * `baseline_report.txt`
  * `system_performance.log`
  * `performance_tuning_report.txt`
* System health is stable post-testing:

  * `uptime`
  * `free -h`
  * `df -h`

---

## 📌 Result

At the end of this lab, I successfully:

* Captured a baseline performance snapshot for the system
* Built a reusable monitoring and reporting workflow
* Demonstrated performance tuning goals with controlled tests
* Simulated CPU/memory/disk bottlenecks (for identification practice)
* Produced a consolidated performance report for later comparison

---

## 🧠 What I Learned

* Performance tuning starts with **baseline measurement**, not guessing
* Bottlenecks shift depending on workload (CPU vs memory vs disk vs network)
* Load averages must be interpreted relative to **core count**
* A structured approach (monitor → test → analyze → report) improves tuning decisions
* Reusable scripts reduce effort and improve consistency across environments

---

## 🌍 Why This Matters

Performance tuning is critical because it directly impacts:

* **Cost efficiency** (less waste, better utilization)
* **User experience** (faster response times)
* **Scalability** (handles growth without major redesign)
* **Reliability** (often uncovers stability issues)
* **Operational readiness** (measurable, repeatable tuning workflows)

---

## 🧰 Real-World Applications

These skills map to real workloads such as:

* Tuning Linux servers for **web apps**, **databases**, and **APIs**
* Baseline collection for **SRE / DevOps** monitoring practices
* Detecting performance regressions after patches or deployments
* Capacity planning and scalability testing for production systems
* Supporting incident response by validating system health during load events

---

## ✅ Conclusion

In this introductory performance tuning lab, I:

* Learned the fundamental goals of performance tuning (throughput, response time, utilization, scalability)
* Measured and documented baseline CPU/memory/disk/load metrics
* Monitored system resources using common tools and custom scripts
* Simulated bottlenecks and used automated checks to identify constraints
* Tested responsiveness and scalability with repeatable testing scripts
* Generated a consolidated performance tuning report for future tuning comparisons

This lab established a structured foundation for more advanced tuning tasks in future labs (kernel tunables, tuned profiles, cgroups, perf/sar analysis, and workload-specific optimization).
