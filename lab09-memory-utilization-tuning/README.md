# 🧪 Lab 09: Memory Utilization Tuning (Ubuntu 20.04)

## 📌 Overview
This lab focuses on **Linux memory tuning** by adjusting virtual memory (VM) parameters such as **swappiness**, and validating the impact using **monitoring + stress testing**.  
It also covers handling a common cloud scenario: **systems shipped without swap enabled**, which affects tuning behavior.

---

## 🎯 Objectives
By the end of this lab, I was able to:
- Understand Linux memory utilization and caching behavior
- Tune `vm.swappiness` to control swap aggressiveness
- Monitor memory behavior using `free`, `vmstat`, and `/proc/meminfo`
- Create repeatable scripts to apply and validate memory tuning
- Enable swap on systems where it is missing (for realistic testing)

---

## ✅ Prerequisites
- Ubuntu 20.04 LTS (cloud VM)
- sudo/root access
- Basic Linux commands (files, processes, editors)
- Tools: `sysctl`, `free`, `vmstat`
- Optional: `stress-ng` for controlled memory pressure tests

---

## 🧪 What Was Done (Task Overview Only)
### Task 1 — Baseline + Swappiness Tuning
- Captured baseline memory metrics
- Checked swap availability (not present by default in the VM)
- Tuned `vm.swappiness` temporarily and persistently

### Task 2 — Monitoring Memory Usage
- Used `free` for quick snapshots and periodic monitoring
- Used `vmstat` for deeper VM + swap activity indicators
- Created scripts for repeatable monitoring/logging

### Task 3 — Stress Testing + Validation
- Generated memory pressure using `stress-ng` and lightweight methods
- Compared multiple swappiness values
- Enabled swap (swapfile) to make the swappiness comparison meaningful
- Built optimization + validation scripts for repeatable checks

---

## 📁 Repo Structure 
```text
lab09-memory-utilization-tuning/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
├── reports/
│   ├── memory_baseline.txt
│   ├── performance_analysis.txt
│   └── optimization_validation_*.log
├── scripts/
│   ├── memory_tune.sh
│   ├── explain_free.sh
│   ├── monitor_memory.sh
│   ├── explain_vmstat.sh
│   ├── advanced_memory_monitor.sh
│   ├── simple_memory_stress.sh
│   ├── memory_performance_test.sh
│   ├── swappiness_comparison.sh
│   ├── optimize_memory.sh
│   └── validate_optimization.sh
└── outputs/
    ├── trace_logs_or_vmstat_logs_here.txt
    ├── memory_usage.log
    ├── advanced_memory_*.log
    └── advanced_memory_*.log.free
````

---

## ✅ Key Results 

* Confirmed how Linux uses **buff/cache** aggressively while keeping **available** memory healthy.
* Demonstrated that **swappiness tuning matters only when swap exists**.
* Validated tuning behavior through monitoring + workload simulation.
* Implemented safer workflow:

  * baseline → change → test → validate → document

---

## 🧠 What I Learned

* Why **available memory** is more meaningful than **free memory**
* How `vm.swappiness` affects swapping behavior under pressure
* How to measure memory health using `free`, `vmstat`, `/proc/meminfo`
* How to run controlled stress tests and capture comparable results
* How to enable swap safely for lab/testing environments

---

## 💡 Why This Matters

Memory tuning is critical for:

* Preventing slowdowns caused by swapping under load
* Improving response time for apps (databases, web apps, services)
* Making systems more stable under unpredictable workload spikes
* Building production-ready monitoring + validation habits

---

## 🌍 Real-World Relevance

This lab maps directly to real admin work such as:

* Linux performance tuning on cloud VMs
* Handling “no swap” default images safely
* Troubleshooting memory pressure and latency issues
* Preparing tuning baselines for production change management

---

## ✅ Conclusion

Lab 09 established a practical workflow for memory tuning:
**baseline → tune → test → validate → document**, using repeatable scripts and realistic cloud VM constraints.
