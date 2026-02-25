# 🎤 Interview Q&A — Lab 03: Viewing Hardware Resources

## 1) Why is hardware resource visibility important for performance tuning?
Because performance tuning depends on understanding system limits. Without knowing CPU topology, memory capacity, storage layout, and NIC capabilities, you can’t accurately interpret metrics, identify bottlenecks, or plan capacity.

---

## 2) What does `lscpu` tell you that is useful for capacity planning?
`lscpu` provides:
- total logical CPUs
- sockets/cores/threads (topology)
- CPU model and clock speed
- cache sizes
- virtualization details and CPU flags  
These determine compute capacity and help interpret load averages and scheduling behavior.

---

## 3) How do you calculate total logical CPUs?
Using:
**Total logical CPUs = sockets × cores per socket × threads per core**  
In this lab:
- sockets = 1
- cores/socket = 1
- threads/core = 2  
So: **1 × 1 × 2 = 2 logical CPUs**

---

## 4) What’s the difference between cores and threads?
- **Core:** physical CPU execution unit
- **Thread (hyperthread):** logical execution context per core  
Hyperthreading can improve throughput for some workloads but doesn’t double raw performance.

---

## 5) Why do CPU cache sizes matter (L1/L2/L3)?
Cache reduces memory access latency. Larger or more efficient caches can significantly improve performance for workloads with repeated data access, such as databases, compression, compilation, and some analytics.

---

## 6) What is the key difference between `MemFree` and `MemAvailable`?
- **MemFree:** truly unused memory
- **MemAvailable:** memory available for new applications *without swapping*, including reclaimable cache  
MemAvailable is usually the better indicator of whether the system has memory headroom.

---

## 7) Why is buffer/cache memory not automatically “bad”?
Linux uses free memory for caching to improve performance. Cache is generally reclaimable when applications need RAM, so high cache usage can be normal and beneficial.

---

## 8) What does swap usage indicate, and what did you observe in this lab?
Swap usage indicates memory pressure if it’s consistently used.  
In this lab:
- swap total was available
- swap used was **0B**
This suggests **no memory pressure**.

---

## 9) What does `lsblk` show that helps with storage analysis?
`lsblk` shows:
- block devices (disks)
- partition layout
- mountpoints
- filesystem type and UUID (with `-f`)  
It helps you understand storage topology and where filesystems are mounted.

---

## 10) Why did your system show `nvme0n1` instead of `sda`?
Because the VM uses NVMe storage. NVMe devices are commonly named:
- `/dev/nvme0n1`, `/dev/nvme1n1`, etc.  
Whereas SATA/SCSI often appear as `sda`, `sdb`, etc.

---

## 11) What does `df -h` tell you that `lsblk` does not?
`df -h` shows **filesystem usage** (used/available/%use) for mounted filesystems.  
`lsblk` focuses more on device layout and relationships (disk → partition → mountpoint).

---

## 12) What does `iostat -x` help you measure?
`iostat -x` provides extended disk performance metrics including:
- `%util` (device utilization)
- `await` (I/O latency)
- queue depth (`aqu-sz`)
- read/write behavior  
It’s used to identify storage bottlenecks or high latency.

---

## 13) Why might `lshw` not exist on some cloud images?
Minimal images often exclude non-essential inventory tools to reduce size and attack surface. In this lab, `lshw` was missing and had to be installed.

---

## 14) What does `lshw -short` provide compared to `lshw`?
- `lshw` produces a very detailed hardware tree
- `lshw -short` provides a concise summary table that is easier to scan for major components (CPU, memory, NIC, storage)

---

## 15) Based on your resource monitoring CSV, what conclusion can you draw?
From `resource_log.csv`:
- CPU usage ~0.6–0.9%
- Memory usage ~18.4–18.5%
- Disk usage ~17%  
This indicates the system is **underutilized** and has significant headroom for workloads or additional services.
