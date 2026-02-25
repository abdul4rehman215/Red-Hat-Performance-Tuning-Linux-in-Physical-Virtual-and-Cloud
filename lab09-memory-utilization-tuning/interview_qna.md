# 🎤 Interview Q&A - Lab 09: Memory Utilization Tuning

> Focus: Linux memory basics, `vm.swappiness`, monitoring with `free`/`vmstat`, swap setup, and safe tuning practices.

---

## 1) What is Linux `vm.swappiness`?
`vm.swappiness` is a kernel parameter that controls **how aggressively Linux moves anonymous memory pages from RAM to swap**.

- **Low value (0–10):** avoid swapping, keep pages in RAM longer.
- **Default (60):** balanced.
- **High value (100):** swap more aggressively.

---

## 2) If swap is not configured, does swappiness matter?
It matters **less**, because the kernel has nowhere to swap to.  
But it still reflects the **kernel’s preference** and can matter once swap gets enabled later (e.g., swapfile).

---

## 3) How do you check swappiness?
```bash
cat /proc/sys/vm/swappiness
sysctl vm.swappiness
````

---

## 4) How do you change swappiness temporarily?

Temporary (until reboot):

```bash
sudo sysctl vm.swappiness=10
# OR
echo 10 | sudo tee /proc/sys/vm/swappiness
```

---

## 5) How do you make swappiness persistent?

Add it to sysctl config and reload:

```bash
echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

**Best practice:** don’t keep appending duplicates—edit and keep one clean entry.

---

## 6) What is the difference between `free` memory and `available` memory?

* **free:** completely unused RAM (often small because Linux uses RAM for caches)
* **available:** estimated RAM available for new apps **without swapping** (more useful metric)

---

## 7) What do `buffers` and `cache` mean?

They are memory used by the kernel to speed up I/O:

* **buffers:** metadata and block device buffers
* **cache:** page cache (file contents)

This memory is **reclaimable** if applications need RAM.

---

## 8) What commands did you use to monitor memory?

```bash
free -h
free -h -s 2 -c 5
vmstat
vmstat 2 10
vmstat -S M 2 5
cat /proc/meminfo | head -20
```

---

## 9) What key fields in `/proc/meminfo` help identify memory pressure?

* `MemAvailable`
* `MemFree`
* `Cached`
* `Buffers`
* `Dirty`, `Writeback`
* `SwapTotal`, `SwapFree`
* `Active`, `Inactive`

---

## 10) What does `vmstat` show that `free` does not?

`vmstat` gives a broader performance view including:

* **r:** runnable processes (CPU wait)
* **si/so:** swap in/out activity
* **bi/bo:** block I/O
* **cs:** context switches
* CPU breakdown (`us`, `sy`, `id`, `wa`)

---

## 11) What does it mean if `si` and `so` are consistently non-zero?

It usually indicates **active swapping**:

* Can mean **RAM pressure**
* May cause latency spikes and performance degradation

---

## 12) How do you clear caches and why is `tee` used?

Clear caches:

```bash
sudo sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

`tee` is used because `>` redirection happens in the shell; without tee the write may not have sudo privileges.

---

## 13) What is `vm.vfs_cache_pressure`?

Controls how aggressively the kernel reclaims **inode/dentry caches**.

* Lower (e.g., 50): keep filesystem caches longer (faster file access)
* Higher (>100): reclaim caches more aggressively

---

## 14) What are `vm.dirty_ratio` and `vm.dirty_background_ratio`?

They control writeback behavior:

* `dirty_background_ratio`: % of memory dirty pages before background writeback starts
* `dirty_ratio`: % of memory dirty pages before processes are forced to write/sync

Tuning helps balance throughput vs latency under write-heavy workloads.

---

## 15) How did you validate whether memory tuning helped?

By:

* logging baseline (`memory_baseline.txt`)
* observing `free`, `vmstat` under load
* using `stress-ng` memory workloads
* checking swap in/out (`si/so`) and responsiveness

---

## 16) Why can stress tests freeze the system?

If memory workload is too aggressive (e.g., allocating near 80–90% RAM) and swap is slow or missing:

* the kernel may thrash
* system can become unresponsive

Mitigation:

```bash
stress-ng --vm 1 --vm-bytes 25% --timeout 30s
```

---

## 17) How do you create swap on a system with no swap?

Create a swapfile:

```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
free -h
```

Optional persistence: add to `/etc/fstab`.

---

## 18) What would you do if `/etc/sysctl.conf` has duplicate entries?

Clean it up:

* open with editor and keep a **single** `vm.swappiness=...` line
* or use `/etc/sysctl.d/99-custom.conf` for custom settings
* reload:

```bash
sudo sysctl -p
# or
sudo sysctl --system
```

---

## 19) When would you prefer higher swappiness?

Cases where:

* memory pressure is expected and swap is fast (NVMe)
* keeping more file cache helps and swapping idle anonymous pages is acceptable
* desktop/interactive environments can vary by workload

---

## 20) What is a safe tuning workflow for production?

1. **Baseline first** (free/vmstat, app latency, I/O)
2. **Change one parameter at a time**
3. **Test realistic load**
4. **Monitor swap, latency, and OOM risk**
5. **Make persistent only after validation**
6. **Document + rollback plan**

---

## 21) Common interview troubleshooting scenario

**Q:** System is slow; `free` shows low free memory. Is it always a RAM problem?
**A:** Not necessarily. Linux uses memory for caches. Check:

* `available`
* `si/so` swap activity
* `wa` I/O wait
* `vmstat` and `dmesg` for OOM events

---

## 22) One-liner checks you should remember

```bash
free -h
vmstat 1 5
sysctl vm.swappiness vm.vfs_cache_pressure vm.dirty_ratio vm.dirty_background_ratio
swapon --show
cat /proc/meminfo | head
```

---
