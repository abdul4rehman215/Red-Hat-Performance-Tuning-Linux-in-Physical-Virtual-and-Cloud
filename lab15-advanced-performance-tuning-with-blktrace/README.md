# 🧪 Lab 15: Advanced Performance Tuning with `blktrace`

> **Focus:** Deep block I/O tracing using **blktrace + blkparse**, then applying **scheduler + queue + read-ahead tuning** and validating improvements with before/after comparisons.

---

## 📌 Lab Summary

In this lab, I installed and used **blktrace** on Ubuntu 24.04 to trace **block-layer I/O activity** on the primary NVMe disk. I generated controlled I/O workloads, captured binary traces, parsed them into readable format with **blkparse**, analyzed workload characteristics (I/O size distribution, sequential vs random behavior, latency), and then performed tuning:

- Tested multiple I/O schedulers (`none`, `mq-deadline`, `kyber`, `bfq`)
- Tuned **queue depth** (`nr_requests`)
- Tuned **read-ahead** (`read_ahead_kb`)
- Captured traces during tuning tests to compare behavior
- Created a **persistent configuration** using:
  - udev rules (scheduler)
  - systemd oneshot service (queue/read-ahead + SSD tweaks)
  - sysctl tuning file (kernel VM + polling settings)

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Install and verify **blktrace/blkparse**
- Trace block I/O events on a real disk (`/dev/nvme0n1`)
- Convert binary trace output into readable logs
- Identify performance patterns:
  - I/O sizes (4KB dominant)
  - sequential vs random access
  - average request latency
- Compare scheduler behavior under similar workloads
- Apply queue depth + read-ahead tuning based on observed patterns
- Validate optimization impact and create persistent config across reboots

---

## ✅ Prerequisites

- Linux storage fundamentals (filesystem/block devices)
- Understanding of throughput, latency, IOPS
- Basic process management
- Familiarity with `iostat`, `iotop`, `fio` basics
- Root/sudo access (blktrace requires it)

---

## 🧰 Lab Environment

- **Machine:** `toor@ip-172-31-10-251`
- **OS:** Ubuntu 24.04.1 LTS
- **Primary disk:** `nvme0n1` (root)
- **Secondary disk:** `nvme1n1` (attached for testing)
- **Tools:** `blktrace`, `blkparse`, `sysstat (iostat)`, `iotop`, `fio`

> **Note:** Device names may vary in cloud labs; commands auto-detect the first real `TYPE=disk` device.

---

## 🗂️ Repository Structure

```text
lab15-advanced-performance-tuning-with-blktrace/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── io_load_generator.sh
    ├── advanced_trace.sh
    ├── analyze_performance.sh
    ├── tune_io_scheduler.sh
    ├── optimize_queue_settings.sh
    ├── validate_optimizations.sh
    └── make_persistent.sh
````

---

## ✅ Tasks Overview (High-Level)

### **Task 1: Install & Prepare**

* Installed `blktrace`, `sysstat`, `iotop`
* Verified `blktrace -V`
* Identified block devices via `lsblk`
* Confirmed available schedulers via `/sys/block/<dev>/queue/scheduler`
* Captured baseline I/O stats with `iostat -x`

### **Task 2: Trace I/O Activity**

* Created test directory `/opt/blktrace-lab`
* Generated test data (1MB, 10MB, 100MB)
* Captured a basic trace while writing a 50MB file
* Ran an advanced trace with custom options during mixed I/O workloads
* Parsed binary trace output into `parsed_trace.txt`

### **Task 3: Analyze + Tune**

* Extracted operation counts (queue/issue/complete)
* Read vs write distribution
* I/O size mix (dominant small I/O)
* Sequential vs random pattern ratio
* Estimated average I/O latency based on queue → complete timing
* Established baseline with:

  * sequential read/write (dd)
  * random read (fio)
* Tested schedulers (`none`, `mq-deadline`, `kyber`, `bfq`) and captured trace samples per scheduler
* Tuned:

  * `nr_requests` queue depth
  * `read_ahead_kb` read-ahead

### **Task 4: Validate + Persist**

* Ran a consolidated validation workload while tracing
* Generated a summary (ops, read/write counts, average I/O size)
* Persisted tuning across reboot using:

  * udev rule (`/etc/udev/rules.d/60-io-scheduler.rules`)
  * systemd service (`io-optimization.service`)
  * optimization script (`/usr/local/bin/apply-io-optimizations.sh`)
  * sysctl config (`/etc/sysctl.d/99-io-performance.conf`)

---

## 🧪 Results & Key Findings

* Primary tracing device selected correctly as **`nvme0n1`** (not loop devices).
* Workload showed **high small I/O (4KB) dominance** and **more random than sequential** during mixed load generation.
* On this cloud NVMe disk:

  * `none`, `mq-deadline`, `kyber` performed similarly for sequential reads.
  * `bfq` was slightly slower (expected for NVMe in throughput-focused workloads).
* Read-ahead tuning improved small-block sequential reads (best observed around **512KB**).
* Queue depth changes had minimal effect for simple sequential reads on NVMe (also expected).

---

## 🧠 What I Learned

* How to trace disk operations at the **block layer** (below filesystem)
* How to interpret blktrace phases:

  * Q (queue) → I (issue) → C (complete)
* How to translate tracing into tuning decisions:

  * scheduler selection based on workload type
  * read-ahead for sequential reads
  * queue depth for concurrency and device saturation
* How to persist performance settings safely using systemd + udev + sysctl

---

## 🌍 Real-World Relevance

These techniques are used in production for:

* Database hosts and log ingestion systems (latency + IOPS sensitivity)
* Storage-heavy applications (high throughput requirements)
* Detecting I/O bottlenecks and queueing delays
* Optimizing cloud costs by improving disk efficiency

---

## ✅ Conclusion

This lab produced a full performance-tuning workflow:
**baseline → trace → parse → analyze → tune → validate → persist**.

The repository artifacts provide repeatable scripts and real outputs proving hands-on tuning with modern NVMe storage on Linux.

---
