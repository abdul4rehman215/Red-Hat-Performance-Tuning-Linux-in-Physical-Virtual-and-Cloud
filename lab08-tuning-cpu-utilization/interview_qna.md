## 🎤 Interview Q&A Lab 08: Tuning CPU Utilization

## 1) What is “CPU scheduling” in Linux, and why does it matter?

**Answer:** CPU scheduling is how the Linux kernel decides **which process/thread runs on which CPU core and for how long**. It matters because poor scheduling can cause **high latency, low throughput, excessive context switching**, and inefficient CPU utilization—especially under heavy load.

---

## 2) Which scheduler tunables did you inspect in this lab?

**Answer:** I inspected scheduler-related sysctl parameters like:

* `kernel.sched_min_granularity_ns`
* `kernel.sched_wakeup_granularity_ns`
* `kernel.sched_migration_cost_ns`
* `kernel.sched_latency_ns`
  using:
  `sysctl -a | grep sched`

---

## 3) Why did `cat /sys/block/sda/queue/scheduler` fail, and how did you fix it?

**Answer:** It failed because the VM uses **NVMe disks**, so the device name is `nvme0n1` (not `sda`).
Fix:

* Check disks: `lsblk`
* Use correct path: `cat /sys/block/nvme0n1/queue/scheduler`

---

## 4) What does `kernel.sched_min_granularity_ns` control?

**Answer:** It controls the **minimum time slice** that a task should get on CPU before being preempted in the CFS scheduler.
Lower values can improve responsiveness for short tasks but may increase **context switching overhead**.

---

## 5) What does `kernel.sched_wakeup_granularity_ns` control?

**Answer:** It affects how easily a **waking task** can preempt a currently running task.
Lower values can reduce latency for interactive tasks but may increase preemptions and scheduler overhead.

---

## 6) What does `kernel.sched_migration_cost_ns` control?

**Answer:** It influences the cost of moving tasks between CPUs.
Higher values make the scheduler **less likely to migrate tasks**, improving cache locality but potentially reducing load balancing across cores.

---

## 7) What does `kernel.sched_latency_ns` represent?

**Answer:** It represents the targeted **scheduling period** (roughly, the time in which every runnable task should get CPU time).
Lowering it can improve responsiveness but may increase overhead under heavy multi-tasking.

---

## 8) What baseline CPU performance test did you run, and why?

**Answer:** I ran a baseline CPU stress test using:

* `stress-ng --cpu $(nproc) --timeout 30s --metrics-brief`

This helped establish a **before/after comparison** when I changed scheduler tunables.

---

## 9) What changes did you apply to scheduler tunables, and what was the goal?

**Answer:** I applied more aggressive/low-latency settings (example values used):

* `sched_min_granularity_ns=1000000`
* `sched_wakeup_granularity_ns=2000000`
* `sched_migration_cost_ns=250000`
* `sched_latency_ns=6000000`

Goal: improve **responsiveness and throughput** for CPU-heavy activity while observing realistic results.

---

## 10) How did you make sysctl changes persistent?

**Answer:** I appended the tuning block to `/etc/sysctl.conf` using `sudo nano`, for example:

```conf
# CPU Scheduler Optimizations
kernel.sched_min_granularity_ns=1000000
kernel.sched_wakeup_granularity_ns=2000000
kernel.sched_migration_cost_ns=250000
kernel.sched_latency_ns=6000000
```

Then validated with `sysctl <param>`.

---

## 11) What is CPU affinity, and why use it?

**Answer:** CPU affinity binds a process to specific CPU core(s).
It can improve performance by:

* reducing cache misses
* reducing migrations
* stabilizing latency for CPU-bound workloads

Tools used: `taskset`, and verification with `taskset -p <PID>`.

---

## 12) How did you verify CPU count and CPU topology?

**Answer:** I checked CPU inventory and layout using:

* `lscpu`
* `lscpu -e`
* `cat /proc/cpuinfo | grep processor | wc -l`

For NUMA mapping:

* Installed + used `numactl --hardware`

---

## 13) What happened when you pinned too many threads onto fewer cores?

**Answer:** Performance dropped.
Example: running **4 busy threads on only 2 cores** reduced throughput (requests/sec) in the web server simulator.
This is expected because cores become oversubscribed → more contention → more waiting → reduced throughput.

---

## 14) Why did changing CPU governor fail on the cloud VM?

**Answer:** Many cloud VMs **don’t expose cpufreq scaling interfaces**, so paths like:
`/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`
may not exist. The tuning must focus on scheduler behavior and workload placement instead.

---

## 15) What was the “sudo echo > file” pitfall, and what’s the correct fix?

**Answer:** `sudo echo 3 > /proc/sys/vm/drop_caches` failed because redirection (`>`) happens in the **current shell**, not inside sudo.
Correct fix:

```bash
echo 3 | sudo tee /proc/sys/vm/drop_caches
```
