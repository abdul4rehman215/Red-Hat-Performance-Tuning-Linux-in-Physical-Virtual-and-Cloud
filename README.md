# 🚀 Red Hat Linux Performance Tuning - Physical • Virtual • Cloud - Performance Engineering Portfolio  

> **Monitoring • Kernel Optimization • Bottleneck Analysis • Infrastructure Observability**

> Low-Level Systems Analysis • Scheduler Engineering • Memory Optimization • I/O & Network Tuning

### A complete 20-lab hands-on Linux Performance Engineering portfolio focused on real-world system optimization across CPU, memory, disk, networking, virtualization, databases, and containers.

### This repository demonstrates structured performance analysis workflows:

> Measure → Identify Bottlenecks → Tune → Validate → Persist → Document

---

<div align="center">

<!-- ================= PLATFORM & STACK ================= -->

![RHEL](https://img.shields.io/badge/OS%20%7C%20Red%20Hat-Enterprise%20Linux%208%20%7C%209-EE0000?style=for-the-badge&logo=redhat&logoColor=EE0000)
![CentOS](https://img.shields.io/badge/CentOS-Stream-purple?style=for-the-badge&logo=centos)
![Ubuntu](https://img.shields.io/badge/Ubuntu-20.04%20%7C%2022.04-orange?style=for-the-badge&logo=ubuntu)
![Linux](https://img.shields.io/badge/Linux-Performance-black?style=for-the-badge&logo=linux)
![Cloud](https://img.shields.io/badge/Environment-Physical%20%7C%20Virtual%20%7C%20Cloud-blue?style=for-the-badge&logo=cloudflare)

<!-- ================= PERFORMANCE FOCUS ================= -->

![Focus](https://img.shields.io/badge/Focus-Linux%20Performance%20Engineering-critical?style=for-the-badge)
![CPU](https://img.shields.io/badge/CPU-Scheduler%20Tuning-success?style=for-the-badge)
![Memory](https://img.shields.io/badge/Memory-Virtual%20Memory%20Optimization-blue?style=for-the-badge)
![Disk](https://img.shields.io/badge/Disk-I%2FO%20Engineering-important?style=for-the-badge)
![Network](https://img.shields.io/badge/Network-TCP%20Stack%20Tuning-informational?style=for-the-badge)
![Kernel](https://img.shields.io/badge/Kernel-sysctl%20Optimization-lightgrey?style=for-the-badge)

<!-- ================= SPECIALIZATION ================= -->

![cgroups](https://img.shields.io/badge/cgroups-v2-orange?style=for-the-badge)
![perf](https://img.shields.io/badge/Profiling-perf-blueviolet?style=for-the-badge)
![blktrace](https://img.shields.io/badge/Tracing-blktrace-yellow?style=for-the-badge)
![Database](https://img.shields.io/badge/Database-PostgreSQL-blue?style=for-the-badge&logo=postgresql)
![Containers](https://img.shields.io/badge/Containers-Docker%20%7C%20K8s-2496ED?style=for-the-badge&logo=docker)

<!-- ================= SCOPE ================= -->

![Labs](https://img.shields.io/badge/Labs-20%20Hands--On-brightgreen?style=for-the-badge)
![Level](https://img.shields.io/badge/Level-Intermediate%20→%20Advanced-blueviolet?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

<!-- ===================== REPO METADATA ===================== -->
![RepoSize](https://img.shields.io/github/repo-size/abdul4rehman215/Red-Hat-Performance-Tuning-Linux-in-Physical-Virtual-and-Cloud?style=for-the-badge)
![Stars](https://img.shields.io/github/stars/abdul4rehman215/Red-Hat-Performance-Tuning-Linux-in-Physical-Virtual-and-Cloud?style=for-the-badge)
![Forks](https://img.shields.io/github/forks/abdul4rehman215/Red-Hat-Performance-Tuning-Linux-in-Physical-Virtual-and-Cloud?style=for-the-badge)
![LastCommit](https://img.shields.io/github/last-commit/abdul4rehman215/Red-Hat-Performance-Tuning-Linux-in-Physical-Virtual-and-Cloud?style=for-the-badge)

</div>

---

# 🎯 Executive Summary

This repository demonstrates hands-on capability in **Linux Performance Engineering and System Optimization** across physical, virtual, and cloud environments.

The 20-lab series simulates real-world infrastructure performance workflows including:

- CPU scheduler & affinity optimization  
- Memory and swap tuning  
- Disk I/O benchmarking & block-layer tracing  
- Network stack & NIC performance tuning  
- Filesystem optimization (ext4, XFS, Btrfs)  
- Database performance alignment (PostgreSQL)  
- Container resource governance (Docker / Kubernetes)  
- End-to-end performance review & validation methodology  

Each lab follows a production-style workflow:

> Baseline → Analyze → Tune → Validate → Persist → Document

All work is execution-driven and includes:

- Structured command execution  
- Before/after benchmark validation  
- Persistent system configuration  
- Monitoring automation  
- Troubleshooting documentation  
- Interview-ready technical Q&A  

This portfolio reflects structured infrastructure performance engineering practices aligned with enterprise Linux and Red Hat performance tuning methodologies.

---

# 📌 About This Repository

This is a structured **20-lab Linux Performance Tuning program** designed to simulate enterprise system optimization scenarios.

The repository covers:

- Kernel parameter tuning with `sysctl`
- CPU scheduler configuration & task affinity
- Memory subsystem optimization & swappiness testing
- Disk I/O scheduler comparison & benchmarking (fio, blktrace)
- Network TCP stack tuning & throughput validation
- Virtualization performance adjustments
- perf-based CPU & memory profiling
- Long-term monitoring with `sar` / `sysstat`
- Database & container performance engineering
- Comprehensive performance review playbook

All labs were executed in controlled RHEL / Ubuntu environments using industry-standard Linux tools.

Each lab folder includes:

- Step-by-step implementation
- Full command scripts
- Captured outputs & benchmarks
- Troubleshooting notes
- Interview-focused explanations

This repository aligns with enterprise Linux administration, Red Hat performance tuning objectives, and production infrastructure engineering practices.

---

## 📚 Labs Index (1–20)

> Click a lab title to jump into its folder.

---

# 🗂 Lab Categories Overview

# ⚡ Section 1 — Core Linux Performance Engineering (Labs 1–10)

<div align="center">

![Category](https://img.shields.io/badge/Category-Core%20Performance%20Engineering-111827?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Baseline%20%26%20Monitoring-0ea5e9?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Kernel%20%26%20Resource%20Tuning-a855f7?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-CPU%20%7C%20Memory%20%7C%20Disk-22c55e?style=for-the-badge)

</div>

| Lab | Title | Focus Area |
|-----|-------|------------|
| 01 | [Introduction to Performance Tuning Concepts](./lab01-introduction-to-performance-tuning-concepts) | Baseline & bottleneck detection |
| 02 | [Setting Up Performance Monitoring Tools](./lab02-setting-up-performance-monitoring-tools) | top, vmstat, iostat, sar, perf |
| 03 | [Viewing Hardware Resources](./lab03-viewing-hardware-resources) | CPU topology & capacity planning |
| 04 | [Configuring Kernel Tunables](./lab04-configuring-kernel-tunables) | sysctl optimization |
| 05 | [Applying Tuned Profiles](./lab05-applying-tuned-profiles) | tuned-adm & governor tuning |
| 06 | [Managing Resource Limits with cgroups](./lab06-managing-resource-limits-with-cgroups) | CPU/memory/I/O limits |
| 07 | [Analyzing System Performance Using strace](./lab07-analyzing-system-performance-using-strace) | System call tracing |
| 08 | [Tuning CPU Utilization](./lab08-tuning-cpu-utilization) | Scheduler & affinity tuning |
| 09 | [Memory Utilization Tuning](./lab09-memory-utilization-tuning) | Swappiness & VM optimization |
| 10 | [Disk I/O Performance Tuning](./lab10-disk-io-performance-tuning) | Scheduler comparison & fio |

### 🔎 Skills Demonstrated
- Baseline performance engineering & bottleneck identification  
- Kernel parameter tuning with safe persistence/rollback  
- CPU scheduler tuning & affinity optimization  
- Memory pressure & swap behavior analysis  
- Disk I/O benchmarking & scheduler selection  
- System-call level diagnosis with `strace`  
- Resource governance using cgroups v2

---

# 🚀 Section 2 — Advanced Performance Engineering (Labs 11–20)

<div align="center">

![Category](https://img.shields.io/badge/Category-Advanced%20Performance%20Engineering-111827?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Profiling%20%26%20Tracing-f97316?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Storage%20%26%20Network%20Optimization-06b6d4?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-Virtualization%20%26%20Containers-3b82f6?style=for-the-badge)
![Focus](https://img.shields.io/badge/Focus-End--to--End%20Performance%20Review-22c55e?style=for-the-badge)

</div>

| Lab | Title | Focus Area |
|-----|-------|------------|
| 11 | [Optimizing File System Utilization](./lab11-optimizing-file-system-utilization) | ext4/XFS/Btrfs tuning |
| 12 | [Network Utilization Tuning](./lab12-network-utilization-tuning) | TCP buffers & NIC tuning |
| 13 | [Tuning Virtualization Performance](./lab13-tuning-virtualization-performance) | vCPU pinning & ballooning |
| 14 | [Performance Analysis with perf](./lab14-performance-analysis-with-perf) | CPU & memory profiling |
| 15 | [Advanced Performance Tuning with blktrace](./lab15-advanced-performance-tuning-with-blktrace) | Block-level tracing |
| 16 | [Implementing Performance Monitoring with sar](./lab16-implementing-performance-monitoring-with-sar) | Historical monitoring |
| 17 | [Performance Tuning for Databases](./lab17-performance-tuning-for-databases) | PostgreSQL OS alignment |
| 18 | [Network Traffic Performance Tuning](./lab18-network-traffic-performance-tuning) | DNS/TCP optimization |
| 19 | [Performance Tuning for Containers](./lab19-performance-tuning-for-containers) | Docker & Kubernetes limits |
| 20 | [Comprehensive Performance Review](./lab20-comprehensive-performance-review) | End-to-end workflow |

### 🧠 Skills Demonstrated
- Filesystem tuning across ext4/XFS/Btrfs with benchmark validation  
- TCP + NIC tuning with measurable throughput/latency improvements  
- Virtualization performance tuning (CPU topology, memory behavior)  
- Workload profiling using `perf` for hotspots & event-driven analysis  
- Block-layer tracing with `blktrace` for latency + access pattern visibility  
- Long-term monitoring & reporting using `sar/sysstat` automation  
- Database + container performance alignment with OS-level tuning  
- End-to-end performance review playbook (collect → analyze → tune → validate)  

---

## 🧠 Advanced Skills Demonstrated

### Storage Engineering
- Filesystem mount optimization
- Read-ahead & scheduler tuning
- Queue depth tuning
- Loopback disk testing
- Block-level tracing analysis

### Network Optimization
- TCP stack tuning (sysctl)
- NIC ring buffer adjustments
- Throughput validation with iperf3
- Connection state analysis
- DNS performance tuning

### Profiling & Tracing
- perf stat / record / report
- Cache miss & page fault analysis
- blktrace latency inspection
- CPU cycle optimization

### Production Workflows
- Database kernel alignment
- Container resource limits & QoS
- Monitoring automation with sar
- Before/After validation frameworks
- Performance reporting methodology

---

# 🛠 Tools & Technologies Used

<details>
<summary><b> Click to expand </b></summary>

### 📊 Core Monitoring & Observability
`top` • `htop` • `vmstat` • `iostat` • `sar` • `free` • `ps`

### 💾 Storage & Filesystem Engineering
`dd` • `fio` • `losetup`  
`mkfs.ext4` • `mkfs.xfs` • `mkfs.btrfs`  
`blktrace` • `blkparse`

### 🌐 Network Performance & TCP Stack Tuning
`sysctl` • `ethtool` • `ss` • `netstat` • `iperf3` • `dig`

### 🔍 Profiling & Low-Level Tracing
`perf` • `strace`

### ⚙️ Resource Control & Kernel Tuning
`cgroups v2` • `taskset` • `tuned-adm`

### 🧪 Workload Simulation & Benchmarking
`stress-ng` • `sysbench`

### 🐳 Containers & Virtualization
`Docker` • `Kubernetes` • `libvirt`

</details>

---

# 📁 Repository Structure

```
Red-Hat-Linux-Performance-Tuning-Linux-in-Physical-Virtual-and-Cloud/
├── 🔹 Core Linux Performance Engineering (Labs 1–10)
├── 🔹 Advanced Performance Engineering (Labs 11–20)
└── README.md
```

## 📦 Standard Lab Folder Structure

Each lab follows a consistent professional performance-engineering workflow:

```
labXX-<lab-name>/

├── README.md              # Objectives, methodology, tuning rationale
├── commands.sh            # Executed commands (step-by-step sequence)
├── output.txt             # Captured metrics & benchmark validation
├── troubleshooting.md     # Issues encountered + resolution strategy
└── interview_qna.md       # Performance tuning interview insights
```

### This ensures:

- ✅ Reproducibility  
- ✅ Before/after validation tracking  
- ✅ Structured performance documentation  
- ✅ Enterprise-style investigation workflow  
- ✅ Interview-ready explanation of tuning decisions  

---

# 📊 Performance Engineering Workflow Model

All labs follow:

1. Establish Baseline  
2. Collect Metrics  
3. Identify Bottleneck  
4. Tune Configuration  
5. Validate Improvement  
6. Persist Changes  
7. Document Findings  

This mirrors real-world infrastructure performance investigations.

---

# 🎓 Learning Outcomes Across 20 Labs

After completing this 20-lab Linux Performance Engineering series, this portfolio demonstrates the ability to:

- Diagnose CPU, memory, disk, and network bottlenecks
- Perform kernel parameter tuning using `sysctl`
- Optimize CPU scheduling, affinity, and cache locality
- Engineer disk I/O strategies with scheduler comparison & tracing
- Tune TCP stack and NIC performance for throughput & latency
- Profile workloads using `perf` and system call tracing
- Apply cgroups v2 for resource governance
- Align OS-level tuning with database & container workloads
- Execute structured performance review & validation workflows

This reflects practical infrastructure optimization — not theoretical study.

---

# 🌍 Real-World Alignment

These labs simulate real enterprise performance engineering workflows including:

- Production Linux server optimization
- Cloud VM performance tuning
- Multi-tenant workload isolation using cgroups
- Database performance troubleshooting (PostgreSQL alignment)
- Container resource limit tuning (Docker / Kubernetes)
- DevOps-style benchmarking & before/after validation
- Persistent configuration management for production systems

All experiments were conducted in controlled lab environments to mirror realistic infrastructure performance investigations.

# 📊 Professional Relevance

This portfolio reflects capability in:

- Infrastructure performance analysis
- Kernel & scheduler optimization
- Storage and block-layer engineering
- Network throughput & latency tuning
- Observability-driven performance troubleshooting
- Structured performance documentation & reporting

Aligned with enterprise Linux administration, Red Hat performance tuning objectives, and production infrastructure engineering roles.

---

# 🧪 Real-World Simulation Model

All labs were executed in controlled Linux environments designed to simulate realistic infrastructure performance engineering scenarios.

The simulation model includes:

- Production-style baseline measurement before tuning
- Controlled workload generation using stress tools
- Concurrent metric collection (CPU, memory, disk, network)
- Bottleneck identification through profiling & tracing
- Incremental kernel and system tuning
- Before/after validation with benchmark comparison
- Persistent configuration for production readiness
- Structured documentation & performance reporting

This repository represents practical performance optimization workflows — mirroring how real infrastructure performance investigations are conducted in enterprise environments.

---

# 📊 Linux Performance Engineering Skills Heatmap

This heatmap reflects **hands-on implementation across 20 labs** in:

**CPU Optimization • Memory Tuning • Disk I/O Engineering • Kernel Tuning • Network Performance • Profiling • Resource Governance • Container Performance**

> Exposure bars use text-block visualization similar to previous repositories.

| Skill Area | Exposure Level | Practical Depth | Tools / Technologies Used |
|------------|---------------|----------------|----------------------------|
| 🧠 CPU Scheduler Optimization | ▓▓▓▓▓▓▓▓▓▓ 100% | Latency tuning, affinity, migration cost tuning | `taskset`, `sysctl`, scheduler params |
| 🧮 Memory & Swap Tuning | ▓▓▓▓▓▓▓▓▓░ 90% | Swappiness tuning, pressure analysis, VM behavior | `vmstat`, `/proc/meminfo`, `sysctl` |
| 💾 Disk I/O Engineering | ▓▓▓▓▓▓▓▓▓▓ 100% | Scheduler comparison, read-ahead tuning, benchmarking | `fio`, `iostat`, `blktrace`, `dd` |
| 🧵 Block-Layer Tracing | ▓▓▓▓▓▓▓▓░░ 85% | I/O latency pattern analysis, queue depth tuning | `blktrace`, `blkparse` |
| 🌐 Network Stack Tuning | ▓▓▓▓▓▓▓▓▓░ 90% | TCP buffer tuning, NIC offload optimization | `sysctl`, `ethtool`, `iperf3`, `ss` |
| 🔍 Profiling & Low-Level Analysis | ▓▓▓▓▓▓▓▓░░ 85% | CPU cycles, cache misses, syscall tracing | `perf`, `strace` |
| ⚙️ Kernel Parameter Engineering | ▓▓▓▓▓▓▓▓▓▓ 100% | Persistent tuning, rollback validation | `sysctl`, `/etc/sysctl.d/` |
| 🏗 cgroups v2 Resource Governance | ▓▓▓▓▓▓▓▓▓░ 90% | CPU/memory/I/O isolation & service limits | `cgroups v2` |
| 🗄 Filesystem Performance Tuning | ▓▓▓▓▓▓▓▓░░ 85% | ext4/XFS/Btrfs mount optimization | `mkfs`, mount options |
| 🐳 Container Performance Tuning | ▓▓▓▓▓▓▓░░░ 80% | Resource limits, monitoring, throttling analysis | Docker, Kubernetes |
| 🗃 Database Performance Alignment | ▓▓▓▓▓▓▓░░░ 80% | OS + PostgreSQL tuning alignment | PostgreSQL, kernel tuning |
| 📈 Monitoring & Observability | ▓▓▓▓▓▓▓▓▓▓ 100% | Historical metrics, baseline validation | `sar`, `sysstat`, `top`, `htop` |
| 🧪 Workload Benchmarking | ▓▓▓▓▓▓▓▓▓░ 90% | Stress-driven validation, before/after comparison | `stress-ng`, `sysbench` |

## 🏆 Proficiency Scale

- ▓▓▓▓▓▓▓▓▓▓ = Implemented End-to-End with Validation & Persistence  
- ▓▓▓▓▓▓▓▓▓░ = Advanced Practical Implementation  
- ▓▓▓▓▓▓▓░░░ = Strong Working Implementation  
- ▓▓▓▓▓░░░░░ = Foundational + Applied Exposure  

This heatmap reflects **program-level performance engineering capability**, not isolated tuning commands — covering:

> Baseline → Monitoring → Bottleneck Detection → Kernel/System Tuning → Validation → Persistence → Documentation

---

# 🧪 How To Use

```bash
git clone https://github.com/abdul4rehman215/Red-Hat-Linux-Performance-Tuning-Linux-in-Physical-Virtual-and-Cloud.git
cd Red-Hat-Linux-Performance-Tuning-Linux-in-Physical-Virtual-and-Cloud

# Open any lab
cd labXX-name

# Follow steps
cat README.md
bash commands.sh
cat output.txt
````

> Each lab is self-contained and includes **baseline setup, tuning steps, validation outputs, troubleshooting notes, and interview Q&A**.

---

# 🖥️ Execution Environment

All 20 labs were executed in controlled Linux environments designed to simulate realistic infrastructure performance engineering scenarios.

Environment characteristics:

- RHEL 8 / 9, CentOS Stream, Ubuntu 20.04 / 22.04
- Physical servers, virtual machines, and cloud instances
- Isolated lab systems for safe stress testing & benchmarking
- Controlled workload generation (`stress-ng`, `sysbench`)
- Concurrent metric collection (CPU, memory, disk, network)
- Profiling & tracing using `perf`, `strace`, `blktrace`
- Persistent configuration validation via `sysctl`, I/O schedulers, mount options, and cgroups

Outputs were validated using before/after benchmark comparisons and structured performance reports to reflect production-style engineering quality.

---

# 🎯 Intended Use

This repository is designed to support:

- Linux performance engineering training
- Infrastructure bottleneck analysis practice
- Kernel & scheduler optimization workflows
- Cloud VM and database performance tuning
- Container resource governance (Docker / Kubernetes)
- DevOps benchmarking & validation pipelines
- Structured performance documentation & reporting

All methodologies reflect enterprise system optimization practices aligned with Red Hat performance tuning objectives.

---

# ⚖️ Ethical & Professional Notice

All performance experiments were conducted:

- In isolated lab environments
- On controlled physical, virtual, or cloud test systems
- Using synthetic workloads and benchmarking tools
- Without impacting production infrastructure

No production systems were modified without authorization.

The techniques demonstrated in this repository are intended solely for responsible system optimization within approved environments.

---

# ⭐ Final Note

This repository reflects **real hands-on Linux performance engineering work** — not theoretical study.

It demonstrates structured capability in:

> **Measure • Diagnose • Tune • Validate • Persist • Document**

Across CPU, memory, disk, networking, virtualization, databases, containers, and kernel internals — aligned with enterprise Linux administration and Red Hat performance tuning practices.

If this repository adds value, consider starring it ⭐

Happy Optimizing 🚀

---

## 👨‍💻 Author

**Abdul Rehman**  
Linux Performance Engineering • Infrastructure Optimization • System Tuning

### 📧 Reach Out

  <a href="https://github.com/abdul4rehman215">
    <img src="https://img.shields.io/badge/Follow-181717?style=for-the-badge&logo=github&logoColor=white" alt="Follow" />
  </a>  
  <a href="https://linkedin.com/in/abdul4rehman215">
     <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white&v=1" />
  </a>
  <a href="mailto:abdul4rehman215@gmail.com">
    <img src="https://img.shields.io/badge/Email-EE0000?style=for-the-badge&logo=gmail&logoColor=white" />
  </a>

---
