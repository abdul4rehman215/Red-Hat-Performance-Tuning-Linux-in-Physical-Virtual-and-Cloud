README.md
# 🧪 Lab 16: Implementing Performance Monitoring with `sar` (sysstat)

**Category:** Red Hat Performance Tuning (Linux in Physical, Virtual, and Cloud)  
**Lab Focus:** Historical performance monitoring + reporting automation  
**Environment:** CentOS/RHEL-style cloud lab machine (`-bash-4.2$`)  
**Host (from output):** `ip-172-31-10-214`  
**Kernel (from output):** `3.10.0-1160.el7.x86_64`

---

## 🎯 Objectives

By completing this lab, I was able to:

- Install and configure **sysstat/sar** for system activity monitoring
- Enable **automated historical collection** via `sysstat` service + cron jobs
- Analyze **CPU, memory, disk I/O, and network trends** using sar reports
- Generate **performance reports** for optimization and troubleshooting
- Build **custom scripts** for daily reporting, dashboards, and trend summaries
- Apply best practices for **long-term monitoring** in Linux environments

---

## 🧰 Prerequisites

- Basic Linux CLI knowledge
- Understanding of CPU/memory/disk/network concepts
- Familiarity with cron and permissions
- sudo/root access for system-level configuration

---

## ✅ What I Did in This Lab 

### 1) Installed and validated `sar`
- Verified `sar` was missing initially
- Installed `sysstat`
- Verified `sar` binary and `sysstat version`

### 2) Enabled historical collection
- Enabled + started `sysstat` service
- Configured retention and collection options in:
  - `/etc/sysconfig/sysstat`
  - `/etc/cron.d/sysstat`

### 3) Added custom collection + reporting automation
- Created a custom collector (`custom-sar-collect.sh`) that writes logs into:
  - `/var/log/sar-custom/`
- Generated workload for testing (`stress-ng`, `dd`) and confirmed sar data updates
- Built multiple focused analysis scripts:
  - CPU trends and peaks
  - Memory + swap + paging
  - Disk I/O utilization and wait time indicators
  - Network interface + TCP summary

### 4) Generated reports and dashboards
- Created a full performance report generator (writes `/tmp/performance-report-YYYY-MM-DD.txt`)
- Created a historical trend analyzer (weekly roll-up)
- Created daily report automation (saved into `/var/log/performance-reports/`)
- Created a lightweight “terminal dashboard” loop for quick checks

---

## 📊 Results Summary (From Captured Output)

- `sar` data files were created under: `/var/log/sa/` (e.g., `sa25`, `sar25`)
- Live sar CPU sampling confirmed workload spikes occurred (example peak around `10:10`)
- Report generation succeeded:
  - `/tmp/performance-report-2026-02-25.txt`
  - `/tmp/historical-trends-2026-02-25.txt`
  - `/var/log/performance-reports/daily-report-2026-02-25.txt`

---

## 🌍 Why This Matters (Real-World Relevance)

Performance issues in production rarely appear “right now” — the real value is having **history**:

- **Incident investigation:** correlate spikes with events/time windows
- **Capacity planning:** identify growth patterns early
- **Optimization validation:** prove whether a tuning change helped or harmed
- **Proactive operations:** detect resource pressure before service impact

---

## 🧠 What I Learned

- How sysstat uses **scheduled collectors** (`sa1`, `sa2`) to build historical datasets
- How to read and interpret key sar outputs quickly:
  - CPU `%user/%system/%iowait/%idle`
  - Memory `%memused`, commit, paging (`sar -B`)
  - Disk `tps`, `await`, `%util`
  - Network `rx/tx kB/s`, TCP segments
- How to structure performance automation scripts into reusable reporting tools

---

## 🧹 Cleanup Notes

- Workload generator test file created: `/tmp/testfile` (optional removal)
- Custom logs stored under `/var/log/sar-custom/`
- Reports stored in `/tmp/` and `/var/log/performance-reports/`

---

## 📁 Repo Structure (for this lab)

```text
lab16-implementing-performance-monitoring-with-sar/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── custom-sar-collect.sh
    ├── cpu-analysis.sh
    ├── memory-analysis.sh
    ├── disk-analysis.sh
    ├── network-analysis.sh
    ├── performance-report.sh
    ├── historical-analysis.sh
    ├── daily-performance-report.sh
    └── performance-dashboard.sh
