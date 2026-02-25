# 🧪 Lab 03: Viewing Hardware Resources

## 🧾 Lab Summary
In this lab, I performed a **complete hardware resource review** on a Linux system using standard CLI utilities. I analyzed CPU architecture and capabilities with `lscpu`, validated memory usage patterns with `free` and `/proc/meminfo`, inspected storage devices using `lsblk` and `df`, and collected detailed system hardware inventory using `lshw`.  

To make the lab repeatable and portfolio-ready, I created scripts to generate a **system resource report**, continuously monitor utilization over time, and produced baseline documentation artifacts (`resource_log.csv` and `baseline_report.txt`) that can be used later for capacity planning and optimization decisions.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Interpret hardware resource utilization using command-line tools
- Analyze CPU specifications and performance characteristics using `lscpu`
- Monitor memory usage and availability using `free`
- Examine block devices and storage layouts using `lsblk`
- Gather comprehensive hardware information using `lshw`
- Identify underutilized resources that could be optimized
- Support system capacity planning and resource allocation decisions

---

## ✅ Prerequisites
- Basic Linux command-line usage (navigation, file ops, command execution)
- Understanding of CPU/RAM/storage fundamentals
- Familiarity with terminal operations
- Basic system administration knowledge
- Understanding of performance monitoring principles

---

## 🖥️ Lab Environment
**Environment:** Cloud-based Linux lab VM  
**OS Family:** CentOS/RHEL 8/9  
**Privileges:** sudo/root access available  
**Key Tools Used:** `lscpu`, `free`, `lsblk`, `df`, `iostat`, `lshw`, `ip`, `ping`, `top`, `htop`

---

