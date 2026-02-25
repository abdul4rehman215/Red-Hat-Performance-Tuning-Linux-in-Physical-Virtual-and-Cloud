# 🎤 Interview Q&A — Lab 10: Disk I/O Performance Tuning (Ubuntu 20.04)

## 1) What is disk I/O performance tuning?
Disk I/O performance tuning is optimizing how the OS interacts with storage to reduce latency and improve throughput/IOPS for workloads like databases, web servers, or file servers.

## 2) What does `iostat` do and why is it used?
`iostat` (from `sysstat`) reports CPU and storage I/O statistics. It helps identify disk bottlenecks by showing read/write rates, latency, queue size, and device utilization.

## 3) What is the difference between `iostat` and `iostat -x`?
- `iostat` shows basic throughput and transfers per second.
- `iostat -x` shows extended metrics like:
  - `r/s`, `w/s`, `rkB/s`, `wkB/s`
  - `r_await`, `w_await` (latency)
  - `aqu-sz` (average queue size)
  - `%util` (device busy time)

## 4) What is `%util` in `iostat`?
`%util` indicates how busy the device is. Near 100% usually means the disk is saturated (or the device is constantly busy).

## 5) What is `await` / `r_await` / `w_await`?
Latency in milliseconds (or reported units depending on tool output) that I/O requests spend waiting + being serviced.
- `r_await`: average read latency
- `w_await`: average write latency

## 6) What is an I/O scheduler in Linux?
A kernel component that decides how block I/O requests are ordered and dispatched to storage devices.

## 7) Why do we tune the I/O scheduler?
Different schedulers perform better depending on hardware (HDD vs SSD/NVMe) and workload (random I/O vs sequential). Scheduler choice impacts latency and throughput.

## 8) Which schedulers were available on this NVMe VM?
From `/sys/block/nvme0n1/queue/scheduler`:
- `mq-deadline`
- `none`
Schedulers like `bfq` and `kyber` were not available (Invalid argument when attempted).

## 9) Explain `mq-deadline` vs `none`.
- `mq-deadline`: multi-queue deadline scheduler; tries to prevent request starvation and keep latency stable.
- `none`: minimal scheduling (often best for NVMe) — relies on device/firmware for queue handling and reduces kernel overhead.

## 10) Why is `none` often recommended for NVMe?
NVMe devices are fast and internally optimized. Extra scheduling can add overhead with little benefit, so `none` often gives best throughput/latency balance.

## 11) How do you check the current scheduler?
```bash
cat /sys/block/nvme0n1/queue/scheduler
````

The active scheduler is shown in brackets, e.g. `mq-deadline [none]`.

## 12) How do you change scheduler temporarily?

```bash
echo none | sudo tee /sys/block/nvme0n1/queue/scheduler
```

This change is runtime-only (won’t survive reboot unless made persistent).

## 13) What’s the purpose of using `oflag=direct` / `iflag=direct` with `dd`?

Direct I/O bypasses page cache to better measure actual disk performance (less “fake” speed from RAM caching).

## 14) What is `fio` and why use it?

`fio` is a flexible I/O workload generator. It can simulate real workloads:

* random read/write, mixed read/write
* different block sizes, queue depths, job counts
* direct I/O and timed runs

## 15) What workloads were tested in this lab?

* Sequential write/read using `dd`
* Random I/O + sequential I/O using `fio`
* Workload simulation scripts (database/webserver/fileserver patterns)

## 16) Why can results vary between runs?

* background noise (system processes)
* caching (if not using direct I/O or caches not dropped)
* virtualization / shared storage
* different queue depths and job counts
  Best practice: run multiple times and average results.

## 17) What did the lab observe for scheduler performance?

On this NVMe VM:

* `none` showed slightly better sequential throughput than `mq-deadline`
* random I/O was similar (both around ~10k IOPS in the small randrw test)
  Conclusion: `none` was recommended for this system.

## 18) Why did `bfq` and `kyber` fail with “Invalid argument”?

Because those schedulers were not enabled/available for this device/kernel combination (common on NVMe with certain kernel configs).

## 19) How do you make scheduler changes persistent?

Options:

1. systemd oneshot service (recommended)
2. udev rule (device-based)
3. rc.local (legacy and not always enabled by default)

## 20) Show an example systemd service approach.

Create `/etc/systemd/system/ioscheduler.service` with:

* oneshot
* ExecStart sets scheduler
  Then:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ioscheduler.service
sudo systemctl start ioscheduler.service
```

## 21) What is the purpose of `drop_caches` before benchmarking?

It clears filesystem caches so tests start from a more consistent state. Used carefully because it can impact system performance temporarily.

```bash
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

## 22) How do you detect an I/O bottleneck in production?

Common signs:

* high `%util`
* rising `await`/latency
* increasing queue size (`aqu-sz`)
* application slowdown during disk-heavy operations
  Confirm with `iostat -x`, `iotop`, and workload-specific tracing.

## 23) Why did `hdparm` show an ioctl warning on NVMe?

`hdparm` is mainly designed for SATA/ATA devices; NVMe often doesn’t support some ATA ioctls, so warnings like “Inappropriate ioctl for device” can appear, while buffered read timing may still work.

## 24) What real-world roles use this knowledge?

* Linux system administrators
* DevOps / SRE
* performance engineers
* database administrators (DBA)
* cloud infrastructure engineers

## 25) One-liner summary of the lab outcome

Measured NVMe disk performance using `iostat/dd/fio`, compared schedulers, and selected **`none`** as the best scheduler for this VM with persistent configuration via systemd.
