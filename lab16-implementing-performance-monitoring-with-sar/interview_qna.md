# 🧠 Interview Q&A - Lab 16: Implementing Performance Monitoring with sar (sysstat)

---

## 1) What is `sar`, and what package provides it?
`sar` (System Activity Reporter) is a historical + real-time performance reporting tool. It comes from the **sysstat** package.

---

## 2) Why is `sar` valuable compared to running `top` or `free`?
`top`/`free` show **current** state only, while `sar` collects data over time and allows **trend analysis**, baselining, and correlation with incidents (CPU spikes, memory pressure, disk bursts, network anomalies).

---

## 3) Where does `sar` store historical performance data on Linux?
Typically under:
- **RHEL/CentOS**: `/var/log/sa/saDD` and `/var/log/sa/sarDD`
  - `saDD` = binary activity file (used by sar)
  - `sarDD` = daily summary text output (optional)

---

## 4) What is the difference between `sa1` and `sa2`?
- `sa1`: collects system activity data periodically (writes to `saDD`)
- `sa2`: generates daily summary reports from collected data

Commonly configured in `/etc/cron.d/sysstat`.

---

## 5) What system resource areas can `sar` monitor?
Common ones used in this lab:
- CPU: `sar -u`
- Load/Run queue: `sar -q`
- Memory: `sar -r`
- Swap: `sar -S`
- Paging: `sar -B`
- Disk I/O: `sar -d`
- Network: `sar -n DEV`, `sar -n EDEV`, `sar -n TCP`

---

## 6) How do you verify that sysstat is collecting data?
- Confirm service:
  - `systemctl status sysstat`
- Confirm files exist:
  - `ls -la /var/log/sa/`
- Confirm `sar` can read today’s file:
  - `sar -u -f /var/log/sa/sa$(date +%d)`

---

## 7) In `sar -u`, what does `%iowait` indicate?
`%iowait` represents time the CPU is idle **waiting on disk I/O**. High iowait often suggests storage bottlenecks, slow disks, or heavy synchronous writes.

---

## 8) What does `sar -d` help you detect?
Disk utilization patterns including:
- `tps` (transactions per second),
- `rd_sec/s` and `wr_sec/s` rates,
- `await` (average I/O wait),
- `%util` (device busy percentage).

It helps identify spikes, queueing, and latency bottlenecks.

---

## 9) What is the purpose of customizing `/etc/sysconfig/sysstat`?
To control:
- retention days (`HISTORY`)
- compression (`COMPRESSAFTER`)
- extra collection options (`SADC_OPTIONS="-S DISK"` etc.)
This controls how much historical data you keep and what is captured.

---

## 10) Why did we create `/usr/local/bin/custom-sar-collect.sh`?
To collect focused, short-window snapshots into a separate directory (`/var/log/sar-custom`) for:
- debugging,
- “incident capture” runs,
- repeatable collection for GitHub lab evidence.

---

## 11) How would you generate a report automatically every day?
Use a scheduled task:
- cron entry like: `0 6 * * * root /usr/local/bin/daily-performance-report.sh`
- store outputs in `/var/log/performance-reports/`

---

## 12) What are typical best practices for performance monitoring in production?
- Keep baseline metrics (normal ranges)
- Use consistent intervals (e.g., 10 minutes) + longer retention (e.g., 30 days)
- Track CPU, memory, disk, network together (not in isolation)
- Set thresholds + alerts (CPU>80%, Mem>85%, Disk util >80%)
- Combine `sar` with modern telemetry stacks (Prometheus/Grafana) when available

---

## 13) Why might historical analysis show only “today” on a fresh lab machine?
Because `sar` files are created daily; if the lab machine is new or data retention is short, only the current day’s `saDD` exists.

---

## 14) What does the “runq-sz” field in `sar -q` represent?
`runq-sz` is the **run queue size** (number of runnable tasks). Sustained high values can indicate CPU contention or overloaded instances.

---

## 15) What’s a realistic real-world use case for `sar` during incident response?
If users report slowness at a specific time, you can pull `sar` data for that window to check:
- CPU bursts,
- memory pressure,
- disk waits,
- network spikes,
and correlate to deployment logs or workload events.

## 17) Where does `sar` store historical data on Linux?

On RHEL/CentOS, data is stored in:

* `/var/log/sa/saDD` (binary data for day DD)
* `/var/log/sa/sarDD` (text summary)
  Example:

```bash
ls -la /var/log/sa/
```

## 18) What is the purpose of `sa1` and `sa2`?

* `sa1` collects performance data and writes it into `saDD` files.
* `sa2` generates daily reports (summaries) and writes them into `sarDD`.
  They are usually scheduled via cron in `/etc/cron.d/sysstat`.

## 19) How do you check CPU usage with `sar`?

Examples:

```bash
sar -u
sar -u 1 5
sar -u -s 09:00:00 -e 17:00:00
```

Key fields:

* `%user`, `%system`, `%iowait`, `%idle`

## 6) How do you analyze memory using `sar`?

Examples:

```bash
sar -r
sar -S
sar -B
```

* `-r` = memory usage
* `-S` = swap usage
* `-B` = paging statistics (faults, pgpgin/pgpgout)

## 20) How do you analyze disk performance using `sar`?

Example:

```bash
sar -d
sar -d 1 3
```

Key fields often reviewed:

* `tps`, `rd_sec/s`, `wr_sec/s`, `await`, `%util`

## 21) How do you analyze network performance using `sar`?

Examples:

```bash
sar -n DEV
sar -n EDEV
sar -n TCP
```

* `DEV` = RX/TX throughput/packets per interface
* `EDEV` = errors/drops
* `TCP` = TCP activity (active/passive opens, segments)

## 9) How do you view historical data (not live) for today?

Use the binary file:

```bash
sar -u -f /var/log/sa/sa$(date +%d)
```

## 22) What does enabling `sysstat` service do?

It ensures scheduled collection is active (depending on distro setup) and helps initialize/reset activity logs. On CentOS/RHEL, it ties into cron-based collection using `sa1`/`sa2`.

## 23) Why did you create a custom collector script instead of only using sysstat defaults?

Default sysstat runs at fixed intervals and stores binary logs. A custom script allows:

* Different sampling rate (e.g., every 2s)
* Separate log folders (`/var/log/sar-custom`)
* Collect multiple categories simultaneously (CPU, memory, disk, network)
* Easier GitHub-friendly outputs

## 24) Why is historical monitoring important for production systems?

Because most performance issues are time-dependent (batch jobs, spikes, cron jobs, deployments). Without historical data, you can’t correlate events with resource usage patterns, making root-cause analysis much harder.

## 25) What are common signs of CPU bottlenecks in `sar` output?

* High `%user` and/or `%system`
* Low `%idle`
* Rising run queue (`sar -q`)
* Sustained peaks during business hours or scheduled jobs

## 26) What are common signs of disk bottlenecks in `sar` output?

* High `await`
* Increasing `%util`
* Rising queue size (`avgqu-sz`)
* In real production: persistent high `%util` indicates saturation

## 27) How can `sar` reporting be automated?

* cron jobs (daily / hourly scripts)
* sysstat built-in cron `/etc/cron.d/sysstat`
* custom scripts scheduled via `/etc/crontab` or `/etc/cron.d/*`
  Example used in lab:

```bash
0 6 * * * root /usr/local/bin/daily-performance-report.sh
```


