# 🎤 Interview Q&A — Lab 04: Configuring Kernel Tunables

## 1) What are kernel tunables and why do they matter?
Kernel tunables are runtime-configurable parameters that influence how the Linux kernel manages CPU scheduling, memory, disk I/O behavior, and networking. They matter because correct tuning can improve performance, stability, and responsiveness under specific workloads.

---

## 2) What is `/proc/sys` and how is it different from normal files?
`/proc/sys` is a virtual filesystem exposing live kernel parameters as files. Writing values updates kernel behavior immediately (runtime), and reading values shows the current active kernel configuration.

---

## 3) What does `sysctl` do compared to editing `/proc/sys/...` directly?
`sysctl` is a user-friendly interface to read and set `/proc/sys` parameters using names like `vm.swappiness`.  
Both methods affect the same runtime values, but `sysctl` is easier to manage and script, and integrates with persistent configs.

---

## 4) Why do changes made with `sysctl` not persist after reboot by default?
Because runtime kernel parameters reset during boot. To persist changes, you must store them in sysctl config files, typically in `/etc/sysctl.d/*.conf` or `/etc/sysctl.conf`.

---

## 5) What does `vm.swappiness` control and what change did you apply?
`vm.swappiness` controls how aggressively the kernel swaps memory pages out of RAM.  
In this lab it was reduced from **60 → 10** to prefer keeping data in RAM and avoid unnecessary swapping.

---

## 6) What are “dirty pages” and why tune `vm.dirty_ratio` and `vm.dirty_background_ratio`?
Dirty pages are modified memory pages not yet written to disk.  
- `dirty_background_ratio` triggers background writeback
- `dirty_ratio` forces more aggressive writeback when memory becomes heavily dirty  
Tuning helps control writeback bursts and latency under I/O-heavy workloads.

---

## 7) What does `vm.vfs_cache_pressure` influence?
It controls how aggressively the kernel reclaims memory used for inode/dentry caches.  
Higher values reclaim cache faster (less caching), lower values keep cache longer (potentially better filesystem performance).

---

## 8) What network tunables did you change and why?
The lab tuned:
- socket buffer max/default (`net.core.rmem_*`, `net.core.wmem_*`)
- TCP buffer ranges (`net.ipv4.tcp_rmem`, `net.ipv4.tcp_wmem`)
- backlog queue (`net.core.netdev_max_backlog`)
- pending connection queue (`net.core.somaxconn`)
- window scaling (`net.ipv4.tcp_window_scaling`)  
These can improve throughput and reduce drops/latency under high network load.

---

## 9) What is the purpose of `net.core.somaxconn`?
It sets the maximum number of queued TCP connections for a listening socket. Increasing it can help servers handle spikes in incoming connection requests without dropping them.

---

## 10) Why did your network throughput test fail initially?
Because `nc` (netcat) was not installed. The script depended on `nc`, so it failed until `nmap-ncat` was installed.

---

## 11) How did you make the tuning persistent in a clean, production-friendly way?
By creating a dedicated config file:
`/etc/sysctl.d/99-performance-tuning.conf`  
This keeps tuning isolated, easy to audit, and removable without editing vendor defaults.

---

## 12) How did you apply the persistent configuration immediately without rebooting?
Using:
```bash
sysctl -p /etc/sysctl.d/99-performance-tuning.conf
````

and verifying via `sysctl` queries.

---

## 13) What does `sysctl --system` do?

It loads sysctl settings from:

* `/usr/lib/sysctl.d/`
* `/run/sysctl.d/`
* `/etc/sysctl.d/`
* `/etc/sysctl.conf`
  It shows the load order and helps confirm the persistent file is being applied.

---

## 14) Why is a validation script important after tuning?

Because it:

* confirms the expected values are active
* detects drift or misapplied changes
* supports repeatable verification (good for production change control)

---

## 15) What safety best practice did you implement for rollback?

A rollback script (`rollback_tuning.sh`) that restores defaults and includes a confirmation prompt.
Also documented that the persistent file must be removed/renamed to make rollback survive reboot.
