# 🧪 Lab 12: Network Utilization Tuning

> **Focus:** Improving Linux network throughput and stability by tuning **TCP buffers (sysctl)**, optimizing **NIC settings (ethtool)**, validating performance with **iperf3**, and making optimizations **persistent** using **systemd**.

---

## 📌 Lab Summary

In this lab, I performed a complete **network performance tuning workflow** on an Ubuntu cloud lab setup using two VMs (server + client). I started by collecting baseline network configuration and throughput measurements, then applied performance optimizations at two layers:

1. **Kernel networking (sysctl):** Increased TCP buffer limits, enabled modern congestion control (**BBR**), and tuned backlog settings.
2. **NIC tuning (ethtool):** Increased ring buffers, enabled beneficial offloads, adjusted interrupt coalescing, and created a **systemd oneshot service** to persist settings.

Finally, I executed advanced iperf3 tests and monitored system resources during load using **sar (sysstat)**, producing comparison outputs saved to a results directory for reporting and GitHub documentation.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Understand fundamentals of network performance optimization in Linux
- Modify TCP buffer sizes using **sysctl** to improve throughput
- Configure network interface performance features using **ethtool**
- Measure and compare network performance using **iperf3**
- Apply a repeatable tuning methodology: **baseline → optimize → validate → persist**
- Troubleshoot typical performance and tooling issues in cloud Linux environments

---

## ✅ Prerequisites

- Linux command-line basics
- Understanding of TCP/IP (bandwidth, latency, RTT, buffers)
- Sudo/root privileges
- Familiarity with performance tooling (`iperf3`, `ethtool`, `sysctl`, `sar`)

---

## 🧰 Lab Environment

- **Platform:** Cloud lab VMs (2-node topology)
- **OS Used:** Ubuntu cloud lab
- **Nodes:**
  - **Server VM:** `ip-172-31-10-201` (NIC: `ens5`, IP: `172.31.20.10`)
  - **Client VM:** `ip-172-31-10-202` (NIC: `ens5`, IP: `172.31.20.11`)
- **Tools:**
  - `iperf3`, `ethtool`, `sysctl`, `sysstat (sar)`, `ping`
  - Additional utilities installed during lab: `net-tools` (for `ifconfig`), `bc`

> ⚠️ Note: This lab includes commands run on **both** server and client. Output artifacts are organized accordingly.

---

## 🗂️ Repository Structure

```text
lab12-network-utilization-tuning/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── scripts/
│   ├── check_tcp_buffers.sh
│   ├── calculate_buffers.sh
│   ├── analyze_interface.sh
│   ├── optimize_ring_buffers.sh
│   ├── optimize_offloads.sh
│   ├── optimize_coalescing.sh
│   ├── ethtool_persistent.sh
│   ├── comprehensive_test.sh
│   ├── monitor_performance.sh
│   ├── latency_analysis.sh
│   └── performance_comparison.sh
└── configs/
    ├── 99-network-performance.conf
    └── network-optimization.service
````

---

## ✅ Tasks Overview

### **Task 1: Baseline Network Performance Assessment**

* Identified NIC and IP configuration using `ip addr`, `ip -s link`
* Collected baseline TCP buffer and network sysctl values
* Validated NIC capabilities and defaults using `ethtool` (speed, ring buffers, offloads)
* Established baseline throughput using:

  * `iperf3` TCP (30s)
  * Saved baseline TCP/UDP/latency results into `~/network_tuning_results/baseline_results.txt`

### **Task 2: TCP Buffer Size Optimization**

* Audited existing TCP buffer configuration using a script (`check_tcp_buffers.sh`)
* Estimated optimal buffer size using a bandwidth-delay product approach (`calculate_buffers.sh`)
* Applied tuned sysctl parameters via:

  * `/etc/sysctl.d/99-network-performance.conf`
  * Increased max/default buffers, backlog values
  * Enabled **BBR** congestion control and TCP Fast Open
* Verified settings after applying sysctl changes
* Re-tested throughput and saved results to `tcp_optimized_results.txt`

### **Task 3: NIC Optimization with ethtool**

* Generated full interface analysis report (ring buffers, offloads, coalescing, driver info)
* Increased RX/TX ring buffers to maximum supported values
* Confirmed and enabled key offloads (where supported): TSO/GSO/GRO + checksum + scatter-gather
* Tuned interrupt coalescing to balance throughput and CPU usage
* Made ethtool settings persistent using:

  * `/usr/local/bin/ethtool_persistent.sh`
  * systemd oneshot service: `network-optimization.service`

### **Task 4: Comprehensive Performance Testing & Analysis**

* Ran multi-scenario performance tests (TCP window sizes, UDP rates, parallel streams, bidirectional/reverse)
* Captured results to `comprehensive_results.txt`
* Monitored CPU/memory/network stats during tests using `sar`
* Produced a comparison report extracting key throughput results and summarizing applied tuning:

  * `performance_comparison.txt`

---

## 🧪 Validation & Evidence

Validation steps performed:

* Confirmed active interface + link stats (`ip -s link`, `ethtool`)
* Verified sysctl tuning applied (`sysctl -p` + re-run check script)
* Verified congestion control (`tcp_available_congestion_control`, `tcp_congestion_control`)
* Verified ring buffer changes (`ethtool -g`)
* Verified persistent service is enabled and active:

  * `systemctl status network-optimization.service`
* Confirmed results artifacts exist and contain data:

  * `baseline_results.txt`, `tcp_optimized_results.txt`, `comprehensive_results.txt`
  * `system_monitoring.txt`, `latency_analysis.txt`, `performance_comparison.txt`

---

## 📈 Observations (High-Level)

* Baseline throughput was measured first to avoid “tuning without proof”
* TCP buffer increases + BBR produced improved throughput under parallel load scenarios
* Ring buffer and coalescing tuning improved stability under bursty traffic patterns
* Some NIC features may show as `[fixed]` or “not supported” in virtual/cloud NICs—handled gracefully

---

## 🧠 What I Learned

* How TCP buffer sizing impacts throughput, especially on high-speed NICs
* How to safely apply network sysctl changes via `/etc/sysctl.d/`
* Practical ethtool tuning: ring buffers, offloads, interrupt coalescing
* How to make interface tuning persistent using systemd
* How to measure results properly using iperf3 and system monitoring with sar

---

## 🌍 Why This Matters

Network tuning is critical for:

* high-throughput systems (log pipelines, replication, backups)
* latency-sensitive services (APIs, trading systems, microservices)
* cloud environments with 10Gb+ NICs where defaults can limit performance
* production reliability (reducing retransmits, drops, and queue pressure)

---

## ✅ Conclusion

This lab demonstrated a full, repeatable network performance tuning workflow:

✅ Baseline measured with iperf3
✅ TCP buffers tuned and applied persistently via sysctl.d
✅ NIC optimized using ethtool (ring buffers, offloads, coalescing)
✅ Persistence implemented using a systemd oneshot service
✅ Advanced testing + monitoring performed with results stored for reporting

All commands, scripts, outputs, and configuration artifacts are included in this lab folder for GitHub portfolio documentation.

---

