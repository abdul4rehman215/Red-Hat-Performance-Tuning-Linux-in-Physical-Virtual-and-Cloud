# 🧪 Lab 11: Optimizing File System Utilization

> **Focus:** File system performance tuning using advanced mount options and filesystem-specific parameters (EXT4, XFS, Btrfs) with benchmarking and analysis in an enterprise Linux environment.

---

## 📌 Lab Summary

In this lab, I optimized file system performance by tuning mount options (e.g., `noatime`, `nodiratime`) and applying filesystem-specific tuning techniques for **ext4**, **xfs**, and **btrfs**. I then validated improvements using repeatable benchmarks, I/O monitoring, and resource impact checks (CPU + memory).

This lab reflects real-world storage performance tuning tasks commonly performed on production Linux servers running high I/O workloads.

---

## 🎯 Objectives

By the end of this lab, I was able to:

- Configure advanced mount options like `noatime` and `nodiratime` to reduce metadata writes
- Apply filesystem tuning strategies for data-heavy workloads
- Compare performance characteristics across **ext4**, **xfs**, and **btrfs**
- Benchmark file system performance using standardized tests
- Monitor I/O behavior using `iostat` and evaluate system resource impact
- Produce a structured performance comparison report for decision-making

---

## ✅ Prerequisites

- Basic Linux filesystem and mount knowledge
- Command-line comfort + editor usage
- Understanding of storage concepts (partitions, mount points, block devices)
- Familiarity with performance tools (`iostat`, `top`, `free`, `dd`, `time`)

---

## 🧰 Lab Environment

- **Platform:** Cloud-based Enterprise Linux lab machine
- **OS:** CentOS/RHEL 8/9 style system
- **Shell Prompt:** `-bash-4.2$`
- **Access:** `sudo` / root-capable lab user
- **Primary FS (root):** XFS (observed)
- **Testing Method:** Loopback-backed images mounted as EXT4/XFS/Btrfs for controlled benchmarking

---

## 🗂️ Repository Structure

```text
lab11-optimizing-file-system-utilization/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── baseline_test.sh
    ├── optimized_test.sh
    ├── comprehensive_test.sh
    ├── filesystem_benchmark.sh
    ├── io_monitor.sh
    ├── resource_monitor.sh
    └── generate_report.sh
````

> **Note:** Scripts were created under `/opt/fstest/` during execution. For GitHub organization and portability, they are placed under `scripts/` in this lab folder.

---

## ✅ Tasks Overview

### **Task 1: Configure Advanced Mount Options for Performance**

* Reviewed current filesystem mounts and options (`mount`, `/proc/mounts`, `df -h`)
* Created a test directory and used `stat` to observe **atime behavior**
* Built an EXT4 loopback filesystem and ran a baseline workload
* Remounted with `noatime,nodiratime` and compared performance + timestamp behavior
* Attempted additional EXT4 mount optimizations; corrected unsupported options and remounted with supported performance options (`data=writeback`)

### **Task 2: Tune File System Types and Options**

* Built separate loopback filesystems and mounted each with tuned options:

  * **EXT4 tuning**

    * Custom mkfs parameters including stride/stripe-width and journal changes
    * Tuned runtime disk queue parameters (`read_ahead_kb`, scheduler)
  * **XFS tuning**

    * Tuned mkfs layout options and mounted with log buffer optimizations
    * Adjusted runtime XFS parameters under `/sys/fs/xfs/...`
  * **Btrfs tuning**

    * Mounted with compression + cache optimizations (`compress=lzo`, `space_cache=v2`, `commit=60`)
    * Performed defragment + verified filesystem usage

### **Task 3: Test and Compare Different File Systems**

* Built a standardized benchmark suite:

  * Sequential write/read workload
  * Small file creation/read workload
  * Directory operations
  * Deletion/cleanup performance
* Performed advanced analysis:

  * **I/O monitoring** using `iostat -x` during mixed workload
  * **Resource monitoring** using `top` + `free` before/after heavy operations
* Generated a final **performance comparison report** summarizing:

  * mount option differences
  * filesystem features snapshot
  * tuning guidance + recommendations

---

## 🧪 Validation & Evidence

Validation steps used to confirm tuning impact:

* Verified mount flags after remounts (`mount | grep ...`)
* Confirmed atime changes vs noatime behavior using `stat`
* Compared baseline vs optimized timings from repeatable test scripts
* Validated loop device mappings with `losetup -a`
* Used cache-drop + sync to reduce benchmark inconsistency (`sync`, `drop_caches`)
* Collected benchmark outputs into report files (`tee` into results)

All execution outputs and timings are captured in:

* `output.txt`
* generated reports saved during execution (referenced in output)

---

## 📊 Results Summary

Key outcomes observed during testing:

* **noatime/nodiratime** reduced access-time metadata churn and improved read-heavy performance consistency
* EXT4 and XFS performed strongly across sequential and metadata-heavy workloads
* Btrfs showed benefit from compression features but was slower in small-file churn tests in this run
* Standardized benchmarking produced comparable timing outputs across filesystems
* I/O monitoring logs confirmed differences in device behavior across workloads
* Resource tests highlighted slightly higher overhead during compression-heavy operations

---

## 🧠 What I Learned

* Why access-time updates can become a bottleneck in read-heavy systems
* How to design controlled, repeatable filesystem benchmarks
* The practical differences between EXT4, XFS, and Btrfs tuning strategies
* How runtime queue tuning (scheduler, read-ahead) impacts storage behavior
* How to correlate benchmark results with I/O telemetry and system resource usage

---

## 🌍 Why This Matters

File system tuning directly impacts:

* application responsiveness
* I/O latency and throughput
* scalability under load
* infrastructure cost efficiency (better performance per resource)

These tuning practices are highly relevant to:

* databases
* web servers
* log pipelines
* high-throughput analytics workloads
* cloud instances running storage-intensive services

---

## 🧩 Real-World Applications

This lab maps to production tasks such as:

* optimizing database storage mounts (`noatime`, writeback strategies)
* selecting the right filesystem for workload type (small-file vs large-file throughput)
* tuning mount and scheduler options for improved I/O performance
* building standardized benchmark baselines for infrastructure decisions
* preparing performance tuning documentation for ops teams

---

## 🧹 Cleanup (Executed)

Cleanup steps included:

* unmounting all test mounts
* detaching loop devices
* removing test filesystem images and temporary logs
* preserving benchmark outputs and reports under `/opt/fstest/`

(Full cleanup commands and results are included in `output.txt` and `commands.sh`.)

---

## ✅ Conclusion

This lab demonstrated enterprise-grade filesystem optimization by combining:

* mount option tuning (`noatime`, `nodiratime`, filesystem-specific flags)
* filesystem creation and runtime parameter adjustments
* benchmarking and performance comparison across EXT4/XFS/Btrfs
* monitoring I/O behavior and resource impact
* generating structured tuning recommendations based on results

✅ Lab completed successfully on a cloud-based Enterprise Linux environment
