# 🛠 Troubleshooting Guide - Lab 16 — Troubleshooting (sar / sysstat)

## Issue 1: `sar: command not found`
### Symptoms
- `sar -V` returns `command not found`
- `which sar` shows no result

### Fix
Install sysstat:
- **RHEL/CentOS**:
```bash
sudo yum install -y sysstat
````

* **Ubuntu/Debian**:

```bash
sudo apt-get update -y
sudo apt-get install -y sysstat
```

Verify:

```bash
which sar
sar -V
```

---

## Issue 2: `sar` shows no historical data (empty or missing records)

### Symptoms

* `sar -u` returns only headers
* `/var/log/sa/` missing `saDD` file

### Causes

* sysstat service not enabled
* cron collection disabled/misconfigured
* system just booted and hasn’t collected an interval yet

### Fix

1. Ensure service is enabled and started:

```bash
sudo systemctl enable sysstat
sudo systemctl start sysstat
sudo systemctl status sysstat
```

2. Verify sysstat cron exists:

```bash
sudo cat /etc/cron.d/sysstat
```

3. Wait at least 10 minutes (if collection is every 10 minutes) or run a manual collection:

```bash
sudo /usr/lib64/sa/sa1 1 1
```

Verify:

```bash
ls -la /var/log/sa/
sar -u -f /var/log/sa/sa$(date +%d)
```

---

## Issue 3: Wrong paths for `sa1` / `sa2` on different distros

### Symptoms

* cron errors because `/usr/lib64/sa/sa1` not found

### Fix

Find correct location:

```bash
which sa1
which sa2
```

Common locations:

* RHEL/CentOS: `/usr/lib64/sa/sa1`, `/usr/lib64/sa/sa2`
* Ubuntu: `/usr/lib/sysstat/sa1`, `/usr/lib/sysstat/sa2`

Update `/etc/cron.d/sysstat` accordingly.

---

## Issue 4: Permission denied reading `/var/log/sa/saDD`

### Symptoms

* Non-root user gets “Permission denied”
* Can’t read `sa25`

### Fix

Use sudo:

```bash
sudo sar -u -f /var/log/sa/sa$(date +%d)
```

If you intentionally want readable logs for non-root:

```bash
sudo chmod 644 /var/log/sa/sa*
```

⚠️ Note: On real production servers, keep restrictive permissions unless policy requires otherwise.

---

## Issue 5: Custom script runs but logs aren’t created

### Symptoms

* `/usr/local/bin/custom-sar-collect.sh` runs but `/var/log/sar-custom/` is empty

### Fix checklist

1. Ensure directory exists + permission:

```bash
sudo mkdir -p /var/log/sar-custom
sudo chmod 755 /var/log/sar-custom
```

2. Ensure `sar` works:

```bash
sar -u 1 1
```

3. Run script with sudo (since it writes to /var/log):

```bash
sudo /usr/local/bin/custom-sar-collect.sh
sudo ls -la /var/log/sar-custom
```

---

## Issue 6: `bc` missing for report scripts

### Symptoms

* `performance-report.sh` fails with `bc: command not found`

### Fix

Install bc:

```bash
sudo yum install -y bc
# or
sudo apt-get install -y bc
```

---

## Issue 7: Dashboard script looks “stuck” or blank

### Symptoms

* `performance-dashboard.sh` clears screen repeatedly
* output refreshes every 5 seconds, looks like nothing is happening

### Fix / Confirm

That’s expected behavior.
Exit with:

```text
Ctrl + C
```

If `clear` is missing (rare):

```bash
sudo yum install -y ncurses
```

---

## Issue 8: `stress-ng` not available for generating workload

### Symptoms

* `stress-ng: command not found`

### Fix

* On CentOS/RHEL 7 (common in labs), enable EPEL then install:

```bash
sudo yum install -y epel-release
sudo yum install -y stress-ng
```

* On Ubuntu:

```bash
sudo apt-get install -y stress-ng
```

---

## Issue 9: Historical trend script shows only one day

### Symptoms

* `historical-analysis.sh` reports only today

### Causes

* No prior `/var/log/sa/saDD` files exist
* lab environment is freshly provisioned or retention is low

### Fix

This is normal for new machines.
To build history:

* keep sysstat running daily
* increase retention in `/etc/sysconfig/sysstat`:

  * `HISTORY=30`

```

---

## Quick Validation Commands (Post-lab)
# Verify sar works
sar -u 1 3

# Verify sysstat files
ls -la /var/log/sa/ | tail

# Verify custom logs
sudo ls -la /var/log/sar-custom | head

# Verify daily report
sudo ls -la /var/log/performance-reports | tail
