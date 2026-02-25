# 🧪 Lab 17: Performance Tuning for Databases (PostgreSQL on RHEL 8/9)

## 📌 Lab Overview
This lab focuses on **database performance tuning** by optimizing Linux **memory**, **disk I/O**, and **network parameters**, then validating improvements using PostgreSQL statistics and system monitoring tools.

You tuned both:
- **System-level parameters** (kernel + disk + network)
- **PostgreSQL configuration** (buffers, work memory, monitoring extensions)

---

## 🎯 Objectives
By the end of this lab, I was able to:

- Optimize database performance by tuning **disk**, **memory**, and **CPU-related** system parameters
- Configure **I/O scheduling** and **network buffers** for database workloads
- Implement performance monitoring using PostgreSQL + Linux tools
- Apply best practices for production-grade database performance tuning
- Understand how OS-level tuning impacts database throughput & latency

---

## ✅ Prerequisites
- Linux sysadmin basics (CLI, editors, services)
- Basic PostgreSQL familiarity
- Understanding of CPU/memory/disk/network performance concepts
- Sudo/root access

---

## 🧰 Lab Environment
**Platform:** Cloud lab machine (RHEL/CentOS style prompt `-bash-4.2$`)  
**Database:** PostgreSQL pre-installed  
**Tools:** `htop`, `iotop`, `iostat`, `sysstat`, `vmstat`, PostgreSQL contrib modules

---

## 🗂️ Repository Structure 
```text
lab17-performance-tuning-for-databases/
├── README.md
├── commands.sh
├── output.txt
├── interview_qna.md
├── troubleshooting.md
└── scripts/
    ├── database-io-tuning.sh
    ├── db_workload_test.sh
    ├── analyze_performance.sh
    └── performance_comparison.sh
````

---

## ✅ What You Did in This Lab (Task Overview)

### 🧠 Task 1: Tune Disk and Memory Settings for Database Workloads

* Checked baseline system memory and disk configuration (`free`, `swapon`, `sysctl`, `lsblk`, scheduler).
* Reviewed baseline PostgreSQL memory settings (`shared_buffers`, `work_mem`, etc.).
* Applied **kernel memory tuning**:

  * Reduced swapping pressure (`vm.swappiness=1`)
  * Tuned dirty page flushing behavior (`vm.dirty_ratio`, `vm.dirty_background_ratio`)
  * Set shared memory limits (`kernel.shmmax`, `kernel.shmall`)
  * Controlled overcommit behavior (`vm.overcommit_memory`, `vm.overcommit_ratio`)
* Tuned PostgreSQL memory configuration:

  * Increased `shared_buffers`, `effective_cache_size`, `work_mem`, `maintenance_work_mem`, `wal_buffers`

### 💾 Task 1 (Disk): Database-Friendly I/O & Filesystem Options

* Ensured database-friendly I/O scheduler selection (`mq-deadline`) and made it persistent via udev rule.
* Optimized filesystem mount flags:

  * Added `noatime,nodiratime` to reduce metadata write overhead
* Increased block-device read-ahead using `blockdev` and made persistent via a systemd oneshot service.

---

## ⚙️ Task 2: Adjust I/O Scheduling and Network Buffers for DB Traffic

### 🧱 Subtask 2.1: Fine-tune I/O scheduler parameters

* Tuned scheduler parameters (front merges, read/write expiry, starvation control).
* Created `/usr/local/bin/database-io-tuning.sh` to apply scheduler parameters at boot.
* Added it to `/etc/rc.local` for persistence (and ensured executable permissions).

### 🌐 Subtask 2.2: Optimize network buffers for PostgreSQL

* Increased TCP send/receive buffers (`net.core.rmem_max`, `net.core.wmem_max`, etc.).
* Enabled TCP scaling and tuning buffers (`tcp_rmem`, `tcp_wmem`).
* Increased backlog settings (`tcp_max_syn_backlog`, `netdev_max_backlog`).
* Updated PostgreSQL connection settings:

  * `max_connections`, listen settings, TCP keepalive tuning

### 🧩 Subtask 2.3: Implement Connection Pooling (PgBouncer)

* Installed PgBouncer
* Created:

  * `/etc/pgbouncer/pgbouncer.ini`
  * `/etc/pgbouncer/userlist.txt`
* Ensured correct permissions and started/enabled PgBouncer service.

---

## 📈 Task 3: Measure Database Performance

### 🔍 Subtask 3.1: Monitoring setup

* Installed monitoring tools and PostgreSQL contrib modules
* Enabled:

  * `pg_stat_statements`
  * logging collector + slow query logging behavior
* Restarted PostgreSQL to apply monitoring changes.
* Created database `testdb` and enabled extensions:

  * `pg_stat_statements`
  * `pgstattuple`

### 🧪 Subtask 3.2: Generate test data and run workload

* Created `customers` and `orders` tables with large dataset:

  * 100,000 customers
  * 500,000 orders
* Created indexes for realistic query paths
* Updated statistics using `ANALYZE`
* Built a concurrent workload script (`db_workload_test.sh`) to simulate OLTP-style queries.

### 🧾 Subtask 3.3–3.5: Baseline + analysis + comparison

* Reset PostgreSQL stats before test runs
* Captured system metrics (`iostat`, `vmstat`)
* Measured DB activity using:

  * `pg_stat_database`
  * `pg_stat_statements`
* Generated analysis report and a comparison script:

  * Cache hit ratio validation
  * Seq scan vs index scan visibility
  * “Top slow queries” breakdown

---

## ✅ Result Highlights

* **Cache Hit Ratio:** ~**99.79%**
* Identified query characteristics:

  * heavy sequential scans in workload patterns
  * index usage concentrated on `idx_orders_customer_id`
* Collected real evidence into logs:

  * `/tmp/iostat_baseline.log`, `/tmp/vmstat_baseline.log`
  * `/tmp/pg_baseline_end.log`
  * `/tmp/performance_analysis.txt`

---

## 🧠 Why This Matters (Real-World Relevance)

Database performance issues are often caused by **system misconfiguration** rather than “slow SQL” alone. These optimizations help:

* Reduce latency from disk writeback behavior
* Improve throughput by tuning buffers and scheduling
* Avoid CPU stalls caused by memory pressure & swapping
* Scale concurrent DB traffic using PgBouncer pooling
* Diagnose slow queries with pg_stat_statements and proper logging

---

## 🧹 Cleanup Notes (Optional)

This lab created large datasets and may increase disk usage. Optional cleanup steps include:

* Dropping `testdb` after exporting results
* Removing temporary workload output files in `/tmp`
* Reverting `/etc/sysctl.conf`, `/etc/fstab`, and PostgreSQL config backups if required

---
