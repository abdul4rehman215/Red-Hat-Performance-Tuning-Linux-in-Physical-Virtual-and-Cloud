# 🎤 Interview Q&A — Lab 05: Applying Tuned Profiles for Optimization

## 1) What is `tuned` and what problem does it solve?
`tuned` is a dynamic tuning daemon that applies performance optimization settings through profiles. It solves the problem of managing many low-level tuning knobs (CPU governor, sysctl values, disk settings, etc.) in a consistent and repeatable way.

---

## 2) What is the difference between `tuned` and manually using `sysctl`?
`sysctl` changes individual kernel parameters directly. `tuned` applies a **bundle of coordinated settings** (governor, sysctl, VM tweaks, etc.) based on the chosen profile, making tuning more systematic and easier to maintain.

---

## 3) How do you check if tuned is installed and running?
- Installed packages:
```bash
rpm -qa | grep tuned
````

* Service state:

```bash
systemctl status tuned
```

---

## 4) Which command lists available tuned profiles and which shows the active one?

* List profiles:

```bash
tuned-adm list
```

* Show active profile:

```bash
tuned-adm active
```

---

## 5) What does `tuned-adm recommend` do?

It recommends the best profile for the detected system environment (e.g., VM guest vs host). In this lab, it recommended `virtual-guest`.

---

## 6) What is the purpose of `tuned-adm verify`?

It verifies the currently active profile is applied without errors and the expected settings are in effect.

---

## 7) What changes did you observe after applying the `balanced` profile?

On this VM, `balanced` switched the CPU governor to **powersave**. This can reduce power usage and may reduce peak throughput compared to `performance` governor.

---

## 8) What changes did you observe after applying `throughput-performance`?

It used the **performance** CPU governor and is designed to maximize throughput. During stress testing, CPU utilization was slightly higher and I/O wait was lower compared to the balanced run.

---

## 9) Why is `virtual-guest` often recommended for cloud VMs?

Because it applies settings optimized for virtualized environments where the hypervisor and virtual hardware characteristics differ from bare metal (scheduler + sysctl choices tuned for guest behavior).

---

## 10) Why did `cat /sys/block/sda/queue/scheduler` fail on your system?

The VM used NVMe disks (`/dev/nvme0n1`) instead of an `sda` device, so the path for `sda` didn’t exist. The correct scheduler file was:

```bash
cat /sys/block/nvme0n1/queue/scheduler
```

---

## 11) How did you compare the profiles in a repeatable way?

By:

* collecting baseline logs per profile (`performance_monitor.sh`)
* running the same CPU + I/O stress test per profile (`stress_test.sh`)
* extracting load/CPU/memory patterns (`compare_profiles.sh`)
* generating a summary report (`performance_analysis.sh`)

---

## 12) What does “profile inheritance” mean in tuned?

Profiles can include other profiles using `include=` in `tuned.conf`. This allows layered configuration (base profile + specialized overrides). You confirmed this by inspecting:

* `/usr/lib/tuned/balanced/tuned.conf`
* `/usr/lib/tuned/throughput-performance/tuned.conf`
* `/usr/lib/tuned/virtual-guest/tuned.conf`

---

## 13) How do you create a custom tuned profile?

Create a directory under `/etc/tuned/<profile-name>/` and add a `tuned.conf`. Then apply it using:

```bash
sudo tuned-adm profile <profile-name>
```

In this lab:
`/etc/tuned/custom-lab-profile/tuned.conf`

---

## 14) What risk comes with using high-performance profiles?

Potential trade-offs include:

* higher power consumption
* increased heat
* less “energy-aware” behavior
* potential contention if the workload doesn’t benefit from aggressive settings
  That’s why baseline measurement + validation is important.

---

## 15) If tuned behaves unexpectedly, what are your first troubleshooting steps?

1. Check service:

```bash
systemctl status tuned
```

2. Confirm active profile:

```bash
tuned-adm active
```

3. Verify:

```bash
tuned-adm verify
```

4. Check logs:

```bash
journalctl -u tuned -n 50 --no-pager
```

5. Reapply profile or revert to recommended:

```bash
tuned-adm recommend
sudo tuned-adm profile <recommended>
```
