# 🧪 Lab 05: Applying Tuned Profiles for Optimization

## 🧾 Lab Summary
In this lab, I used the **tuned daemon** on RHEL 9 to apply and compare multiple performance profiles. I verified tuned installation + service health, reviewed available profiles, captured baseline system configuration, and then applied:

- `balanced`
- `throughput-performance`
- `virtual-guest`

To compare behavior, I collected **repeatable baseline logs**, ran a **CPU + I/O stress test**, and extracted performance patterns (load averages, CPU utilization, memory usage).  
I also went beyond profile switching by analyzing profile configurations under `/usr/lib/tuned`, creating a **custom tuned profile** under `/etc/tuned`, and building scripts for **comparison reporting**, **real-time monitoring**, and **automated troubleshooting / best practices validation**.

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Explain what tuned does and why profiles matter
- Apply tuned profiles: `throughput-performance`, `virtual-guest`, and `balanced`
- Capture baseline metrics before/after profile changes
- Compare the effects of profiles on CPU governor, I/O scheduler, and key sysctl settings
- Select tuned profiles based on workload + environment (especially virtualization)
- Troubleshoot tuned issues using service + verification + logs

---

## ✅ Prerequisites
- Basic Linux CLI usage
- Familiarity with system monitoring concepts and performance metrics
- Understanding virtualization basics
- Root/sudo access
- tuned installed (`tuned-adm`, tuned service)

---

## 🖥️ Lab Environment
**Environment:** Cloud-based RHEL/CentOS lab VM  
**OS Version Observed:** RHEL 9.4  
**tuned Version Observed:** 2.22.0  
**Monitoring Tools:** `htop`, `sysstat/iostat`, `iotop`, `vmstat`, `top`  
**Storage:** NVMe (`/dev/nvme0n1`) on this VM (not `sda`)  
**Hostname Observed:** `ip-172-31-10-233`

---

## 📁 Repository Structure
```text
lab05-applying-tuned-profiles/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── performance_monitor.sh
    ├── stress_test.sh
    ├── compare_profiles.sh
    ├── performance_analysis.sh
    ├── realtime_monitor.sh
    ├── tuned_troubleshoot.sh
    ├── profile_switch_test.sh
    └── tuned_best_practices.sh
````

> Note: The lab also generated logs and reports:

* `~/tuned_performance_data/*.log` (baseline + profile logs)
* `~/stress_results_*.log` (stress monitoring outputs)
* `~/tuned_performance_report.txt` (summary report)

(These are reflected in `output.txt` and can be committed if you want, but the lab structure here keeps outputs centralized in `output.txt`.)

---

## 🧩 Lab Tasks Overview (What I Did)

### ✅ Task 1: Verify tuned setup + explore profiles

* Confirmed tuned packages are installed (`rpm -qa | grep tuned`)
* Verified `tuned.service` is running and enabled
* Listed available tuned profiles (`tuned-adm list`)
* Checked active profile (`tuned-adm active`) and recommendation (`tuned-adm recommend`)

---

### ✅ Task 2: Baseline performance monitoring

* Confirmed monitoring tools are present (`sysstat`, `htop`, `iotop`)
* Created `performance_monitor.sh` to capture:

  * system info, CPU, tuned profile
  * CPU governor
  * correct I/O scheduler path (NVMe-aware)
  * key kernel params: `vm.swappiness`, `kernel.sched_min_granularity_ns`, `net.core.rmem_max`
  * memory state + load averages
* Captured baseline log using current profile (`virtual-guest`)

---

### ✅ Task 3: Apply and test `balanced`

* Applied profile: `tuned-adm profile balanced`
* Verified correctness: `tuned-adm verify`
* Observed governor change: `performance → powersave`
* Ran stress test (`stress_test.sh`) and saved monitoring output

---

### ✅ Task 4: Apply and test `throughput-performance`

* Applied profile and verified
* Governor switched to `performance`
* Captured monitor log + stress test log
* Compared last monitoring iteration between balanced vs throughput-performance

---

### ✅ Task 5: Apply and test `virtual-guest`

* Re-applied the VM-optimized profile
* Verified applied state
* Captured monitoring + stress results and compared with other profiles

---

### ✅ Task 6: Advanced analysis + custom profile creation

* Read real tuned profile configurations:

  * `/usr/lib/tuned/balanced/tuned.conf`
  * `/usr/lib/tuned/throughput-performance/tuned.conf`
  * `/usr/lib/tuned/virtual-guest/tuned.conf`
* Created a custom profile:

  * `/etc/tuned/custom-lab-profile/tuned.conf`
* Applied and verified `custom-lab-profile`
* Collected monitoring + stress results for custom profile
* Updated comparison script to include the custom profile

---

### ✅ Task 7: Reporting + real-time monitoring

* Built `performance_analysis.sh` to generate a summary report:

  * extracts latest profile logs
  * summarizes CPU governor, scheduler, and swappiness
  * pulls stress test load lines
* Built `realtime_monitor.sh` for interactive, second-by-second observation

---

### ✅ Task 8: Troubleshooting + best practices automation

* Built `tuned_troubleshoot.sh`:

  * service status, daemon check, active profile, verify
  * recent tuned logs via `journalctl`
  * custom profile discovery
  * quick system resource sanity check
* Built `profile_switch_test.sh` to cycle through profiles and verify active state
* Built `tuned_best_practices.sh` checklist for service health + verification + recommendations

---

## ✅ Verification & Validation

This lab is complete when:

* tuned is installed and service is running:

  * `systemctl status tuned`
* profile switching works + verifies cleanly:

  * `tuned-adm profile <name>`
  * `tuned-adm verify`
* baseline + profile logs exist:

  * `~/tuned_performance_data/*.log`
* stress tests produced logs:

  * `~/stress_results_*.log`
* reports/scripts exist and run:

  * `~/tuned_performance_report.txt`
  * scripts in `scripts/`

---

## 📌 Result

Key outcomes observed:

* `balanced` switched CPU governor to **powersave** (more power-efficient behavior)
* `throughput-performance` and `virtual-guest` used **performance** governor (higher throughput intent)
* stress log comparison showed higher load averages under throughput-optimized settings
* tuned profile inheritance was verified by inspecting `tuned.conf` include chains
* custom profile creation demonstrated controlled overrides via `/etc/tuned/`

---

## 🧠 What I Learned

* tuned provides a safe, standardized way to apply tuned performance behaviors without manually editing dozens of sysctl/cpufreq settings
* profile choice depends on environment:

  * VM → `virtual-guest`
  * general use → `balanced`
  * max throughput → `throughput-performance`
* always capture baseline logs before switching profiles
* verify profile application (`tuned-adm verify`) and check tuned logs when something looks wrong
* profile configs are readable and composable (inheritance using `include=`)

---

## ✅ Conclusion

In this lab, I successfully used tuned to apply and compare performance profiles, validated changes using monitoring + stress tests, inspected profile configuration and inheritance, and created a custom tuned profile with supporting automation for reporting, troubleshooting, and best practices. This workflow mirrors how tuning is typically managed in real-world enterprise Linux environments.
