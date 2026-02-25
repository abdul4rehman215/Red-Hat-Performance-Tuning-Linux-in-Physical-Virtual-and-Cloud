# 🧪 Lab 10: Disk I/O Performance Tuning (Ubuntu 20.04)

## 📌 Overview
This lab focuses on **measuring, tuning, and validating disk I/O performance** on a Linux system using common tools and real workload simulations. The environment uses **NVMe disks** (Amazon EBS), so scheduler availability is limited compared to SATA/SCSI disks.

## 🎯 Objectives
- Monitor disk I/O performance using tools like **iostat**, **iotop**, and system snapshots
- Understand disk I/O schedulers and what they optimize for
- Change I/O scheduler settings (temporary) and confirm the active scheduler
- Benchmark disk performance under different scheduler configurations
- Choose the best scheduler for NVMe-based workloads
- Persist scheduler choice across reboots using a **systemd service** (and also explored udev/rc.local methods)

## ✅ Prerequisites
- Basic Linux CLI usage (files, processes, permissions)
- Understanding of disk devices, mount points, and I/O operations
- Familiarity with monitoring concepts and interpreting metrics
- Sudo/root access

## 🧰 Tools Used
- **sysstat / iostat** (disk utilization, latency, queue depth, throughput)
- **dd** (simple sequential read/write load generation)
- **fio** (workload-specific benchmarking: random/sequential, mixed patterns)
- **hdparm** (basic throughput check; limited on NVMe)
- **iotop** + **watch** (live monitoring during load)

## 🗂 What This Lab Covers 
1. **Baseline Monitoring**
   - Verified monitoring tools and captured baseline I/O stats using iostat.
2. **Disk Discovery**
   - Identified disks with `lsblk`, confirmed mount points, checked disk details with `fdisk -l`.
3. **Generate I/O Load**
   - Created controlled write/read workloads and observed metrics spikes.
4. **Scheduler Tuning**
   - Verified available schedulers for NVMe (`mq-deadline`, `none`)
   - Attempted others (bfq/kyber) and documented why unavailable.
5. **Benchmark & Compare**
   - Ran benchmarking script comparing schedulers.
   - Ran detailed fio tests for random/sequential workloads.
6. **Persist Best Configuration**
   - Documented results and enabled the chosen scheduler at boot using a **systemd oneshot service**.

## ✅ Results Summary (What Happened)
- On this NVMe VM, only **`mq-deadline`** and **`none`** were supported.
- Benchmarks showed **`none`** delivered slightly better throughput and similar random I/O performance.
- Final recommendation for this system: **use `none` scheduler**.

## 🌍 Why This Matters (Real-World Relevance)
- Databases, web servers, and storage-heavy apps are often bottlenecked by I/O.
- Correct scheduler selection reduces latency spikes and improves throughput.
- NVMe behaves differently than HDD/SATA, so tuning must match hardware reality.
- In production, this helps improve performance **without upgrading hardware**.

## 📌 Repository Structure 
```text
lab10-disk-io-performance-tuning/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── scripts/
│   ├── disk_performance_test.sh
│   └── analyze_results.sh
└── reports/
   └── performance_report.txt
```

## ✅ Conclusion

This lab built hands-on skills for **disk performance monitoring, scheduler selection, benchmarking, and persistent tuning**—especially important on NVMe-based cloud systems where scheduler options are limited.