## 📁 Repository Structure
```text
lab03-viewing-hardware-resources/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── system_report.sh
    └── monitor_resources.sh
````

---

## 🧩 Lab Tasks Overview (What I Did)

### ✅ Task 1: Analyzing CPU Resources with `lscpu`

#### Subtask 1.1: Basic CPU Information Gathering

* Ran `lscpu` to identify:

  * architecture, logical CPU count, sockets/cores/threads
  * virtualization details (KVM)
  * cache sizes
  * CPU instruction flags

#### Subtask 1.2: Advanced CPU Analysis

* Filtered CPU frequency-related fields (MHz/GHz)
* Reviewed cache levels (L1/L2/L3)
* Examined CPU flags to understand supported instruction sets and platform capabilities

✅ Practical interpretation:

* Total logical CPUs = sockets × cores/socket × threads/core
* Based on lab output: `1 × 1 × 2 = 2 logical CPUs`

---

### ✅ Task 2: Memory Analysis with `free` and `/proc/meminfo`

#### Subtask 2.1: Basic Memory Information

* Used `free -h` for quick view of total/used/free/buffers/cache
* Used `free -h --wide` for a more detailed breakdown (buffers + cache)
* Observed memory changes over time using `free -h -s 5 -c 3`

#### Subtask 2.2: Advanced Memory Analysis

* Reviewed `/proc/meminfo` for detailed kernel memory values
* Calculated memory utilization percentage using `awk`
* Verified swap configuration and current swap usage (`swapon --show`)

Key interpretation reminders used in this lab:

* Available memory is more meaningful than “free” memory
* buffer/cache is reclaimable when needed
* swap usage can indicate memory pressure when consistently high

---

### ✅ Task 3: Storage Device Analysis with `lsblk`, `df`, and `iostat`

#### Subtask 3.1: Basic Block Device Information

* Listed block devices and partitions using `lsblk`
* Displayed filesystem types and mountpoints using `lsblk -f`
* Displayed human-readable sizes using `lsblk -h`

#### Subtask 3.2: Advanced Storage Analysis

* Printed storage details with explicit columns (name/size/type/mount/fstype/uuid)
* Reviewed mounted filesystem usage with `df -h`
* Observed disk I/O performance characteristics using `iostat -x`

Interpretation notes:

* NVMe naming (`nvme0n1`) indicates modern storage type
* Filesystem type (`xfs`) can affect tuning options
* Disk utilization (`%util`) and latency (`await`) are core I/O indicators

---

### ✅ Task 4: Comprehensive Hardware Analysis with `lshw`

#### Subtask 4.1: Complete System Overview

* Verified whether `lshw` existed; installed it when missing
* Generated a complete hardware inventory using `sudo lshw`
* Generated a concise summary view using `sudo lshw -short`
* Focused on key hardware classes:

  * processor, memory, disk, network

This produced detailed hardware identification such as:

* CPU model
* system memory size
* network adapter type (ENA)
* NVMe storage controller information

#### Subtask 4.2: Network Hardware Analysis

* Reviewed NIC details using `sudo lshw -class network`
* Checked interface state using `ip link show`
* Inspected addressing using `ip addr show`
* Validated external connectivity and latency using `ping -c 4 8.8.8.8`

---

### ✅ Task 5: Resource Utilization Analysis & Optimization

#### Subtask 5.1: Real-Time Monitoring

* Used `top` for real-time performance snapshot
* Installed `htop` when not present and verified it runs
* Checked load averages using `uptime`

#### Subtask 5.2: Underutilized Resource Identification

Created reusable scripts:

* `system_report.sh` → generates a full resource analysis snapshot
* `monitor_resources.sh` → monitors CPU/memory/disk over 60 seconds and exports to CSV

Generated artifacts:

* `resource_log.csv` → time-series snapshot for quick utilization review
* `baseline_report.txt` → summarized system baseline details

#### Subtask 5.3: Optimization Recommendations

Using collected metrics, I evaluated:

* CPU headroom (very low usage)
* memory pressure (low usage, swap unused)
* disk usage (low usage percentage)
* network health (stable connectivity + low latency)

---

## ✅ Verification & Validation

I validated completion by confirming:

* CPU analysis outputs available (`lscpu` + filtered outputs)
* Memory analysis outputs available (`free`, `/proc/meminfo`, `swapon`)
* Storage view confirmed (`lsblk`, `df`, `iostat`)
* `lshw` installed and hardware inventory collected (`lshw`, `lshw -short`)
* Connectivity verified (`ping`)
* Scripts created and executed successfully:

  * `system_report.sh`
  * `monitor_resources.sh`
* Reports/artifacts generated:

  * `resource_log.csv`
  * `baseline_report.txt`

---

## 📌 Result

At the end of this lab, I produced a clear and repeatable hardware baseline:

* CPU: 2 logical CPUs (1 socket, 1 core, 2 threads)
* Memory: ~3.7 GiB, low utilization, swap unused
* Storage: NVMe root disk + additional disk device present
* Network: ENA adapter, stable connectivity, low latency
* Automation: scripts and CSV logs for repeatable monitoring

---

## 🧠 What I Learned

* Hardware visibility is the foundation for performance tuning and capacity planning
* CPU topology (threads/cores/sockets) matters for interpreting load and scheduling
* `MemAvailable` is more meaningful than `MemFree` on Linux
* Storage type (NVMe vs SATA) changes device naming and performance expectations
* Inventory tools (`lshw`) can be missing on minimal images and may require install
* Lightweight scripts + CSV outputs improve repeatability and documentation quality

---

## 🌍 Why This Matters

Understanding hardware resources supports:

* Performance optimization and capacity planning
* Identifying bottlenecks and constraints early
* Making informed decisions about scaling in virtual/cloud environments
* Preparing for performance tuning certifications and real-world admin work

---

## ✅ Conclusion

In this lab, I successfully used essential Linux tools (`lscpu`, `free`, `lsblk`, `df`, `iostat`, `lshw`) to analyze CPU, memory, storage, and network hardware. I also built automated scripts to generate system reports and collect utilization samples over time, producing baseline documentation artifacts that are reusable for performance tuning and capacity planning in later labs.
