# 🎤 Interview Q&A - Lab 17: Performance Tuning for Databases (PostgreSQL on RHEL/CentOS)

## 1) Why is `vm.swappiness` reduced for database servers?
Databases rely heavily on RAM caching. High swappiness can push memory pages to swap even when RAM is available, increasing latency. Lowering `vm.swappiness` (e.g., to `1`) helps keep database working sets in memory and avoids swap thrashing.

## 2) What do `vm.dirty_ratio` and `vm.dirty_background_ratio` control?
They control how much dirty (modified) memory the kernel can accumulate before forcing writeback:
- `vm.dirty_background_ratio`: when background writeback starts.
- `vm.dirty_ratio`: the max dirty threshold before processes are forced to write.
For databases, tuning these can reduce latency spikes and improve write consistency.

## 3) Why are shared memory limits (`kernel.shmmax`, `kernel.shmall`) relevant to PostgreSQL?
PostgreSQL uses shared memory for components like `shared_buffers`. If shared memory limits are too low, PostgreSQL may fail to start or cannot allocate needed memory. Increasing these limits supports larger memory allocations safely.

## 4) What is PostgreSQL `shared_buffers`, and why did we increase it?
`shared_buffers` is the memory PostgreSQL allocates for caching table/index pages. Increasing it (commonly ~25% of RAM for dedicated DB servers) reduces disk reads and improves query performance.

## 5) What is `effective_cache_size` and what does it actually change?
It is a planner hint (not allocated memory). It tells PostgreSQL how much OS + PostgreSQL cache is likely available, helping it choose better query plans (e.g., index scans vs sequential scans).

## 6) What is `work_mem` and what risk comes with increasing it?
`work_mem` is per-operation memory used for sorts/hash joins. If increased too much and many queries run concurrently, total memory usage can explode (work_mem × concurrent operations), risking OOM.

## 7) Why did we set `maintenance_work_mem` higher?
It speeds up maintenance operations like VACUUM, CREATE INDEX, and ALTER TABLE by providing more memory for those operations.

## 8) Why did we choose `mq-deadline` as the I/O scheduler for database workloads?
Database workloads have mixed/random I/O and benefit from predictable latency. `mq-deadline` often provides stable latency behavior and prevents starvation compared to some schedulers on certain storage types.

## 9) Why did we add `noatime,nodiratime` to `/etc/fstab`?
These options stop frequent access-time updates (metadata writes) on every file access. Reducing unnecessary writes can improve I/O performance, especially for read-heavy DB workloads.

## 10) What is disk read-ahead (`blockdev --setra`) and why tune it?
Read-ahead controls how much data the kernel prefetches. Databases often do random reads; very high read-ahead can waste I/O and pollute cache. In this lab we set it explicitly and made it persistent via systemd service to control behavior consistently.

## 11) Why tune TCP buffers for database traffic?
Database servers may handle many concurrent connections and large query results. Larger TCP buffers and backlog settings can improve throughput and reduce drops/retries under load.

## 12) What problem does PgBouncer solve?
PgBouncer provides connection pooling. Instead of PostgreSQL handling thousands of client connections directly (which is expensive), PgBouncer reuses backend connections and reduces overhead, improving scalability.

## 13) What is `pg_stat_statements` and why enable it?
It tracks query execution statistics (calls, total time, mean time). It helps identify slow/heavy queries and prioritize optimization (indexes, query rewrite, config tuning).

## 14) Why did the workload script run `psql` as `sudo -u postgres`?
On many RHEL installs, PostgreSQL uses peer authentication for local socket connections. Running queries as the `postgres` OS user avoids authentication failures while preserving lab intent.

## 15) What does cache hit ratio indicate and what’s a “good” value?
Cache hit ratio = `blks_hit / (blks_hit + blks_read)`.  
High values (commonly >95%) suggest most reads are served from memory cache rather than disk. In the lab, it was ~99.79%, indicating strong caching performance.

## 16) What does high sequential scan (`seq_scan`) output imply?
It means PostgreSQL is scanning tables sequentially rather than using indexes. It may be fine for small tables, but on large tables it can indicate missing indexes, stale stats, or inefficient queries.

## 17) Why do we reset stats before benchmarking (`pg_stat_reset`, `pg_stat_statements_reset`)?
Resetting removes old history so measurement reflects only the current workload run. This makes baseline vs tuned comparisons accurate.

## 18) How would you safely roll back tuning changes if performance gets worse?
- Restore backups (`/etc/sysctl.conf.backup`, `postgresql.conf.backup`, `/etc/fstab.backup`)
- Revert scheduler changes (remove udev rule)
- Disable PgBouncer if misconfigured
- Restart affected services carefully (`postgresql`, `systemd-udevd`, etc.)
